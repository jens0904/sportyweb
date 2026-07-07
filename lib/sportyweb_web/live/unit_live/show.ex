defmodule SportywebWeb.UnitLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Inventory
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Inventory.Rental

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :articles)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    unit =
      Inventory.get_unit!(
        id,
        [
          :location,
          article: :club,
          rentals: [:location, :contact, article: :club, contact: :contracts]
        ]
      )

    active_rental =
      Enum.find(unit.rentals, &Rental.active?/1)

    inactive_rentals =
      Enum.filter(unit.rentals, &Rental.inactive?/1)

    incident_rentals =
      Enum.filter(unit.rentals, fn rental ->
        Rental.inactive?(rental) and rental.condition_status in ["damaged", "lost"]
      end)

    fee_rentals =
      Enum.filter(unit.rentals, fn rental ->
        Rental.inactive?(rental) and rental.fee_required == true
      end)

    {:noreply,
     socket
     |> assign(:page_title, "Einheit: #{unit.serial_number}")
     |> assign(:unit, unit)
     |> assign(:location, unit.location)
     |> assign(:article, unit.article)
     |> assign(:club, unit.article.club)
     |> assign(:active_rental, active_rental)
     |> assign(:inactive_rentals_count, length(inactive_rentals))
     |> assign(:incident_rentals_count, length(incident_rentals))
     |> assign(:fee_rentals_count, length(fee_rentals))
     |> stream(:inactive_rentals, inactive_rentals, reset: true)
     |> stream(:incident_rentals, incident_rentals, reset: true)
     |> stream(:fee_rentals, fee_rentals, reset: true)}
  end
end
