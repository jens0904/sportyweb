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
                      type="datetime-local"
                      label="Ausleihdatum"
                      disabled
                    />

                    <input
                      type="hidden"
                      name={@form[:rental_date].name}
                      value={@form[:rental_date].value}
                    />
                  </div>

<div class="col-span-12 md:col-span-6">
  <%= if @rental_rule.rental_period_unit == "Stunden" do %>
    <label for="rental_return_time" class="block text-sm font-semibold leading-6 text-zinc-800">
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
  <option value={time} selected={@return_time == time}>{time}</option>
<% end %>
    </select>
  <% else %>
    <.input
      field={@form[:return_date]}
      type="date"
      label="Rückgabedatum"
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
  @spec handle_event(<<_::32, _::_*8>>, map(), any()) :: {:noreply, any()}
  def handle_event("validate", %{"rental" => rental_params}, socket) do
    return_time = Map.get(rental_params, "return_time")

    rental_params =
      normalize_rental_datetimes(rental_params, socket.assigns.rental_rule)

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

  def handle_event("update_rental_fee_options", %{"rental" => %{"contact_id" => contact_id}}, socket) do
    {:noreply, assign_rental_fee_options(socket, contact_id)}
  end

  @impl true
  def handle_event("update_unit_options", %{"rental" => %{"location_id" => location_id}}, socket) do
    {:noreply, assign_unit_options(socket, location_id)}
  end

  defp normalize_rental_datetimes(params, rental_rule) do
  if rental_rule.rental_period_unit == "Stunden" do
    params
    |> normalize_datetime_local("rental_date")
    |> put_return_date_from_time()
  else
    params
    |> normalize_datetime_local("rental_date")
    |> normalize_date_to_datetime("return_date")
  end
end

defp put_return_date_from_time(params) do
  with rental_date when is_binary(rental_date) <- Map.get(params, "rental_date"),
       return_time when is_binary(return_time) <- Map.get(params, "return_time"),
       {:ok, rental_datetime, _} <- DateTime.from_iso8601(rental_date),
       {:ok, time} <- Time.from_iso8601(return_time <> ":00") do
    return_datetime =
      DateTime.new!(DateTime.to_date(rental_datetime), time, "Etc/UTC")

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
          Map.put(
            params,
            field,
            DateTime.new!(date, ~T[00:00:00], "Etc/UTC") |> DateTime.to_iso8601()
          )

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
          Map.put(params, field, DateTime.from_naive!(naive, "Etc/UTC") |> DateTime.to_iso8601())

        _ ->
          params
      end

    _ ->
      params
  end
end

  defp save_rental(socket, :edit, rental_params) do
    rental_params =
      rental_params
      |> normalize_rental_datetimes(socket.assigns.rental_rule)

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

  defp contact_options(club_id, _article_id, %{for_club_members: true, for_non_members: true}) do
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


end
