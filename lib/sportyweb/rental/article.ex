defmodule Sportyweb.Rental.Article do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.Department
  alias Sportyweb.Rental.Category
  alias Sportyweb.Rental.Unit
  alias Sportyweb.Rental.Loan
  alias Sportyweb.Rental.RentalFee

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "articles" do
    belongs_to :club, Club
    belongs_to :department, Department
    belongs_to :category, Category
    has_many :units, Unit
    has_many :loans, Loan
    has_many :rental_fees, RentalFee
    field :name, :string
    field :description, :string
    field :reference_number, :string
    field :costs_of_loss, Money.Ecto.Composite.Type, default_currency: :EUR
    field :choose_loan_period, :boolean, default: false
    field :for_club_members, :boolean, default: false
    field :for_non_members, :boolean, default: false
    field :loan_period, :integer
    field :loan_period_unit, :string, default: "Tage"
    field :allow_renewal, :boolean, default: false
    field :max_renewals, :integer, default: 2
    field :renewal_period, :integer, default: 7

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
      :category_id,
      :for_club_members,
      :for_non_members,
      :choose_loan_period,
      :loan_period,
      :loan_period_unit,
      :allow_renewal,
      :max_renewals,
      :renewal_period
    ])
    |> validate_required([
      :name,
      :description,
      :reference_number,
      :for_club_members,
      :for_non_members,
      :costs_of_loss,
      :club_id,
      :allow_renewal,
      :max_renewals
    ])
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> validate_currency(:amount, :EUR)
    |> validate_currency(:amount_one_time, :EUR)
  end
end
