defmodule Sportyweb.Rental.CategoryFee do
  @moduledoc """
  Associative entity, part of a [polymorphic association with many to many](https://hexdocs.pm/ecto/polymorphic-associations-with-many-to-many.html).
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Rental.Category
  alias Sportyweb.Finance.Fee

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "category_fees" do
    belongs_to :category, Category
    belongs_to :fee, Fee

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category_fee, attrs) do
    category_fee
    |> cast(attrs, [:category_id, :fee_id])
    |> validate_required([:category_id, :fee_id])
    |> unique_constraint(:fee_id, name: "category_fees_fee_id_index")
  end
end
