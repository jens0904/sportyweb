defmodule Sportyweb.Asset.AccessoriesFee do
  @moduledoc """
  Associative entity, part of a [polymorphic association with many to many](https://hexdocs.pm/ecto/polymorphic-associations-with-many-to-many.html).
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Accessories
  alias Sportyweb.Finance.Fee

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accessories_fees" do
    belongs_to :accessories, Accessories
    belongs_to :fee, Fee

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(accessories_fee, attrs) do
    accessories_fee
    |> cast(attrs, [:accessories_id, :fee_id])
    |> validate_required([:accessories_id, :fee_id])
    |> unique_constraint(:fee_id, name: "accessories_fees_fee_id_index")
  end
end
