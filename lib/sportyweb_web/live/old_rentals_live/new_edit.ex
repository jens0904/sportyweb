defmodule SportywebWeb.OldRentalsLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Inventory
  alias Sportyweb.Inventory.OldRentals

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.OldRentalsLive.FormComponent}
        id={@old_rentals.id || :new}
        title={@page_title}
        action={@live_action}
        old_rentals={@old_rentals}
        club={@club}
        navigate={
          if @old_rentals.id,
            do: ~p"/old_rentals/#{@old_rentals}",
            else: ~p"/clubs/#{@club}/old_rentals"
        }
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :old_rentals)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    old_rentals = Inventory.get_old_rentals!(id, [:club])

    socket
    |> assign(:page_title, "Alte Ausleihe bearbeiten")
    |> assign(:old_rentals, old_rentals)
    |> assign(:club, old_rentals.club)
  end


  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    old_rentals = Inventory.get_old_rentals!(id)
    {:ok, _old_rentals} = Inventory.delete_old_rentals(old_rentals)

    {:noreply,
     socket
     |> put_flash(:info, "Alte Ausleihe erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{old_rentals.club_id}/old_rentals")}
  end
end
