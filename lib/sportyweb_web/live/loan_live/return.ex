defmodule SportywebWeb.LoanLive.Return do
  use SportywebWeb, :live_view

  alias Sportyweb.Rental


  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.LoanLive.ReturnComponent}
        id={@loan.id}
        title="Ausleihe zurückgeben"
        action={@live_action}
        loan={@loan}
        article={@article}
        club={@club}
        navigate={~p"/articles/#{@article}"}
      />
    </div>
    """
  end


  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :articles)}
  end



  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end



  def apply_action(socket, :return, %{"id" => id}) do
    loan = Rental.get_loan!(id, article: :club)

    socket
    |> assign(:page_title, "Ausleihe zurückgeben")
    |> assign(:loan, loan)
    |> assign(:article, loan.article)
    |> assign(:club, loan.article.club)
  end



end
