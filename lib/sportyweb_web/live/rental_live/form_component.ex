defmodule SportywebWeb.RentalLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Asset
  alias Sportyweb.Inventory
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
                      type="datetime-local"
                      label="Ausleihdatum"
                      disabled
                    />

                    <input
                      type="hidden"
                      name={@form[:rental_date].name}
                      value={format_datetime_local_value(@form[:rental_date].value)}
                    />
                  </div>

                  <div class="col-span-12 md:col-span-6">
                    <%= if @rental_rule.rental_period_unit == "Stunden" do %>
                      <label
                        for="rental_return_time"
                        class="block text-sm font-semibold leading-6 text-zinc-800"
                      >
                        Rückgabezeit
                      </label>

                      <select
                        id="rental_return_time"
                        name="rental[return_time]"
                        class="mt-2 block w-full rounded-lg border-zinc-300 text-zinc-900 focus:border-zinc-400 focus:ring-0 sm:text-sm sm:leading-6"
                      >
                        <option value="">Bitte auswählen</option>

                        <%= for hour <- 8..22 do %>
                          <% time = String.pad_leading(Integer.to_string(hour), 2, "0") <> ":00" %>
                          <option value={time} selected={@return_time == time}>
                            {time}
                          </option>
                        <% end %>
                      </select>

                      <%= for error <- @form[:return_date].errors do %>
                        <p class="mt-2 text-sm text-rose-600">
                          {translate_error(error)}
                        </p>
                      <% end %>
                    <% else %>
                      <label
                        for="rental_return_date"
                        class="block text-sm font-semibold leading-6 text-zinc-800"
                      >
                        Rückgabedatum
                      </label>

                      <input
                        id="rental_return_date"
                        name={@form[:return_date].name}
                        type="date"
                        value={format_date_input_value(@form[:return_date].value)}
                        class="mt-2 block w-full rounded-lg border-zinc-300 text-zinc-900 focus:border-zinc-400 focus:ring-0 sm:text-sm sm:leading-6"
                      />

                      <%= for error <- @form[:return_date].errors do %>
                        <p class="mt-2 text-sm text-rose-600">
                          {translate_error(error)}
                        </p>
                      <% end %>
                    <% end %>
                  </div>

                  <div class="col-span-12 md:col-span-6">
                    <.input
                      field={@form[:contact_id]}
                      type="select"
                      label="Kontakt"
                      options={Enum.map(@contact_options, &{&1.name, &1.id})}
                      prompt="Bitte auswählen"
                      phx-change="update_rental_fee_options"
                    />
                  </div>

                  <div class="col-span-12 md:col-span-6">
                    <.input
                      field={@form[:rental_fee_id]}
                      type="select"
                      label="Gebühr"
                      options={Enum.map(@rental_fee_options, &rental_fee_option_label/1)}
                      prompt="Bitte auswählen"
                    />
                  </div>

                  <div class="col-span-12 md:col-span-6">
                    <.input
                      field={@form[:location_id]}
                      type="select"
                      label="Standort"
                      options={Enum.map(@location_options, &{&1.name, &1.id})}
                      prompt="Bitte auswählen"
                      phx-change="update_unit_options"
                    />
                  </div>

                  <div class="col-span-12 md:col-span-6">
                    <.input
                      field={@form[:unit_id]}
                      type="select"
                      label="Einheit"
                      options={Enum.map(@unit_options, &{&1.serial_number, &1.id})}
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
    IO.inspect(assigns.article.id, label: "ARTICLE ID")
    IO.inspect(rental_rule, label: "APPLICABLE RENTAL RULE")

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:return_time, nil)
     |> assign(:rental_rule, rental_rule)
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
    IO.inspect(rental_params, label: "VALIDATE PARAMS")
    return_time = Map.get(rental_params, "return_time")

    rental_params =
      rental_params
      |> Enum.into(%{"article_id" => socket.assigns.rental.article.id})
      |> normalize_rental_datetimes(socket.assigns.rental_rule)

    changeset =
      Inventory.change_rental(socket.assigns.rental, rental_params)

    {:noreply,
     socket
     |> assign(:return_time, return_time)
     |> assign(form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"rental" => rental_params}, socket) do
    save_rental(socket, socket.assigns.action, rental_params)
  end

  def handle_event(
        "update_rental_fee_options",
        %{"rental" => %{"contact_id" => contact_id}},
        socket
      ) do
    {:noreply, assign_rental_fee_options(socket, contact_id)}
  end

  @impl true
  def handle_event("update_unit_options", %{"rental" => %{"location_id" => location_id}}, socket) do
    {:noreply, assign_unit_options(socket, location_id)}
  end

  defp save_rental(socket, :edit, rental_params) do
    rental_params =
      normalize_rental_datetimes(rental_params, socket.assigns.rental_rule)

    case Inventory.update_rental(socket.assigns.rental, rental_params) do
      {:ok, _rental} ->
        {:noreply,
         socket
         |> put_flash(:info, "Rental updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end

  defp save_rental(socket, :new, rental_params) do
    rental_params =
      rental_params
      |> normalize_rental_datetimes(socket.assigns.rental_rule)
      |> Enum.into(%{
        "article_id" => socket.assigns.rental.article.id
      })

    case Inventory.create_rental(rental_params) do
      {:ok, %{rental: _rental}} ->
        {:noreply,
         socket
         |> put_flash(:info, "Die Ausleihe wurde erfolgreich angelegt.")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, :rental, %Ecto.Changeset{} = changeset, _changes} ->
        IO.inspect(changeset.errors, label: "RENTAL ERRORS")
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}

      {:error, :unit, %Ecto.Changeset{}, _changes} ->
        {:noreply,
         socket
         |> put_flash(:error, "Die ausgewählte Einheit konnte nicht als belegt markiert werden.")}

        {:noreply,
         socket
         |> put_flash(:error, "Die Ausleihe konnte nicht gespeichert werden.")}
    end
  end

  defp normalize_rental_datetimes(params, rental_rule) do
    case rental_rule.rental_period_unit do
      "Stunden" ->
        params
        |> normalize_datetime_local("rental_date")
        |> put_return_date_from_time()

      _ ->
        params
        |> normalize_datetime_local("rental_date")
        |> normalize_date_to_datetime("return_date")
    end
  end

  defp put_return_date_from_time(params) do
    with rental_date when is_binary(rental_date) <- Map.get(params, "rental_date"),
         return_time when is_binary(return_time) <- Map.get(params, "return_time"),
         {:ok, rental_datetime, _offset} <- DateTime.from_iso8601(rental_date),
         {:ok, time} <- Time.from_iso8601(return_time <> ":00") do
      return_datetime =
        rental_datetime
        |> DateTime.to_date()
        |> DateTime.new!(time, "Etc/UTC")

      Map.put(params, "return_date", DateTime.to_iso8601(return_datetime))
    else
      _ -> params
    end
  end

  defp normalize_date_to_datetime(params, field) do
    case Map.get(params, field) do
      value when is_binary(value) ->
        case Date.from_iso8601(value) do
          {:ok, date} ->
            datetime =
              date
              |> DateTime.new!(~T[00:00:00], "Etc/UTC")
              |> DateTime.to_iso8601()

            Map.put(params, field, datetime)

          _ ->
            params
        end

      _ ->
        params
    end
  end

  defp normalize_datetime_local(params, field) do
    case Map.get(params, field) do
      value when is_binary(value) ->
        value =
          if String.length(value) == 16 do
            value <> ":00"
          else
            value
          end

        case NaiveDateTime.from_iso8601(value) do
          {:ok, naive} ->
            datetime =
              naive
              |> DateTime.from_naive!("Etc/UTC")
              |> DateTime.to_iso8601()

            Map.put(params, field, datetime)

          _ ->
            params
        end

      _ ->
        params
    end
  end

  defp format_datetime_local_value(%DateTime{} = datetime) do
    Calendar.strftime(datetime, "%Y-%m-%dT%H:%M")
  end

  defp format_datetime_local_value(value) when is_binary(value) do
    String.slice(value, 0, 16)
  end

  defp format_datetime_local_value(_value), do: ""

  defp contact_options(club_id, article_id, nil) do
    Personal.list_contracts(article_id, club_id)
  end

  defp contact_options(club_id, _article_id, %{
         for_club_members: true,
         for_non_members: false
       }) do
    Personal.list_members(club_id)
  end

  defp contact_options(club_id, _article_id, %{
         for_club_members: false,
         for_non_members: true
       }) do
    Personal.list_contacts(club_id)
  end

  defp contact_options(club_id, _article_id, %{
         for_club_members: true,
         for_non_members: true
       }) do
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

  defp format_date_input_value(%DateTime{} = datetime) do
    datetime
    |> DateTime.to_date()
    |> Date.to_iso8601()
  end

  defp format_date_input_value(%Date{} = date), do: Date.to_iso8601(date)

  defp format_date_input_value(value) when is_binary(value), do: String.slice(value, 0, 10)

  defp format_date_input_value(_value), do: ""

  defp rental_fee_option_label(rental_fee) do
    IO.inspect(rental_fee, label: "RENTAL FEE")

    target =
      cond do
        rental_fee.category -> "Kategorie: #{rental_fee.category.name}"
        rental_fee.article -> "Artikel: #{rental_fee.article.name}"
        true -> "Ohne Zuordnung"
      end

    amount =
    case Money.to_string(rental_fee.amount) do
      {:ok, formatted_amount} -> formatted_amount
      formatted_amount when is_binary(formatted_amount) -> formatted_amount
      _ -> ""
    end
    {"#{rental_fee.name} – #{amount} € – #{target}", rental_fee.id}
  end
end
