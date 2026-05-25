defmodule SportywebWeb.LoanLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Rental

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage loan records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="loan-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:loan_number]} type="text" label="Loan number" />
        <.input field={@form[:serial_number]} type="number" label="Anlagennummer" />
        <%= if Enum.any?(@location_options) do %>
          <div class="col-span-12">
            <.input
              field={@form[:article_id]}
              type="select"
              label="Artikel"
              options={@article_options |> Enum.map(&{&1.name, &1.id})}
              prompt="Bitte Artikel auswählen"
            />
          </div>
        <% end %>
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
        <.input field={@form[:return_date]} type="date" label="Return date" />
        <:actions>
          <div>
            <.button phx-disable-with="Speichern...">Speichern</.button>
            <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
          </div>
          <.button
            :if={@loan.id}
            class="bg-rose-700 hover:bg-rose-800"
            phx-click={JS.push("delete", value: %{id: @loan.id})}
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
  def update(%{loan: loan} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Rental.change_loan(loan))
     end)}
  end

  @impl true
  def handle_event("validate", %{"loan" => loan_params}, socket) do
    changeset = Rental.change_loan(socket.assigns.loan, loan_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"loan" => loan_params}, socket) do
    save_loan(socket, socket.assigns.action, loan_params)
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
        "club_id" => socket.assigns.loan.club.id
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
end
