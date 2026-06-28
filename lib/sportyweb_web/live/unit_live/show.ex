defmodule SportywebWeb.UnitLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Inventory

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :articles)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    unit =
      Inventory.get_unit_with_inactive_rentals!(id)

    {:noreply,
     socket
     |> assign(:page_title, "Einheit: #{unit.serial_number}")
     |> assign(:unit, unit)
     |> assign(:location, unit.location)
     |> assign(:article, unit.article)
     |> assign(:club, unit.article.club)
     |> stream(:rentals, unit.rentals)}
  end
end
