defmodule SportywebWeb.LoanLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Rental
  alias Sportyweb.Asset
  alias Sportyweb.Personal

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.card>
      <%= if @article.units do %>
        <%= if Enum.any?(@article.units, &(&1.occupied == false && &1.for_lending == true)) do %>
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
                  field={@form[:loan_date]}
                  type="date"
                  label="Ausleihdatum"
                  phx-change="update_return_date"
                />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input
                field={@form[:return_date]}
                type="date"
                label="Rückgabedatum"
                disabled={@return_date_locked?}
                />

                <%= if @return_date_locked? do %>
                  <input
                    type="hidden"
                    name={@form[:return_date].name}
                    value={@form[:return_date].value}
                  />
                <% end %>
              </div>
 <div class="col-span-12 md:col-span-6">
  <.input
    field={@form[:contact_id]}
    type="select"
    label="Kontakt"
    options={
      cond do
        @article.for_non_members ->
          @non_member_contact_options |> Enum.map(&{&1.name, &1.id})

        @article.for_club_members ->
          @member_contact_options |> Enum.map(&{&1.name, &1.id})

        true ->
          @contact_options |> Enum.map(&{&1.name, &1.id})
      end
    }
    prompt="Bitte auswählen"
    phx-change="update_rental_fee_options"
  />
</div>
              <div class="col-span-12 md:col-span-6">
              <.input
                  field={@form[:rental_fee_id]}
                  type="select"
                  label="Mietgebühr"
                  options={@rental_fee_options |> Enum.map(&{&1.name, &1.id})}
                  prompt="Bitte auswählen"
                />
              </div>

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


            </.input_grid>
          </.input_grids>

          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
            </div>
          </:actions>
        </.simple_form>
        <% else %>
          <p>Es ist derzeit keine Einheit dieses Artikels zur Ausleihe verfügbar.</p>
        <% end %>
      <% else %>
        <p>Der Artikel hat keine zugewiesene Einheit und kann daher nicht ausgeliehen werden. Bitte weisen Sie dem Artikel zuerst eine Einheit zu.</p>
      <% end %>
      </.card>
    </div>
    """
  end

  @impl true
  def update(%{loan: loan} = assigns, socket) do
    return_date=Rental.calculate_return_date(assigns.article.id, loan.loan_date)

    loan =
      if return_date do
        %{loan | return_date: return_date}
      else
        loan
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:return_date_locked?, not is_nil(return_date))
     |> assign(:non_member_contact_options, Personal.list_contacts(assigns.club.id))
     |> assign(:member_contact_options, Personal.list_members(assigns.club.id))
     |> assign(:contact_options, Personal.list_contracts(assigns.article.id, assigns.club.id))
     |> assign(:location_options, Asset.list_locations_with_units(assigns.club.id, assigns.article.id))
     |> assign_new(:form, fn ->
       to_form(Rental.change_loan(loan))
     end)
     |> assign_rental_fee_options(nil)
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

  def handle_event("update_rental_fee_options", %{"loan" => %{"contact_id" => contact_id}}, socket) do
    IO.inspect(contact_id, label: "contact_id")
    IO.inspect("EVENT!")
    IO.inspect(contact_id)
    {:noreply, assign_rental_fee_options(socket, contact_id)}
  end
  @impl true
  def handle_event("update_unit_options", %{"loan" => %{"location_id" => location_id}}, socket) do
    {:noreply, assign_unit_options(socket, location_id)}
  end

  def handle_event("update_return_date", %{"loan" => %{"loan_date" => loan_date} = loan_params}, socket) do
    {:noreply, assign_return_date(socket, loan_date, loan_params)}
  end

  defp save_loan(socket, :edit, loan_params) do
    case Rental.update_loan(socket.assigns.loan, loan_params) do
      {:ok, _loan} ->
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
      {:ok, %{loan: _loan}} ->
        {:noreply,
         socket
         |> put_flash(:info, "Die Ausleihe wurde erfolgreich angelegt.")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, :loan, %Ecto.Changeset{} = changeset, _changes} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, :unit, %Ecto.Changeset{} = _changeset, _changes} ->
        {:noreply,
        socket
        |> put_flash(:error, "Die ausgewählte Einheit konnte nicht als belegt markiert werden.")}
    end
  end

  defp assign_unit_options(socket, location_id) do
    assign(
      socket,
      :unit_options,
      Rental.list_available_units(socket.assigns.loan.article_id, location_id)
    )
  end

  defp assign_rental_fee_options(socket, contact_id) do
    assign(
      socket,
      :rental_fee_options,
      Rental.list_belonging_rental_fees(socket.assigns.loan.article_id, contact_id)
    )
  end



  defp assign_return_date(socket, loan_date, loan_params) do
    loan_params =
      case Date.from_iso8601(loan_date) do
        {:ok, loan_date} ->
          case Rental.calculate_return_date(socket.assigns.article.id, loan_date) do
            nil ->
              loan_params
            return_date ->
              Map.put(loan_params, "return_date", Date.to_iso8601(return_date))
          end
        _ ->
          loan_params
      end
      changeset = Rental.change_loan(socket.assigns.loan, loan_params)
      assign(socket, form: to_form(changeset, action: :validate))
  end
end
