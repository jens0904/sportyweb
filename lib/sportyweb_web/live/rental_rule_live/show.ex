defmodule SportywebWeb.RentalRuleLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Inventory

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :rental_rules)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    rental_rule = Inventory.get_rental_rule!(id, [:club, :category, :article])

    {:noreply,
     socket
     |> assign(:page_title, page_title(rental_rule))
     |> assign(:rental_rule, rental_rule)
     |> assign(:club, rental_rule.club)}
  end

  defp page_title(%{article: article}) when not is_nil(article) do
    "Mietregel für Artikel: #{article.name}"
  end

  defp page_title(%{category: category}) when not is_nil(category) do
    "Mietregel für Kategorie: #{category.name}"
  end

  defp page_title(_rental_rule) do
    "Mietregel für gesamten Verein"
  end
end
