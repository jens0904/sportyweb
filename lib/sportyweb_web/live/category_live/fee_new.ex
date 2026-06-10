defmodule SportywebWeb.CategoryLive.FeeNew do
  use SportywebWeb, :live_view

  alias Sportyweb.Rental
  alias Sportyweb.Finance.Fee
  alias Sportyweb.Polymorphic.InternalEvent
  alias Sportyweb.Polymorphic.Note

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.FeeLive.FormComponent}
        id={@fee.id || :new}
        title={@page_title}
        action={@live_action}
        fee={@fee}
        fee_object={@category}
        navigate={if @fee.id, do: ~p"/fees/#{@fee}", else: ~p"/categories/#{@category}"}
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

  defp apply_action(socket, :index, %{"id" => id}) do
    # If the route behind this function should be more than a redirect in the future, put it in its own "Index"-LiveView!
    socket
    |> push_navigate(to: ~p"/categories/#{id}")
  end

  # There is no "edit" action in this LiveView because that gets handled in the default SportywebWeb.FeeLive.NewEdit

  defp apply_action(socket, :new, %{"id" => id}) do
    category = Rental.get_category!(id, :club)
    type = "category"

    socket
    |> assign(
      :page_title,
      "Spezifische Gebühr erstellen (#{get_key_for_value(Fee.get_valid_types(), type)})"
    )
    |> assign(:fee, %Fee{
      club_id: category.club.id,
      club: category.club,
      is_general: false,
      type: type,
      categories: [category],
      internal_events: [%InternalEvent{}],
      notes: [%Note{}]
    })
    |> assign(:category, category)
    |> assign(:club, category.club)
  end
end
