defmodule SportywebWeb.RentalRuleLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Rental
  alias Sportyweb.Rental.RentalRule

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.RentalRuleLive.FormComponent}
        id={@rental_rule.id || :new}
        title={@page_title}
        action={@live_action}
        rental_rule={@rental_rule}
        club={@club}
        navigate={
          if @rental_rule.id,
            do: ~p"/rental_rules/#{@rental_rule}",
            else: ~p"/clubs/#{@club}/rental_rules"
        }
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :rental_rules)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    rental_rule = Rental.get_rental_rule!(id, [:club])

    socket
    |> assign(:page_title, "Ausleihregel bearbeiten")
    |> assign(:rental_rule, rental_rule)
    |> assign(:club, rental_rule.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id, [:categories, :articles])

    socket
    |> assign(:page_title, "Ausleihregel erstellen")
    |> assign(:rental_rule, %RentalRule{
      club_id: club.id,
      club: club
    })
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    rental_rule = Rental.get_rental_rule!(id)
    {:ok, _} = Rental.delete_rental_rule(rental_rule)

    {:noreply,
     socket
     |> put_flash(:info, "Ausleihregel erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{rental_rule.club_id}/rental_rules")}
  end
end
