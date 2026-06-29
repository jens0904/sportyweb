defmodule SportywebWeb.RentalLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Inventory
  alias Sportyweb.Inventory.Rental

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.RentalLive.FormComponent}
        id={@rental.id || :new}
        title={@page_title}
        action={@live_action}
        rental={@rental}
        article={@article}
        club={@club}
        navigate={if @rental.id, do: ~p"/rentals/#{@rental}", else: ~p"/articles/#{@article}"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :articles)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    rental = Inventory.get_rental!(id, article: :club)

    socket
    |> assign(:page_title, "Ausleihe bearbeiten")
    |> assign(:rental, rental)
    |> assign(:article, rental.article)
    |> assign(:club, rental.article.club)
  end

  defp apply_action(socket, :new, %{"article_id" => article_id}) do
    article = Inventory.get_article!(article_id, [:club, :units])

    socket
    |> assign(:page_title, "Ausleihe anlegen")
    |> assign(:rental, %Rental{
      article_id: article.id,
      article: article,
      rental_date: DateTime.utc_now() |> DateTime.truncate(:second)
    })
    |> assign(:article, article)
    |> assign(:club, article.club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    rental = Inventory.get_rental!(id)
    {:ok, _} = Inventory.delete_rental(rental)

    {:noreply,
     socket
     |> put_flash(:info, "Ausleihe erfolgreich gelöscht")
     |> push_navigate(to: "/article/#{rental.article_id}/rentals")}
  end
end
