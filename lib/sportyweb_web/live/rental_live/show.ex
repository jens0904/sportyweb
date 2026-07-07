defmodule SportywebWeb.RentalLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Inventory
  alias Sportyweb.Inventory.Rental
  alias Sportyweb.Personal.Contact


  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :articles)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    rental =
      Inventory.get_rental!(id, [:location, :unit, contact: :contracts, article: :club])

      rental_rule = Inventory.get_applicable_rental_rule(rental.article.id)

    {:noreply,
     socket
     |> assign(:page_title, "Ausleihe: #{rental.article.name}")
     |> assign(:rental, rental)
     |> assign(:article, rental.article)
     |> assign(:rental_rule, rental_rule)
     |> assign(:club, rental.article.club)}
  end
end
