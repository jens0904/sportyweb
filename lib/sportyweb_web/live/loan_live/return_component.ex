defmodule SportywebWeb.LoanLive.ReturnComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Rental


  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="loan-return-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:return_comment]} type="textarea" label="Kommentar" />
        <.button>Ausleihe zurückgeben</.button>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{loan: loan} = assigns, socket) do
    changeset = Rental.change_loan(loan)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"loan" => loan_params}, socket) do
    changeset = Rental.change_loan(socket.assigns.loan, loan_params)

      {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"loan" => loan_params}, socket) do
    case Rental.return_loan(socket.assigns.loan, loan_params) do
      {:ok, %{loan: _loan}} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ausleihe erfolgreich zurückgegeben")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, :loan, %Ecto.Changeset{} = changeset, _changes} ->
        {:noreply, assign(socket, :form, to_form(changeset))}

      {:error, :unit, %Ecto.Changeset{} = _changeset, _changes} ->
        {:noreply,
        socket
        |> put_flash(:error, "Fehler beim Zurückgeben der Ausleihe.")}
    end
  end
end
