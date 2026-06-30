defmodule SportywebWeb.RentalLive.Renew do
  use SportywebWeb, :live_view

  alias Sportyweb.Inventory


  @impl true
  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.RentalLive.RenewComponent}
        id={@rental.id}
        title="Ausleihe verlängern"
        action={@live_action}
        rental={@rental}
        article={@article}
        club={@club}
        navigate={~p"/rentals/#{@rental}"}
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



  def apply_action(socket, :renew, %{"id" => id}) do
    rental = Inventory.get_rental!(id, article: :club, article: :rental_rules)

    socket
    |> assign(:page_title, "Ausleihe verlängern")
    |> assign(:rental, rental)
    |> assign(:article, rental.article)
    |> assign(:club, rental.article.club)
    |> assign(:rental_rule, rental.article.rental_rules)
  end

end
