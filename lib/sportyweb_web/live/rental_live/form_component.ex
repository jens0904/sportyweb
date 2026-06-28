defmodule SportywebWeb.RentalLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Inventory
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
      <%= cond do %>
        <% is_nil(@rental_rule) -> %>
          <p>
            Für diesen Artikel oder dessen Kategorie wurde noch keine Ausleihregel definiert.
            Bitte legen Sie zuerst eine passende Ausleihregel an.
          </p>

      <% !@article.units -> %>
        <p>
          Der Artikel hat keine zugewiesene Einheit und kann daher nicht ausgeliehen werden.
          Bitte weisen Sie dem Artikel zuerst eine Einheit zu.
        </p>

      <% !Enum.any?(@article.units, &(&1.occupied == false && &1.for_lending == true)) -> %>
        <p>Es ist derzeit keine Einheit dieses Artikels zur Ausleihe verfügbar.</p>

      <% true -> %>
            <.simple_form
              for={@form}
              id="rental-form"
              phx-target={@myself}
              phx-change="validate"
              phx-submit="save"
            >
              <.input_grids>
                <.input_grid>
                  <div class="col-span-12 md:col-span-6">
                    <.input
                      field={@form[:rental_date]}
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
                      options={@contact_options |> Enum.map(&{&1.name, &1.id})}
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
        <% end %>
      </.card>
    </div>
    """
  end

  @impl true
  def update(%{rental: rental} = assigns, socket) do
    rental_rule = Inventory.get_applicable_rental_rule(assigns.article.id)

    return_date =
      Inventory.calculate_return_date(assigns.article.id, rental.rental_date)

    rental =
      if return_date do
        %{rental | return_date: return_date}
      else
        rental
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:rental_rule, rental_rule)
     |> assign(:return_date_locked?, not is_nil(return_date))
     |> assign(:contact_options, contact_options(assigns.club.id, assigns.article.id, rental_rule))
     |> assign(:location_options, Asset.list_locations_with_units(assigns.club.id, assigns.article.id))
     |> assign_new(:form, fn ->
       to_form(Inventory.change_rental(rental))
     end)
     |> assign_rental_fee_options(nil)
     |> assign_unit_options(nil)}
  end

  @impl true
  def handle_event("validate", %{"rental" => rental_params}, socket) do
    changeset =
      Inventory.change_rental(socket.assigns.rental, rental_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"rental" => rental_params}, socket) do
    save_rental(socket, socket.assigns.action, rental_params)
  end

  def handle_event("update_rental_fee_options", %{"rental" => %{"contact_id" => contact_id}}, socket) do
    {:noreply, assign_rental_fee_options(socket, contact_id)}
  end

  @impl true
  def handle_event("update_unit_options", %{"rental" => %{"location_id" => location_id}}, socket) do
    {:noreply, assign_unit_options(socket, location_id)}
  end

  def handle_event("update_return_date", %{"rental" => %{"rental_date" => rental_date} = rental_params}, socket) do
    {:noreply, assign_return_date(socket, rental_date, rental_params)}
  end

  defp save_rental(socket, :edit, rental_params) do
    case Inventory.update_rental(socket.assigns.rental, rental_params) do
      {:ok, _rental} ->
        {:noreply,
         socket
         |> put_flash(:info, "Rental updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_rental(socket, :new, rental_params) do
    rental_params =
      Enum.into(rental_params, %{
        "article_id" => socket.assigns.rental.article.id
      })

    case Inventory.create_rental(rental_params) do
      {:ok, %{rental: _rental}} ->
        {:noreply,
         socket
         |> put_flash(:info, "Die Ausleihe wurde erfolgreich angelegt.")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, :rental, %Ecto.Changeset{} = changeset, _changes} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, :unit, %Ecto.Changeset{}, _changes} ->
        {:noreply,
         socket
         |> put_flash(:error, "Die ausgewählte Einheit konnte nicht als belegt markiert werden.")}
    end
  end

  defp contact_options(club_id, article_id, nil) do
    Personal.list_contracts(article_id, club_id)
  end

  defp contact_options(club_id, _article_id, %{for_club_members: true, for_non_members: false}) do
    Personal.list_members(club_id)
  end

  defp contact_options(club_id, _article_id, %{for_club_members: false, for_non_members: true}) do
    Personal.list_contacts(club_id)
  end

  defp contact_options(club_id, article_id, %{for_club_members: true, for_non_members: true}) do
    Personal.list_contacts(club_id)
  end

  defp contact_options(club_id, article_id, _rental_rule) do
    Personal.list_contracts(article_id, club_id)
  end

  defp assign_unit_options(socket, location_id) do
    assign(
      socket,
      :unit_options,
      Inventory.list_available_units(socket.assigns.rental.article_id, location_id)
    )
  end

  defp assign_rental_fee_options(socket, contact_id) do
    assign(
      socket,
      :rental_fee_options,
      Inventory.list_belonging_rental_fees(socket.assigns.rental.article_id, contact_id)
    )
  end

  defp assign_return_date(socket, rental_date, rental_params) do
    rental_params =
      case Date.from_iso8601(rental_date) do
        {:ok, rental_date} ->
          case Inventory.calculate_return_date(socket.assigns.article.id, rental_date) do
            nil -> rental_params
            return_date -> Map.put(rental_params, "return_date", Date.to_iso8601(return_date))
          end

        _ ->
          rental_params
      end

    changeset = Inventory.change_rental(socket.assigns.rental, rental_params)
    assign(socket, form: to_form(changeset, action: :validate))
  end
end
