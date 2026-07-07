defmodule SportywebWeb.ArticleLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Inventory
  alias Sportyweb.Inventory.Rental
  alias Sportyweb.Personal.Contact

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :articles)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    article =
      Inventory.get_article_with_rentals!(id)

    rental_rule =
      Inventory.get_applicable_rental_rule(article.id)

    active_rentals =
      Enum.filter(article.rentals, &Rental.active?/1)

    inactive_rentals =
      Enum.filter(article.rentals, &Rental.inactive?/1)

    {:noreply,
     socket
     |> assign(:page_title, "Artikel: #{article.name}")
     |> assign(:article, article)
     |> assign(:club, article.club)
     |> assign(:rental_rule, rental_rule)
     |> stream(:units, article.units)
     |> assign(:active_rentals_count, length(active_rentals))
     |> assign(:inactive_rentals_count, length(inactive_rentals))
     |> stream(:rentals, active_rentals)
     |> stream(:inactive_rentals, inactive_rentals)}
  end
end
