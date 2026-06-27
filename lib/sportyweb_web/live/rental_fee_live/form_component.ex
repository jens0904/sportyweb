defmodule SportywebWeb.RentalFeeLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Rental
  alias Sportyweb.Rental.Category
  alias Sportyweb.Rental.Article

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
     |> assign_new(:form, fn ->
       to_form(Rental.change_rental_fee(rental_fee))
     end)}
  end

  @impl true
  def handle_event("validate", %{"rental_fee" => rental_fee_params}, socket) do
    changeset = Rental.change_rental_fee(socket.assigns.rental_fee, rental_fee_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"rental_fee" => rental_fee_params}, socket) do
    save_rental_fee(socket, socket.assigns.action, rental_fee_params)
  end

  defp save_rental_fee(socket, :edit, rental_fee_params) do
    case Rental.update_rental_fee(socket.assigns.rental_fee, rental_fee_params) do
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

    case Rental.create_rental_fee(rental_fee_params) do
      {:ok, rental_fee} ->
        case create_association(rental_fee, socket.assigns.rental_fee_object) do
          {:ok, _} ->
            {:noreply,
            socket
            |> put_flash(:info, "Mietgebühr erfolgreich erstellt")
            |> push_navigate(to: socket.assigns.navigate)}

          {:error, _} ->
            {:noreply,
            socket
            |> put_flash(:error, "Mietgebühr konnte nicht erstellt werden")}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp create_association(rental_fee, %Category{} = rental_fee_object) do
    Rental.create_category_rental_fee(rental_fee_object, rental_fee)
    {:ok, rental_fee}
  end

  defp create_association(rental_fee, %Article{} = rental_fee_object) do
    Rental.create_article_rental_fee(rental_fee_object, rental_fee)
    {:ok, rental_fee}
  end

end
