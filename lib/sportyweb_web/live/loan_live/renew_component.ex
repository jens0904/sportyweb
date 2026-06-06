defmodule SportywebWeb.LoanLive.RenewComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Rental

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>
      <.card>
      <%= if @article.allow_renewal do %>
        <%= if @loan.renewal_count < @article.max_renewals do %>
          <.simple_form
            for={@form}
            id="loan-renew-form"
            phx-target={@myself}
            phx-change="validate"
          phx-submit="save"
        >
          <.input
            field={@form[:return_date]}
            type="date"
            label="Neues Rückgabedatum"
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
  def update(%{loan: loan} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(Rental.change_loan(loan)))}
  end

  @impl true
  def handle_event("validate", %{"loan" => loan_params}, socket) do
    changeset = Rental.change_loan(socket.assigns.loan, loan_params)

      {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"loan" => loan_params}, socket) do
    case Rental.renew_loan(socket.assigns.loan, loan_params) do
      {:ok, loan} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ausleihe erfolgreich verlängert.")
         |> push_navigate(to: ~p"/loans/#{loan}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, changeset)}
    end
  end


end
