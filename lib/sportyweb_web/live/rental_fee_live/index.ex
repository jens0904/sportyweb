defmodule SportywebWeb.RentalFeeLive.Index do
  use SportywebWeb, :live_view
  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :rental_fees)}
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

    rental_fees =
      socket.assigns.all_rental_fees
      |> Enum.filter(fn fee ->
        scope_ok =
          case scope do
            "" -> true
            "club" -> is_nil(fee.article_id) and is_nil(fee.category_id)
            "category" -> not is_nil(fee.category_id)
            "article" -> not is_nil(fee.article_id)
          end

        object_ok =
          case {scope, object_id} do
            {_, ""} -> true
            {"category", id} -> fee.category_id == id
            {"article", id} -> fee.article_id == id
            _ -> true
          end

        scope_ok and object_ok
      end)

    {:noreply,
     socket
     |> assign(:scope, scope)
     |> assign(:object_id, object_id)
     |> stream(:rental_fees, rental_fees, reset: true)}
  end

  defp apply_action(socket, :index_root, _params) do
    socket
    |> redirect(to: "/clubs")
  end

  defp apply_action(socket, :index, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id, rental_fees: [:article, :category, :successor, :club], articles: [], categories: [])

    socket
    |> assign(:page_title, "Mietgebühren")
    |> assign(:all_rental_fees, club.rental_fees)
    |> assign(:club, club)
    |> assign(:scope, "")
    |> assign(:object_id, "")
    |> stream(:rental_fees, club.rental_fees, reset: true)

  end
end
