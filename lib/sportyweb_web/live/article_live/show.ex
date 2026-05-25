defmodule SportywebWeb.ArticleLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Rental

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :articles)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    article =
      Rental.get_article!(id, [:club, units: :location])

    {:noreply,
     socket
     |> assign(:page_title, "Artikel: #{article.name}")
     |> assign(:article, article)
     |> assign(:club, article.club)
     |> stream(:units, article.units)}
  end
end
