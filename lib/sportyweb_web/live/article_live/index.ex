defmodule SportywebWeb.ArticleLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :articles)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end


def handle_event("filter", params, socket) do
  department_id = Map.get(params, "department_id", "")
  category_id = Map.get(params, "category_id", "")
  rental_status = Map.get(params, "rental_status", "")

  articles =
    socket.assigns.all_articles
    |> Enum.filter(fn article ->
      matches_department? =
        department_id == "" or article.department_id == department_id

      matches_category? =
        category_id == "" or article.category_id == category_id

      matches_rental_status? =
        case rental_status do
          "" -> true
          "rented" -> Enum.any?(article.rentals)
          _ -> true
        end

      matches_department? and matches_category? and matches_rental_status?
    end)

  {:noreply,
   socket
   |> assign(:department_id, department_id)
   |> assign(:category_id, category_id)
   |> assign(:rental_status, rental_status)
   |> stream(:articles, articles, reset: true)}
end

  defp apply_action(socket, :index_root, _params) do
    socket
    |> redirect(to: "/clubs")
  end

  defp apply_action(socket, :index, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id, articles: [:department, :category, :rentals], categories: [], departments: [])

    socket
    |> assign(:page_title, "Artikel")
    |> assign(:club, club)
    |> assign(:all_articles, club.articles)
    |> assign(:department_id, "")
    |> assign(:category_id, "")
    |> assign(:available_categories, club.categories)
    |> assign(:rental_status, "")
    |> stream(:articles, club.articles, reset: true)
  end
end
