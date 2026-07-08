defmodule SportywebWeb.RentalLive.ReturnComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Inventory
  alias Sportyweb.Inventory.Rental

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
          options={Rental.get_condition_statuses() |> Enum.map(&{&1[:key], &1[:value]})}
        />

        <.input
          field={@form[:condition_note]}
          type="textarea"
          label="Bemerkung zum Zustand"
        />

        <.button>Ausleihe zurückgeben</.button>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{rental: rental} = assigns, socket) do
    changeset =
      Rental.return_changeset(rental, %{
        "condition_status" => rental.condition_status || "ok"
      })

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset, as: :rental))}
  end

  @impl true
  def handle_event("validate", %{"rental" => rental_params}, socket) do
    changeset =
      socket.assigns.rental
      |> Rental.return_changeset(rental_params)
      |> Map.put(:action, :validate)

    {:noreply,
     assign(socket, :form, to_form(changeset, as: :rental))}
  end

  @impl true
  def handle_event("save", %{"rental" => rental_params}, socket) do
    case Inventory.return_rental(socket.assigns.rental, rental_params) do
      {:ok, _changes} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ausleihe erfolgreich zurückgegeben")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, :unit, _changeset, _changes} ->
        changeset =
          Rental.return_changeset(socket.assigns.rental, rental_params)

        {:noreply,
         socket
         |> put_flash(:error, "Der Zustand der Einheit konnte nicht aktualisiert werden.")
         |> assign(:form, to_form(changeset, as: :rental))}

      {:error, :rental, changeset, _changes} ->
        {:noreply,
         socket
         |> put_flash(:error, "Die Ausleihe konnte nicht zurückgegeben werden.")
         |> assign(:form, to_form(changeset, as: :rental))}
    end
  end
end
