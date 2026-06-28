defmodule SportywebWeb.UnitLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Inventory
  alias Sportyweb.Inventory.Unit

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.UnitLive.FormComponent}
        id={@unit.id || :new}
        title={@page_title}
        action={@live_action}
        unit={@unit}
        club={@club}
        navigate={if @unit.id, do: ~p"/units/#{@unit}", else: ~p"/articles/#{@article}"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :articles)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    unit = Inventory.get_unit!(id, article: :club)

    socket
    |> assign(:page_title, "Einheit bearbeiten")
    |> assign(:unit, unit)
    |> assign(:article, unit.article)
    |> assign(:club, unit.article.club)
  end

  defp apply_action(socket, :new, %{"article_id" => article_id}) do
    article = Inventory.get_article!(article_id, [:club])

    socket
    |> assign(:page_title, "Einheit erstellen")
    |> assign(:unit, %Unit{
      article_id: article.id,
      article: article
    })
    |> assign(:article, article)
    |> assign(:club, article.club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    unit = Inventory.get_unit!(id)
    {:ok, _} = Inventory.delete_unit(unit)

    {:noreply,
     socket
     |> put_flash(:info, "Einheit erfolgreich gelöscht")
     |> push_navigate(to: "/articles/#{unit.article_id}")}
  end
end
