defmodule SportywebWeb.RentalRuleLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :rental_rules)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("filter", params, socket) do
    scope = Map.get(params, "scope", "")
    object_id = Map.get(params, "object_id", "")

    object_id =
      if scope in ["category", "article"] do
        object_id
      else
        ""
      end

    rental_rules =
      socket.assigns.all_rental_rules
      |> Enum.filter(fn rule ->
        scope_ok =
          case scope do
            "" -> true
            "club" -> is_nil(rule.article_id) and is_nil(rule.category_id)
            "category" -> not is_nil(rule.category_id)
            "article" -> not is_nil(rule.article_id)
          end

        object_ok =
          case {scope, object_id} do
            {_, ""} -> true
            {"category", id} -> rule.category_id == id
            {"article", id} -> rule.article_id == id
            _ -> true
          end

        scope_ok and object_ok
      end)

    {:noreply,
     socket
     |> assign(:scope, scope)
     |> assign(:object_id, object_id)
     |> stream(:rental_rules, rental_rules, reset: true)}
  end

  defp apply_action(socket, :index_root, _params) do
    socket
    |> redirect(to: "/clubs")
  end

  defp apply_action(socket, :index, %{"club_id" => club_id}) do
    club =
      Organization.get_club!(club_id,
        rental_rules: [:category, :article],
        articles: [],
        categories: []
      )

    active_rental_rules =
      Enum.filter(club.rental_rules, &is_nil(&1.archived_at))

    socket
    |> assign(:page_title, "Mietregeln")
    |> assign(:all_rental_rules, active_rental_rules)
    |> assign(:club, club)
    |> assign(:scope, "")
    |> assign(:object_id, "")
    |> stream(:rental_rules, active_rental_rules, reset: true)
  end
end
