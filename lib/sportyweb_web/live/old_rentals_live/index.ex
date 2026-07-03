defmodule SportywebWeb.OldRentalsLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Inventory
  alias Sportyweb.Inventory.OldRentals
  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :old_rentals)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index_root, _params) do
    socket
    |> redirect(to: "/clubs")
  end

  defp apply_action(socket, :index, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id, old_rentals: [:article, :contact, :location, :unit])

    socket
    |> assign(:page_title, "Archivierte Vermietungen")
    |> assign(:club, club)
    |> stream(:old_rentals_collection, club.old_rentals, reset: true)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Neue alte Ausleihe")
    |> assign(:club, club)
    |> assign(:old_rentals, %OldRentals{club: club})
  end

  defp apply_action(socket, :edit, %{"club_id" => club_id, "id" => id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Alte Ausleihe bearbeiten")
    |> assign(:club, club)
    |> assign(:old_rentals, Inventory.get_old_rentals!(id))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    old_rentals = Inventory.get_old_rentals!(id)
    {:ok, _old_rentals} = Inventory.delete_old_rentals(old_rentals)

    {:noreply, stream_delete(socket, :old_rentals_collection, old_rentals)}
  end
end
