defmodule SportywebWeb.CategoryLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Inventory
  alias Sportyweb.Inventory.Category
  alias Sportyweb.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.CategoryLive.FormComponent}
        id={@category.id || :new}
        title={@page_title}
        action={@live_action}
        category={@category}
        club={@club}
        navigate={
          if @category.id,
            do: ~p"/categories/#{@category}",
            else: ~p"/clubs/#{@club}/categories"
        }
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :categories)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    category = Inventory.get_category!(id, [:club])

    socket
    |> assign(:page_title, "Ausrüstungskategorie bearbeiten")
    |> assign(:category, category)
    |> assign(:club, category.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id, [:categories])

    socket
    |> assign(:page_title, "Ausrüstungskategorie erstellen")
    |> assign(:category, %Category{
      club_id: club.id,
      club: club
    })
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Inventory.get_category!(id)
    {:ok, _} = Inventory.delete_category(category)

    {:noreply,
     socket
     |> put_flash(:info, "Ausrüstungskategorie erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{category.club_id}/categories")}
  end
end
