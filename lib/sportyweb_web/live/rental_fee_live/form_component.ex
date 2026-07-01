defmodule SportywebWeb.RentalFeeLive.FormComponent do
  use SportywebWeb, :live_component

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
              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:scope]}
                  type="select"
                  label="Gilt für"
                  options={[
                    {"Kategorie", "category"},
                    {"Artikel", "article"}
                  ]}
                />
              </div>

              <%= case @form[:scope].value do %>
                <% "category" -> %>
                  <div class="col-span-12 md:col-span-6">
                    <.input
                      field={@form[:category_id]}
                      type="select"
                      label="Kategorie"
                      options={Enum.map(@category_options, &{&1.name, &1.id})}
                      prompt="Kategorie auswählen"
                    />
                  </div>
                <% "article" -> %>
                  <div class="col-span-12 md:col-span-6">
                    <.input
                      field={@form[:article_id]}
                      type="select"
                      label="Artikel"
                      options={Enum.map(@article_options, &{&1.name, &1.id})}
                      prompt="Artikel auswählen"
                    />
                  </div>
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
     end)}
  end

  @impl true
  def handle_event("validate", %{"rental_fee" => rental_fee_params}, socket) do
    changeset = Inventory.change_rental_fee(socket.assigns.rental_fee, rental_fee_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
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
