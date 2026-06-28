defmodule SportywebWeb.RentalLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Inventory


  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :articles)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    rental =
      Inventory.get_rental!(id, [:location, :unit, :contact, article: :club])

    {:noreply,
     socket
     |> assign(:page_title, "Ausleihe: #{rental.rental_number}")
     |> assign(:rental, rental)
     |> assign(:article, rental.article)
     |> assign(:club, rental.article.club)}
  end
end
