defmodule SportywebWeb.ArticleLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Inventory
  alias Sportyweb.Inventory.Unit

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :articles)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    article =
      Inventory.get_article_with_active_rentals!(id)

    rental_rule = Inventory.get_applicable_rental_rule(article.id)

    {:noreply,
     socket
     |> assign(:page_title, "Artikel: #{article.name}")
     |> assign(:article, article)
     |> assign(:club, article.club)
     |> assign(:rental_rule, rental_rule)
     |> stream(:units, article.units)
     |> stream(:rentals, article.rentals)}
  end
end
