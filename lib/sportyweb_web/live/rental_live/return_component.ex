defmodule SportywebWeb.RentalLive.ReturnComponent do
  use SportywebWeb, :live_component
  use Ecto.Schema
  alias Sportyweb.Inventory.ReturnForm

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
        <.input
          field={@form[:condition_status]}
          type="select"
          label="Zustand bei Rückgabe"
          options={[
            {"In Ordnung", "ok"},
            {"Beschädigt", "damaged"},
            {"Verloren", "lost"}
          ]}
        />

        <.input field={@form[:condition_note]} type="textarea" label="Bemerkung zum Zustand" />
        <.button>Ausleihe zurückgeben</.button>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{rental: rental} = assigns, socket) do
    changeset = ReturnForm.changeset(%ReturnForm{condition_status: "ok"})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset, as: :rental))}
  end

  @impl true
  def handle_event("validate", %{"rental" => rental_params}, socket) do
    changeset =
      %ReturnForm{}
      |> ReturnForm.changeset(rental_params)

    {:noreply, assign(socket, form: to_form(changeset, as: :rental, action: :validate))}
  end

  def handle_event("save", %{"rental" => rental_params}, socket) do
    case Inventory.return_rental(socket.assigns.rental, rental_params) do
      {:ok, changes} ->
        # Optional prüfen:
        # Map.has_key?(changes, :old_rental)
        # Map.has_key?(changes, :unit)

        {:noreply,
         socket
         |> put_flash(:info, "Ausleihe erfolgreich zurückgegeben")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, :unit, _changeset, _changes} ->
        form = ReturnForm.changeset(%ReturnForm{}, rental_params)

        {:noreply,
         socket
         |> put_flash(:error, "Der Zustand der Einheit konnte nicht aktualisiert werden.")
         |> assign(:form, to_form(form, as: :rental))}

      {:error, :old_rental, _changeset, _changes} ->
        form = ReturnForm.changeset(%ReturnForm{}, rental_params)

        {:noreply,
         socket
         |> put_flash(:error, "Die Ausleihe konnte nicht archiviert werden.")
         |> assign(:form, to_form(form, as: :rental))}

      {:error, :rental, _changeset, _changes} ->
        form = ReturnForm.changeset(%ReturnForm{}, rental_params)

        {:noreply,
         socket
         |> put_flash(:error, "Die Ausleihe konnte nicht zurückgegeben werden.")
         |> assign(:form, to_form(form, as: :rental))}
    end
  end
end
