defmodule SportywebWeb.AccessoriesLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Asset

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :assets)}
  end

  @impl true
  @spec handle_params(map(), any(), map()) :: {:noreply, map()}
  def handle_params(%{"id" => id}, _, socket) do
    accessories =
      Asset.get_accessories!(id, [:emails, :notes, :phones, fees: :internal_events, location: :club])

    {:noreply,
     socket
     |> assign(:page_title, "Accessories: #{accessories.name}")
     |> assign(:accessories, accessories)
     |> assign(:location, accessories.location)
     |> assign(:club, accessories.location.club)}
  end
end
