defmodule Sportyweb.Rental.ArticleRentalFee do
  @moduledoc """
  Associative entity, part of a [polymorphic association with many to many](https://hexdocs.pm/ecto/polymorphic-associations-with-many-to-many.html).
  """

  use Ecto.Schema
  import Ecto.Changeset


  alias Sportyweb.Article
  alias Sportyweb.RentalFee

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "article_rental_fees" do
    belongs_to :article, Article
    belongs_to :rental_fee, RentalFee

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article_rental_fee, attrs) do
    article_rental_fee
    |> cast(attrs, [:article_id, :rental_fee_id])
    |> validate_required([:article_id, :rental_fee_id])
  end
end
