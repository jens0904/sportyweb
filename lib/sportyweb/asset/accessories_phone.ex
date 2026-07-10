defmodule Sportyweb.Asset.AccessoriesPhone do
  @moduledoc """
  Associative entity, part of a [polymorphic association with many to many](https://hexdocs.pm/ecto/polymorphic-associations-with-many-to-many.html).
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Accessories
  alias Sportyweb.Polymorphic.Phone

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accessories_phones" do
    belongs_to :accessories, Accessories
    belongs_to :phone, Phone

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(accessories_phone, attrs) do
    accessories_phone
    |> cast(attrs, [:accessories_id, :phone_id])
    |> validate_required([:accessories_id, :phone_id])
    |> unique_constraint(:phone_id, name: "accessories_phones_phone_id_index")
  end
end
