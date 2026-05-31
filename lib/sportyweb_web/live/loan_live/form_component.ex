defmodule SportywebWeb.LoanLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Rental
  alias Sportyweb.Asset

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.card>
        <.simple_form
          for={@form}
          id="loan-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input_grids>
            <.input_grid>
              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:location_id]}
                  type="select"
                  label="Standort"
                  options={@location_options |> Enum.map(&{&1.name, &1.id})}
                  prompt="Bitte auswählen"
                  phx-change="update_unit_options"
                />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:unit_id]}
                  type="select"
                  label="Einheit"
                  options={@unit_options |> Enum.map(&{&1.serial_number, &1.id})}
                  prompt="Bitte auswählen"
                />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:return_date]} type="date" label="Rückgabedatum" />
              </div>
            </.input_grid>
          </.input_grids>

          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
            </div>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  @impl true
  def update(%{loan: loan} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:location_options, Asset.list_locations(assigns.club.id))
     |> assign_new(:form, fn ->
       to_form(Rental.change_loan(loan))
     end)
     |> assign_unit_options(nil)}
  end

  @impl true
  def handle_event("validate", %{"loan" => loan_params}, socket) do
    changeset =
      Rental.change_loan(socket.assigns.loan, loan_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"loan" => loan_params}, socket) do
    save_loan(socket, socket.assigns.action, loan_params)
  end

  @impl true
  def handle_event("update_unit_options", %{"loan" => %{"location_id" => location_id}}, socket) do
    {:noreply, assign_unit_options(socket, location_id)}
  end

  defp save_loan(socket, :edit, loan_params) do
    case Rental.update_loan(socket.assigns.loan, loan_params) do
      {:ok, loan} ->
        {:noreply,
         socket
         |> put_flash(:info, "Loan updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_loan(socket, :new, loan_params) do
    loan_params =
      Enum.into(loan_params, %{
        "article_id" => socket.assigns.loan.article.id
      })

    case Rental.create_loan(loan_params) do
      {:ok, loan} ->
        {:noreply,
         socket
         |> put_flash(:info, "Loan created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp assign_unit_options(socket, location_id) do
    assign(
      socket,
      :unit_options,
      Rental.list_available_units(socket.assigns.loan_object, location_id)
    )
  end
end
