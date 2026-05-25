defmodule SportywebWeb.LoanLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Rental
  alias Sportyweb.Organization.Club

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :loans)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    loan =
      Rental.get_loan!(id, [:club])

    {:noreply,
     socket
     |> assign(:page_title, "Ausleihe: #{loan.loan_number}")
     |> assign(:loan, loan)
     |> assign(:club, loan.club)}
  end
end
