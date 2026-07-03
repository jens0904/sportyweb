defmodule SportywebWeb.OldRentalsLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Inventory

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :old_rentals)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    old_rentals = Inventory.get_old_rentals!(id, [:club, :article, :contact, :location, :unit])

    {:noreply,
     socket
     |> assign(:page_title, "Archiv Vermietung: #{old_rentals.article.name}")
     |> assign(:old_rentals, old_rentals)
     |> assign(:club, old_rentals.club)}
  end
end
