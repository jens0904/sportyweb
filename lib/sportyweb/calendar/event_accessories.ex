defmodule Sportyweb.Calendar.EventAccessories do
  @moduledoc """
  Associative entity, part of a [polymorphic association with many to many](https://hexdocs.pm/ecto/polymorphic-associations-with-many-to-many.html).
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Accessories
  alias Sportyweb.Calendar.Event

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_accessories" do
    belongs_to :event, Event
    belongs_to :accessories, Accessories

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_accessories, attrs) do
    event_accessories
    |> cast(attrs, [:event_id, :accessories_id])
    |> validate_required([:event_id, :accessories_id])
    |> unique_constraint(:accessories_id, name: "event_accessories_accessories_id_index")
  end
end
