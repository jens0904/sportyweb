defmodule SportywebWeb.RentalFeeLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Inventory
  alias Sportyweb.Inventory.RentalFee

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.RentalFeeLive.FormComponent}
        id={@rental_fee.id || :new}
        title={@page_title}
        action={@live_action}
        rental_fee={@rental_fee}
        club={@club}
        navigate={
          if @rental_fee.id,
            do: ~p"/rental_fees/#{@rental_fee}",
            else: ~p"/clubs/#{@club}/rental_fees"
        }
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :rental_fees)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    rental_fee = Inventory.get_rental_fee!(id, [:category, :article, :club])

    socket
    |> assign(:page_title, "Mietgebühr bearbeiten")
    |> assign(:rental_fee, rental_fee)
    |> assign(:article, rental_fee.article)
    |> assign(:club, rental_fee.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id, [:categories, :articles])

    socket
    |> assign(:page_title, "Mietgebühr anlegen")
    |> assign(:rental_fee, %RentalFee{
      club_id: club.id,
      club: club
    })
    |> assign(:club, club)
  end

  @impl true
  def handle_event("archive", %{"id" => id}, socket) do
    rental_fee = Inventory.get_rental_fee!(id)

    case Inventory.archive_rental_fee(rental_fee) do
      {:ok, _rental_rule} ->
        {:noreply,
         socket
         |> put_flash(:info, "Mietgebühr wurde archiviert.")
         |> push_navigate(to: "/clubs/#{rental_fee.club_id}/rental_fees")}

      {:error, :rental_fee_has_active_rentals} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           "Die Mietgebühr kann nicht archiviert werden, solange aktive Vermietungen vorhanden sind."
         )}
    end
  end
end
