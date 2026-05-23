defmodule SportywebWeb.CategoryLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Rental

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :categories)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    category =
      Rental.get_category!(id, [:club])

    {:noreply,
     socket
     |> assign(:page_title, "Ausrüstungskategorie: #{category.name}")
     |> assign(:category, category)
     |> assign(:club, category.club)}
  end
end
