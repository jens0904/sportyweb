defmodule Sportyweb.Inventory.RentalFee do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Changeset
  import SportywebWeb.CommonValidations
  alias Sportyweb.Organization
  alias Sportyweb.Organization.Club
  alias Sportyweb.Inventory.Article
  alias Sportyweb.Inventory.Category
  alias Sportyweb.Inventory.Rental


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "rental_fees" do
    belongs_to :club, Club
    belongs_to :article, Article
    belongs_to :category, Category
    has_many :rentals, Rental
    field :scope, :string, virtual: true
    field :name, :string, default: ""
    field :member_type, Ecto.Enum, values: [:member, :non_member]
    field :amount, Money.Ecto.Composite.Type, default_currency: :EUR
    field :minimum_age_in_years, :integer, default: nil
    field :maximum_age_in_years, :integer, default: nil
    field :rental_duration, Ecto.Enum, values: [:short_term, :long_term]

    timestamps(type: :utc_datetime)
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
        :club_id
      ],
      empty_values: ["", nil]
    )
    |> validate_required([
      :name,
      :amount,
      :minimum_age_in_years,
      :maximum_age_in_years,
      :member_type,
      :rental_duration,
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
