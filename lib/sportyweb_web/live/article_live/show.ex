defmodule SportywebWeb.ArticleLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Rental
  alias Sportyweb.Rental.Unit

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :articles)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    article =
      Rental.get_article_with_active_loans!(id)

    {:noreply,
     socket
     |> assign(:page_title, "Artikel: #{article.name}")
     |> assign(:article, article)
     |> assign(:club, article.club)
     |> stream(:units, article.units)
     |> stream(:loans, article.loans)}
  end
end
