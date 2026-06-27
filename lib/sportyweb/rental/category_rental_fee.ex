defmodule Sportyweb.Rental.CategoryRentalFee do
  @moduledoc """
  Associative entity, part of a [polymorphic association with many to many](https://hexdocs.pm/ecto/polymorphic-associations-with-many-to-many.html).
  """

  use Ecto.Schema
  import Ecto.Changeset


  alias Sportyweb.Rental.Category
  alias Sportyweb.Rental.RentalFee

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "category_rental_fees" do
    belongs_to :category, Category
    belongs_to :rental_fee, RentalFee

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category_rental_fee, attrs) do
    category_rental_fee
    |> cast(attrs, [:category_id, :rental_fee_id])
    |> validate_required([:category_id, :rental_fee_id])
  end
end
