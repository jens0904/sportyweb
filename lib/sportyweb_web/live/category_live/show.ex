defmodule SportywebWeb.CategoryLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Inventory

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :categories)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    category =
      Inventory.get_category!(id, [:club, :rental_fees])

    {:noreply,
     socket
     |> assign(:page_title, "Ausrüstungskategorie: #{category.name}")
     |> assign(:category, category)
     |> assign(:club, category.club)
     |> stream(:rental_fees, category.rental_fees)}
  end
end
