defmodule SportywebWeb.RentalRuleLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Inventory

  @impl true
  def render(assigns) do
  ~H"""
<div>
  <.header>
    {@title}
    <:subtitle>Definieren Sie eine Ausleihregel.</:subtitle>
  </.header>

  <.card>
    <.simple_form
      for={@form}
      id="rental_rule-form"
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
                {"Gesamten Verein", "club"},
                {"Kategorie", "category"},
                {"Artikel", "article"}
              ]}
            />
          </div>

          <div class="col-span-12 md:col-span-6">
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
                <div></div>
            <% end %>
          </div>
        </.input_grid>

        <.input_grid class="pt-6">
          <div class="col-span-12 md:col-span-6">
            <.input
              field={@form[:for_club_members]}
              type="checkbox"
              label="Für Vereinsmitglieder"
            />
          </div>

          <div class="col-span-12 md:col-span-6">
            <.input
              field={@form[:for_non_members]}
              type="checkbox"
              label="Für Nichtmitglieder"
            />
          </div>
        </.input_grid>

        <.input_grid class="pt-6">
          <div class="col-span-12 md:col-span-6">
            <.input
              field={@form[:rental_period_unit]}
              type="select"
              label="Einheit"
              prompt="Bitte auswählen"
              options={[
                {"Stunden", "Stunden"},
                {"Tage", "Tage"},
                {"Wochen", "Wochen"}
              ]}
            />
          </div>

          <div class="col-span-12 md:col-span-6">
            <.input
              field={@form[:choose_rental_period]}
              type="checkbox"
              label="Feste Dauer definieren"
            />
          </div>

          <%= if Phoenix.HTML.Form.normalize_value("checkbox", @form[:choose_rental_period].value) do %>
            <div class="col-span-12 md:col-span-6">
              <%= case @form[:rental_period_unit].value do %>
                <% "Stunden" -> %>
                  <.input
                    field={@form[:rental_period]}
                    type="select"
                    label="Dauer"
                    prompt="Bitte auswählen"
                    options={Enum.map(1..12, &{"#{&1} Stunde#{if &1 == 1, do: "", else: "n"}", &1})}
                  />

                <% "Tage" -> %>
                  <.input
                    field={@form[:rental_period]}
                    type="select"
                    label="Dauer"
                    prompt="Bitte auswählen"
                    options={Enum.map(1..7, &{"#{&1} Tag#{if &1 == 1, do: "", else: "e"}", &1})}
                  />

                <% "Wochen" -> %>
                  <.input
                    field={@form[:rental_period]}
                    type="select"
                    label="Dauer"
                    prompt="Bitte auswählen"
                    options={Enum.map(1..10, &{"#{&1} Woche#{if &1 == 1, do: "", else: "n"}", &1})}
                  />

                <% _ -> %>
                  <div></div>
              <% end %>
            </div>
          <% end %>
        </.input_grid>

        <.input_grid class="pt-6">
          <div class="col-span-12 md:col-span-6">
            <.input
              field={@form[:allow_renewal]}
              type="checkbox"
              label="Verlängerung erlauben"
            />
          </div>

          <%= if Phoenix.HTML.Form.normalize_value("checkbox", @form[:allow_renewal].value) do %>
            <div class="col-span-12 md:col-span-6">
              <.input
                field={@form[:max_renewals]}
                type="select"
                label="Maximale Anzahl Verlängerungen"
                options={1..5}
              />
            </div>

            <div class="col-span-12 md:col-span-6">
              <%= case @form[:rental_period_unit].value do %>
                <% "Stunden" -> %>
                  <.input
                    field={@form[:renewal_period]}
                    type="select"
                    label="Verlängerungszeitraum"
                    prompt="Bitte auswählen"
                    options={Enum.map(1..12, &{"#{&1} Stunde#{if &1 == 1, do: "", else: "n"}", &1})}
                  />

                <% "Tage" -> %>
                  <.input
                    field={@form[:renewal_period]}
                    type="select"
                    label="Verlängerungszeitraum"
                    prompt="Bitte auswählen"
                    options={Enum.map(1..7, &{"#{&1} Tag#{if &1 == 1, do: "", else: "e"}", &1})}
                  />

                <% "Wochen" -> %>
                  <.input
                    field={@form[:renewal_period]}
                    type="select"
                    label="Verlängerungszeitraum"
                    prompt="Bitte auswählen"
                    options={Enum.map(1..10, &{"#{&1} Woche#{if &1 == 1, do: "", else: "n"}", &1})}
                  />

                <% _ -> %>
                  <div></div>
              <% end %>
            </div>
          <% end %>
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
  def update(%{rental_rule: rental_rule} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:category_options, Inventory.list_categories(assigns.club.id))
     |> assign(:article_options, Inventory.list_articles(assigns.club.id))
     |> assign_new(:form, fn ->
       to_form(Inventory.change_rental_rule(rental_rule))
     end)}
  end

  @impl true
  def handle_event("validate", %{"rental_rule" => rental_rule_params}, socket) do
    changeset = Inventory.change_rental_rule(socket.assigns.rental_rule, rental_rule_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"rental_rule" => rental_rule_params}, socket) do
    save_rental_rule(socket, socket.assigns.action, rental_rule_params)
  end

  defp save_rental_rule(socket, :edit, rental_rule_params) do
    rental_rule_params =
      Enum.into(rental_rule_params, %{
        "club_id" => socket.assigns.rental_rule.club.id
      })

    case Inventory.update_rental_rule(socket.assigns.rental_rule, rental_rule_params) do
      {:ok, _rental_rule} ->
        {:noreply,
         socket
         |> put_flash(:info, "Rental rule updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_rental_rule(socket, :new, rental_rule_params) do
    rental_rule_params =
      Enum.into(rental_rule_params, %{
        "club_id" => socket.assigns.rental_rule.club.id
      })

    case Inventory.create_rental_rule(rental_rule_params) do
      {:ok, _rental_rule} ->
        {:noreply,
         socket
         |> put_flash(:info, "Rental rule created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
