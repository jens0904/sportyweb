defmodule SportywebWeb.RentalFeeLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Rental

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :articles)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    rental_fee =
      Rental.get_rental_fee!(id, article: :club)

    {:noreply,
     socket
     |> assign(:page_title, "Mietentgelt: #{rental_fee.name}")
     |> assign(:article, rental_fee.article)
     |> assign(:rental_fee, rental_fee)
     |> assign(:club, rental_fee.article.club)}
  end
end
