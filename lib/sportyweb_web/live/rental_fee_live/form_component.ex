defmodule SportywebWeb.RentalFeeLive.FormComponent do
  use SportywebWeb, :live_component
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Inventory
  alias Sportyweb.Inventory.Category
  alias Sportyweb.Inventory.Article

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
          id="rental_fee-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input_grids>
            <.input_grid>
              <.input
                field={@form[:scope]}
                type="select"
                label="Gilt für"
                options={[
                  {"Gesamten Verein", "club"},
                  {"Kategorie", "category"},
                  {"Artikel", "article"}
                ]}
              />

              <%= case @form[:scope].value do %>
                <% "category" -> %>
                  <.input
                    field={@form[:category_id]}
                    type="select"
                    label="Kategorie"
                    options={Enum.map(@category_options, &{&1.name, &1.id})}
                    prompt="Kategorie auswählen"
                  />
                <% "article" -> %>
                  <.input
                    field={@form[:article_id]}
                    type="select"
                    label="Artikel"
                    options={Enum.map(@article_options, &{&1.name, &1.id})}
                    prompt="Artikel auswählen"
                  />
                <% _ -> %>
              <% end %>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:name]} type="text" label="Name" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:member_type]}
                  type="select"
                  label="Für wen gilt die Gebühr?"
                  prompt="Bitte auswählen"
                  options={[{"Mitglieder", :member}, {"Nichtmitglieder", :non_member}]}
                />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:rental_duration]}
                  type="select"
                  label="Für welche Mietdauer?"
                  prompt="Bitte auswählen"
                  options={[
                    {"Kurzfristige Vermietungen", :short_term},
                    {"Langfristige Vermietungen", :long_term}
                  ]}
                />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:amount]} type="text" label="Grundbetrag in Euro" />
                <.input_description>
                  Das €-Zeichen kann, muss aber nicht angegeben werden.
                </.input_description>
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input
                  name="vat_amount"
                  value={vat_amount_preview(@form)}
                  type="text"
                  label="Mehrwertsteuer"
                  disabled
                  class="bg-gray-100 text-gray-500 cursor-not-allowed"
                />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input
                  name="gross_amount"
                  value={gross_amount_preview(@form)}
                  type="text"
                  label="Bruttopreis"
                  disabled
                  class="bg-gray-100 text-gray-500 cursor-not-allowed"
                />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:minimum_age_in_years]}
                  type="number"
                  label="Mindestalter (optional)"
                  min="0"
                />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:maximum_age_in_years]}
                  type="number"
                  label="Höchstalter (optional)"
                  min="0"
                />
              </div>
              <div :if={Enum.any?(@successor_rental_fee_options)} class="col-span-12">
                <.input
                  field={@form[:successor_id]}
                  type="select"
                  label="Nachfolger-Gebühr (optional)"
                  options={@successor_rental_fee_options |> Enum.map(&{&1.name, &1.id})}
                  prompt="Keine Nachfolger-Gebühr"
                />
              </div>
            </.input_grid>
          </.input_grids>

          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
              <.button
                :if={@rental_fee.id}
                class="bg-rose-700 hover:bg-rose-800"
                phx-click={JS.push("delete", value: %{id: @rental_fee.id})}
                data-confirm="Unwiderruflich löschen?"
              >
                Löschen
              </.button>
            </div>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  @impl true
  def update(%{rental_fee: rental_fee} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:category_options, Inventory.list_categories(assigns.club.id))
     |> assign(:article_options, Inventory.list_articles(assigns.club.id))
     |> assign_new(:form, fn ->
       to_form(Inventory.change_rental_fee(rental_fee))
     end)
     |> assign_successor_rental_fee_options(rental_fee, rental_fee.maximum_age_in_years)}
  end

  @impl true
  def handle_event("validate", %{"rental_fee" => rental_fee_params}, socket) do
    changeset = Inventory.change_rental_fee(socket.assigns.rental_fee, rental_fee_params)

    changed_maximum_age_in_years = get_change(changeset, :maximum_age_in_years)

    rental_fee =
    %{
      socket.assigns.rental_fee
      | member_type: get_field(changeset, :member_type),
        rental_duration: get_field(changeset, :rental_duration)
    }


    if changed_maximum_age_in_years do
      # Assigning new successor_fee_options should usually be done in a separate
      # handle_event function that gets called every time a change happens
      # to the value of the :maximum_age_in_years field. This was the case once,
      # but adding a phx-change="..." to the field removed the ability to
      # dynamically validate with this function. This led to some unwanted
      # behaviours (the validation only happend after clicking submit)
      # and was therefore replaced with what you can see here.
      # It is not optimal, because the assignment of new successor_fee_options
      # happens more often than it would with a separate handle_event function,
      # but at least the dynamic validation works (again) and doesn't confuse users.
      # https://hexdocs.pm/phoenix_live_view/form-bindings.html
      {:noreply,
       socket
       |> assign(form: to_form(changeset, action: :validate))
       |> assign_successor_rental_fee_options(
         rental_fee,
         changed_maximum_age_in_years
       )}
    else
      {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end

  def handle_event("save", %{"rental_fee" => rental_fee_params}, socket) do
    save_rental_fee(socket, socket.assigns.action, rental_fee_params)
  end

  defp save_rental_fee(socket, :edit, rental_fee_params) do
    case Inventory.update_rental_fee(socket.assigns.rental_fee, rental_fee_params) do
      {:ok, _rental_fee} ->
        {:noreply,
         socket
         |> put_flash(:info, "Mietgebühr wurde erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp assign_successor_rental_fee_options(socket, rental_fee, maximum_age_in_years) do
    assign(
      socket,
      :successor_rental_fee_options,
      Inventory.list_successor_rental_fee_options(rental_fee, maximum_age_in_years)
    )
  end

  defp save_rental_fee(socket, :new, rental_fee_params) do
    rental_fee_params =
      Enum.into(rental_fee_params, %{
        "club_id" => socket.assigns.rental_fee.club.id
      })

    case Inventory.create_rental_fee(rental_fee_params) do
      {:ok, _rental_fee} ->
        {:noreply,
         socket
         |> put_flash(:info, "Mietgebühr erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp vat_amount_preview(form) do
    amount = form[:amount].value
    member_type = form[:member_type].value

    case parse_amount(amount) do
      nil ->
        ""

      amount ->
        vat_rate =
          case member_type do
            :member -> Decimal.new("0.07")
            "member" -> Decimal.new("0.07")
            :non_member -> Decimal.new("0.19")
            "non_member" -> Decimal.new("0.19")
            _ -> Decimal.new("0")
          end

        amount
        |> Decimal.mult(vat_rate)
        |> Decimal.round(2)
        |> Decimal.to_string(:normal)
        |> Kernel.<>(" €")
    end
  end

  defp parse_amount(nil), do: nil

  defp parse_amount(%Money{} = money), do: money.amount

  defp parse_amount(amount) when is_binary(amount) do
    amount =
      amount
      |> String.replace("€", "")
      |> String.replace("\u00A0", "")
      |> String.trim()
      |> String.replace(",", ".")

    case Decimal.parse(amount) do
      {decimal, ""} -> decimal
      _ -> nil
    end
  end

  defp parse_amount(_), do: nil

  defp gross_amount_preview(form) do
    amount = form[:amount].value
    member_type = form[:member_type].value

    case parse_amount(amount) do
      nil ->
        ""

      amount ->
        vat_rate =
          case member_type do
            :member -> Decimal.new("0.07")
            "member" -> Decimal.new("0.07")
            :non_member -> Decimal.new("0.19")
            "non_member" -> Decimal.new("0.19")
            _ -> Decimal.new("0")
          end

        amount
        |> Decimal.mult(Decimal.add(Decimal.new("1"), vat_rate))
        |> Decimal.round(2)
        |> Decimal.to_string(:normal)
        |> Kernel.<>(" €")
    end
  end
end
