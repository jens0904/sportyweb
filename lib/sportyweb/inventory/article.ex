defmodule Sportyweb.Inventory.Article do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.Department
  alias Sportyweb.Inventory.Category
  alias Sportyweb.Inventory.Unit
  alias Sportyweb.Inventory.Rental
  alias Sportyweb.Inventory.ArticleRentalFee
  alias Sportyweb.Inventory.RentalFee
  alias Sportyweb.Inventory.RentalRule
  alias Sportyweb.Inventory.OldRentals

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "articles" do
    belongs_to :club, Club
    belongs_to :department, Department
    belongs_to :category, Category
    has_many :units, Unit
    has_many :rentals, Rental
    has_many :old_rentals, OldRentals
    has_many :rental_rules, RentalRule
    has_many :rental_fees, RentalFee
    field :name, :string
    field :description, :string
    field :reference_number, :string
    field :costs_of_loss, Money.Ecto.Composite.Type, default_currency: :EUR


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [
      :name,
      :description,
      :reference_number,
      :costs_of_loss,
      :club_id,
      :department_id,
      :category_id
    ])
    |> validate_required([
      :name,
      :description,
      :reference_number
    ])
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> validate_currency(:amount, :EUR)
    |> validate_currency(:amount_one_time, :EUR)
  end
  @derive {
  Flop.Schema,
  filterable: [:name, :reference_number, :category_id],
  sortable: [:name, :reference_number],
  default_limit: 20
  }
end
