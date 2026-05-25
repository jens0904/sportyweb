defmodule SportywebWeb.UnitLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Asset
  alias Sportyweb.Rental

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage unit records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="unit-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:serial_number]} type="number" label="Anlagennummer" />
        <%= if Enum.any?(@location_options) do %>
          <div class="col-span-12">
            <.input
              field={@form[:location_id]}
              type="select"
              label="Standort"
              options={@location_options |> Enum.map(&{&1.name, &1.id})}
              prompt="Bitte Standort auswählen"
            />
          </div>
        <% end %>
        <.input field={@form[:for_lending]} type="checkbox" label="ausleihbar" />
        <.input field={@form[:for_booking]} type="checkbox" label="reservierbar" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Unit</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{unit: unit} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:location_options, Asset.list_locations(assigns.club.id))
     |> assign_new(:form, fn ->
       to_form(Rental.change_unit(unit))
     end)}
  end

  @impl true
  def handle_event("validate", %{"unit" => unit_params}, socket) do
    changeset = Rental.change_unit(socket.assigns.unit, unit_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"unit" => unit_params}, socket) do
    save_unit(socket, socket.assigns.action, unit_params)
  end

  defp save_unit(socket, :edit, unit_params) do
    case Rental.update_unit(socket.assigns.unit, unit_params) do
      {:ok, unit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Unit updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_unit(socket, :new, unit_params) do
    unit_params =
      Enum.into(unit_params, %{
        "article_id" => socket.assigns.unit.article.id
      })

    case Rental.create_unit(unit_params) do
      {:ok, unit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Unit created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
