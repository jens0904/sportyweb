defmodule SportywebWeb.RentalLive.RenewComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Inventory

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>
      <.card>
      <%= if @rental_rule.allow_renewal do %>
        <%= if @rental.renewal_count < @article.max_renewals do %>
            <.simple_form
              for={@form}
              id="rental-renew-form"
              phx-target={@myself}
              phx-change="validate"
              phx-submit="save"
          >
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
                      <label for="rental_return_date" class="block text-sm font-semibold leading-6 text-zinc-800">
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

            <.button type="submit" class="mt-4">
              Verlängern
            </.button>
          </.simple_form>
        <% else %>
          <p>Die maximale Anzahl an Verlängerungen wurde bereits erreicht.</p>
        <% end %>
      <% else %>
        <p>Eine Verlängerung für den Artikel ist nicht erlaubt.</p>
      <% end %>
      </.card>
    </div>
    """
  end

  @impl true
  def update(%{rental: rental} = assigns, socket) do
    rental_rule = Inventory.get_applicable_rental_rule(assigns.article.id)
    return_date = Inventory.calculate_new_return_date(rental, assigns.article.id)

    changeset = Inventory.change_rental(rental, %{"return_date" => return_date})
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:return_time, nil)
     |> assign(:rental_rule, rental_rule)
     |> assign(:form, to_form(changeset))
     |> assign(:return_date, return_date)}
  end

  @impl true
  def handle_event("validate", %{"rental" => rental_params}, socket) do
    changeset = Inventory.change_rental(socket.assigns.rental, rental_params)

      {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"rental" => rental_params}, socket) do
    rental_params = normalize_return_date(rental_params)

    case Inventory.renew_rental(socket.assigns.rental, rental_params) do
      {:ok, rental} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ausleihe erfolgreich verlängert.")
         |> push_navigate(to: ~p"/rentals/#{rental}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end

  defp normalize_return_date(params) do
    case Map.get(params, "return_date") do
      value when is_binary(value) ->
        case Date.from_iso8601(value) do
          {:ok, date} ->
            Map.put(params, "return_date", DateTime.new!(date, ~T[00:00:00], "Etc/UTC"))

          _ ->
            params
        end

      _ ->
        params
    end
  end

  defp format_date_input_value(%Date{} = date), do: Date.to_iso8601(date)

  defp format_date_input_value(value) when is_binary(value), do: String.slice(value, 0, 10)

  defp format_date_input_value(_value), do: ""


end
