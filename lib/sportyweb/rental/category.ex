defmodule Sportyweb.Rental.Category do
  use Ecto.Schema
  import Ecto.Changeset
  alias Sportyweb.Organization.Club
  alias Sportyweb.Rental.Article
  alias Sportyweb.Rental.CategoryRentalFee
  alias Sportyweb.Rental.RentalFee

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "categories" do
    belongs_to :club, Club
    has_many :articles, Article

    many_to_many :rental_fees, RentalFee, join_through: CategoryRentalFee

    field :name, :string
    field :description, :string
    field :loan_period, :integer
    field :loan_period_unit, :string, default: "Tage"
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description, :loan_period, :loan_period_unit, :club_id])
    |> validate_required([:name, :description, :club_id])
    |> unique_constraint(
      :name,
      name: "categories_club_id_name_index",
      message: "Name bereits vergeben!"
    )
  end
end
