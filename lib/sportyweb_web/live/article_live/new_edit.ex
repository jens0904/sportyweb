defmodule SportywebWeb.ArticleLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Inventory
  alias Sportyweb.Inventory.Article

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.ArticleLive.FormComponent}
        id={@article.id || :new}
        title={@page_title}
        action={@live_action}
        article={@article}
        club={@club}
        navigate={
          if @article.id,
            do: ~p"/articles/#{@article}",
            else: ~p"/clubs/#{@club}/articles"
        }
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
    article = Inventory.get_article!(id, [:club])

    socket
    |> assign(:page_title, "Artikel bearbeiten")
    |> assign(:article, article)
    |> assign(:club, article.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id, [:articles, :departments])

    socket
    |> assign(:page_title, "Artikel erstellen")
    |> assign(:article, %Article{
      club_id: club.id,
      club: club
    })
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    article = Inventory.get_article!(id)
    {:ok, _} = Inventory.delete_article(article)

    {:noreply,
     socket
     |> put_flash(:info, "Ausrüstungsart erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{article.club_id}/articles")}
  end
end
