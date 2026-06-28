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
      <%= if @article.allow_renewal do %>
        <%= if @rental.renewal_count < @article.max_renewals do %>
            <.simple_form
              for={@form}
              id="rental-renew-form"
              phx-target={@myself}
              phx-change="validate"
              phx-submit="save"
          >
            <.input
              field={@form[:return_date]}
              type="date"
              label="Neues Rückgabedatum"
              readonly={true}
            />

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
    return_date = Inventory.calculate_new_return_date(rental, assigns.article.id)

    changeset = Inventory.change_rental(rental, %{"return_date" => return_date})
    {:ok,
     socket
     |> assign(assigns)
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
    case Inventory.renew_rental(socket.assigns.rental, rental_params) do
      {:ok, rental} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ausleihe erfolgreich verlängert.")
         |> push_navigate(to: ~p"/rentals/#{rental}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, changeset)}
    end
  end


end
