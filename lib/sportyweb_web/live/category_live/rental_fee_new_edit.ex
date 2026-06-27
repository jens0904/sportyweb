defmodule SportywebWeb.CategoryLive.RentalFeeNewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Rental
  alias Sportyweb.Rental.RentalFee

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.RentalFeeLive.FormComponent}
        id={@rental_fee.id || :new}
        title={@page_title}
        action={@live_action}
        rental_fee={@rental_fee}
        rental_fee_object={@category}
        navigate={if @rental_fee.id, do: ~p"/rental_fees/#{@rental_fee}", else: ~p"/categories/#{@category}"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :categories)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    rental_fee = Rental.get_rental_fee!(id, [:category, article: :club])

    socket
    |> assign(:page_title, "Mietgebühr bearbeiten")
    |> assign(:rental_fee, rental_fee)
    |> assign(:category, rental_fee.category)
    |> assign(:club, rental_fee.article.club)
  end

  defp apply_action(socket, :new, %{"category_id" => category_id}) do
    category = Rental.get_category!(category_id, [:club, :rental_fees])
    club = category.club

    socket
    |> assign(:page_title, "Mietgebühr anlegen")
    |> assign(:rental_fee, %RentalFee{
      club_id: club.id,
      club: club,
      categories: [category]
    })
    |> assign(:category, category)
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    rental_fee = Rental.get_rental_fee!(id)
    {:ok, _} = Rental.delete_rental_fee(rental_fee)

    {:noreply,
     socket
     |> put_flash(:info, "Mietgebühr erfolgreich gelöscht")
     |> push_navigate(to: "/article/#{rental_fee.article_id}/rental_fees")}
  end
end
