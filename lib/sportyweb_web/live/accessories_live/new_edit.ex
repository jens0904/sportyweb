defmodule SportywebWeb.AccessoriesLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Asset
  alias Sportyweb.Asset.Accessories
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.AccessoriesLive.FormComponent}
        id={@accessories.id || :new}
        title={@page_title}
        action={@live_action}
        accessories={@accessories}
        navigate={
          if @accessories.id, do: ~p"/accessories/#{@accessories}", else: ~p"/locations/#{@location}"
        }
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :assets)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    accessories = Asset.get_accessories!(id, [:emails, :phones, :notes, location: :club])

    socket
    |> assign(:page_title, "Accessories bearbeiten")
    |> assign(:accessories, accessories)
    |> assign(:location, accessories.location)
    |> assign(:club, accessories.location.club)
  end

  defp apply_action(socket, :new, %{"location_id" => location_id}) do
    location = Asset.get_location!(location_id, [:club])

    socket
    |> assign(:page_title, "Accessories erstellen")
    |> assign(:accessories, %Accessories{
      location_id: location.id,
      location: location,
      emails: [%Email{}],
      phones: [%Phone{}],
      notes: [%Note{}]
    })
    |> assign(:location, location)
    |> assign(:club, location.club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    accessories = Asset.get_accessories!(id)
    {:ok, _} = Asset.delete_accessories(accessories)

    {:noreply,
     socket
     |> put_flash(:info, "Zubehör erfolgreich gelöscht")
     |> push_navigate(to: "/locations/#{accessories.location_id}")}
  end
end
