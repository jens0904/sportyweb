defmodule Sportyweb.Inventory.Category do
  use Ecto.Schema
  import Ecto.Changeset
  alias Sportyweb.Organization.Club
  alias Sportyweb.Inventory.Article
  alias Sportyweb.Inventory.CategoryRentalFee
  alias Sportyweb.Inventory.RentalFee

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "categories" do
    belongs_to :club, Club
    has_many :articles, Article

    has_many :rental_fees, RentalFee

    field :name, :string
    field :description, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description, :club_id])
    |> validate_required([:name, :description, :club_id])
    |> unique_constraint(
      :name,
      name: "categories_club_id_name_index",
      message: "Name bereits vergeben!"
    )
  end
end
