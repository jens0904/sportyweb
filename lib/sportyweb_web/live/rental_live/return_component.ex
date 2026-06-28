defmodule SportywebWeb.RentalLive.ReturnComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Inventory


  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="rental-return-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:return_comment]} type="textarea" label="Kommentar" />
        <.button>Ausleihe zurückgeben</.button>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{rental: rental} = assigns, socket) do
    changeset = Inventory.change_rental(rental)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"rental" => rental_params}, socket) do
    changeset = Inventory.change_rental(socket.assigns.rental, rental_params)

      {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"rental" => rental_params}, socket) do
    case Inventory.return_rental(socket.assigns.rental, rental_params) do
      {:ok, %{rental: _rental}} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ausleihe erfolgreich zurückgegeben")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, :rental, %Ecto.Changeset{} = changeset, _changes} ->
        {:noreply, assign(socket, :form, to_form(changeset))}

      {:error, :unit, %Ecto.Changeset{} = _changeset, _changes} ->
        {:noreply,
        socket
        |> put_flash(:error, "Fehler beim Zurückgeben der Ausleihe.")}
    end
  end
end
