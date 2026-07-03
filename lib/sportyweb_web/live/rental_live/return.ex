defmodule SportywebWeb.RentalLive.Return do
  use SportywebWeb, :live_view

  alias Sportyweb.Inventory


  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.RentalLive.ReturnComponent}
        id={@rental.id}
        title="Ausleihe zurückgeben"
        action={@live_action}
        rental={@rental}
        article={@article}
        club={@club}
        navigate={~p"/articles/#{@article}"}
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



  def apply_action(socket, :return, %{"id" => id}) do
    rental = Inventory.get_rental!(id, [:rental_fee, article: :club])

    socket
    |> assign(:page_title, "Ausleihe zurückgeben")
    |> assign(:rental, rental)
    |> assign(:article, rental.article)
    |> assign(:club, rental.article.club)
  end



end
