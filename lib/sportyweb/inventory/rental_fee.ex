defmodule Sportyweb.Inventory.RentalFee do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Changeset
  import SportywebWeb.CommonValidations
  alias Sportyweb.Organization.Club
  alias Sportyweb.Inventory.Article
  alias Sportyweb.Inventory.Category
  alias Sportyweb.Inventory.Rental
  alias Sportyweb.Inventory.RentalFee

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "rental_fees" do
    belongs_to :club, Club
    belongs_to :article, Article
    belongs_to :category, Category
    belongs_to :successor, RentalFee, foreign_key: :successor_id
    has_many :ancestors, RentalFee, foreign_key: :successor_id
    has_many :rentals, Rental
    field :scope, :string, virtual: true
    field :name, :string, default: ""
    field :flat_fee, :boolean, default: false
    field :member_type, Ecto.Enum, values: [:member, :non_member]
    field :amount, Money.Ecto.Composite.Type, default_currency: :EUR
    field :minimum_age_in_years, :integer, default: nil
    field :maximum_age_in_years, :integer, default: nil
    field :rental_duration, Ecto.Enum, values: [:short_term, :long_term]

    timestamps(type: :utc_datetime)
  end

  def vat_rate(%__MODULE__{member_type: member_type}) do
  case member_type do
    :member -> Decimal.new("0.07")
    "member" -> Decimal.new("0.07")
    :non_member -> Decimal.new("0.19")
    "non_member" -> Decimal.new("0.19")
    _ -> Decimal.new("0")
  end
end

def vat_money(%__MODULE__{} = rental_fee) do
  vat_amount =
    rental_fee.amount.amount
    |> Decimal.mult(vat_rate(rental_fee))
    |> Decimal.round(2)

  %{rental_fee.amount | amount: vat_amount}
end

def gross_money(%__MODULE__{} = rental_fee) do
  gross_amount =
    rental_fee.amount.amount
    |> Decimal.add(vat_money(rental_fee).amount)
    |> Decimal.round(2)

  %{rental_fee.amount | amount: gross_amount}
end

def money_label(%Money{} = money) do
  case Money.to_string(money) do
    {:ok, formatted} -> formatted
    formatted when is_binary(formatted) -> formatted
    _ -> ""
  end
end

def vat_amount_label(%__MODULE__{} = rental_fee) do
  rental_fee
  |> vat_money()
  |> money_label()
end

def gross_amount_label(%__MODULE__{} = rental_fee) do
  rental_fee
  |> gross_money()
  |> money_label()
end

  @doc false
  def changeset(fee, attrs) do
    fee
    |> cast(
      attrs,
      [
        :name,
        :amount,
        :minimum_age_in_years,
        :maximum_age_in_years,
        :member_type,
        :scope,
        :rental_duration,
        :article_id,
        :category_id,
        :club_id,
        :successor_id,
        :flat_fee
      ],
      empty_values: ["", nil]
    )
    |> validate_required([
      :name,
      :amount,
      :member_type,
      :rental_duration
    ])
    |> update_change(:name, &String.trim/1)
    |> validate_length(:name, max: 250)
    |> validate_currency(:amount, :EUR)
    |> validate_number(:minimum_age_in_years,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 125
    )
    |> validate_number(:maximum_age_in_years,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 125
    )
    |> validate_numbers_order(
      :minimum_age_in_years,
      :maximum_age_in_years,
      "Muss größer oder gleich \"Mindestalter\" sein!"
    )
  end

  @doc false
end
