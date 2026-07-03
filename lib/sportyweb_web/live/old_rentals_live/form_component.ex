defmodule SportywebWeb.OldRentalsLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Inventory

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage old_rentals records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="old_rentals-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />

        <:actions>
          <.button phx-disable-with="Saving...">
            Speichern
          </.button>

          <.cancel_button navigate={@navigate}>
            Abbrechen
          </.cancel_button>

          <.button
            :if={@old_rentals.id}
            class="bg-rose-700 hover:bg-rose-800"
            phx-click={JS.push("delete", value: %{id: @old_rentals.id})}
            data-confirm="Unwiderruflich löschen?"
          >
            Löschen
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{old_rentals: old_rentals} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Inventory.change_old_rentals(old_rentals))
     end)}
  end

  @impl true
  def handle_event("validate", %{"old_rentals" => old_rentals_params}, socket) do
    changeset =
      Inventory.change_old_rentals(
        socket.assigns.old_rentals,
        old_rentals_params
      )

    {:noreply,
     assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"old_rentals" => old_rentals_params}, socket) do
    save_old_rentals(socket, socket.assigns.action, old_rentals_params)
  end

  defp save_old_rentals(socket, :edit, old_rentals_params) do
    case Inventory.update_old_rentals(
           socket.assigns.old_rentals,
           old_rentals_params
         ) do
      {:ok, _old_rentals} ->
        {:noreply,
         socket
         |> put_flash(:info, "Old rentals updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         assign(socket, form: to_form(changeset))}
    end
  end

  defp save_old_rentals(socket, :new, old_rentals_params) do
    case Inventory.create_old_rentals(old_rentals_params) do
      {:ok, _old_rentals} ->
        {:noreply,
         socket
         |> put_flash(:info, "Old rentals created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         assign(socket, form: to_form(changeset))}
    end
  end
end
