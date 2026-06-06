defmodule SportywebWeb.LoanLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Rental
  alias Sportyweb.Rental.Loan

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.LoanLive.FormComponent}
        id={@loan.id || :new}
        title={@page_title}
        action={@live_action}
        loan={@loan}
        article={@article}
        club={@club}
        navigate={if @loan.id, do: ~p"/loans/#{@loan}", else: ~p"/articles/#{@article}"}
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

  defp apply_action(socket, :edit, %{"id" => id}) do
    loan = Rental.get_loan!(id, article: :club)

    socket
    |> assign(:page_title, "Ausleihe bearbeiten")
    |> assign(:loan, loan)
    |> assign(:article, loan.article)
    |> assign(:club, loan.article.club)
  end

  defp apply_action(socket, :new, %{"article_id" => article_id}) do
    article = Rental.get_article!(article_id, [:club, :units])

    socket
    |> assign(:page_title, "Ausleihe anlegen")
    |> assign(:loan, %Loan{
      article_id: article.id,
      article: article
    })
    |> assign(:article, article)
    |> assign(:club, article.club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    loan = Rental.get_loan!(id)
    {:ok, _} = Rental.delete_loan(loan)

    {:noreply,
     socket
     |> put_flash(:info, "Ausleihe erfolgreich gelöscht")
     |> push_navigate(to: "/article/#{loan.article_id}/loans")}
  end
end
