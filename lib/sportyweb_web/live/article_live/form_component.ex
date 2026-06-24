defmodule SportywebWeb.ArticleLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Rental
  alias Sportyweb.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage article records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="article-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Beschreibung" />
        <.input field={@form[:reference_number]} type="text" label="Referenznummer" />
        <.input field={@form[:costs_of_loss]} type="text" label="Wiederbeschaffungskosten" />
        <div class="col-span-12">
          <.input
            field={@form[:department_id]}
            type="select"
            label="Abteilung"
            options={@department_options |> Enum.map(&{&1.name, &1.id})}
            prompt="Vereinsweit"
          />
        </div>
        <div class="col-span-12">
          <.input
            field={@form[:category_id]}
            type="select"
            label="Kategorie"
            options={@category_options |> Enum.map(&{&1.name, &1.id})}
            prompt="---"
          />
        </div>
        <.input field={@form[:for_non_members]} type="checkbox" label="Überlassung an Nichtmitglieder erlauben" />
        <.input field={@form[:allow_renewal]} type="checkbox" label="Verlängerung erlauben" />
        <%= if Phoenix.HTML.Form.normalize_value("checkbox", @form[:allow_renewal].value) do %>
          <.input field={@form[:max_renewals]} type="select" label="Bitte die maximale Anzahl an Verlängerungen auswählen" options={1..5}  />
          <.input field={@form[:renewal_period]} type="number" label="Verlängerungszeitraum in Tagen" />
        <% end %>
        <.input
          field={@form[:choose_loan_period]}
          type="checkbox"
          label="festen Ausleihzeitraum hinzufügen"
        />
        <%= if Phoenix.HTML.Form.normalize_value("checkbox", @form[:choose_loan_period].value) do %>
          <.input field={@form[:loan_period_unit]} type="select" label="Bitte wählen Sie die gewünschte Einheit aus" options={[{"Stunden", "hours"}, {"Tage", "days"}]}  />
          <%= if @form[:loan_period_unit].value == "hours" do %>
             <.input
               field={@form[:loan_period]}
               type="select"
               label="Ausleihzeitraum in Stunden"
               options={Enum.map(1..12, fn n -> {n, n} end)}
              />
         <% else %>
          <.input
            field={@form[:loan_period]}
            type="number"
            label="Ausleihzeitraum in Tagen"
          />
          <% end %>
        <% end %>
        <:actions>
          <.button phx-disable-with="Saving...">Speichern</.button>
          <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
          <.button
            :if={@article.id}
            class="bg-rose-700 hover:bg-rose-800"
            phx-click={JS.push("delete", value: %{id: @article.id})}
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
  def update(%{article: article} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:department_options, Organization.list_departments(assigns.club.id))
     |> assign(:category_options, Rental.list_categories(assigns.club.id))
     |> assign_new(:form, fn ->
       to_form(Rental.change_article(article))
     end)}
  end

  @impl true
  def handle_event("validate", %{"article" => article_params}, socket) do
    changeset = Rental.change_article(socket.assigns.article, article_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"article" => article_params}, socket) do
    save_article(socket, socket.assigns.action, article_params)
  end

  defp save_article(socket, :edit, article_params) do
    article_params =
      Enum.into(article_params, %{
        "club_id" => socket.assigns.article.club.id
      })

    case Rental.update_article(socket.assigns.article, article_params) do
      {:ok, _article} ->
        {:noreply,
         socket
         |> put_flash(:info, "Article updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_article(socket, :new, article_params) do
    article_params =
      Enum.into(article_params, %{
        "club_id" => socket.assigns.article.club.id
      })

    case Rental.create_article(article_params) do
      {:ok, _article} ->
        {:noreply,
         socket
         |> put_flash(:info, "Article created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
