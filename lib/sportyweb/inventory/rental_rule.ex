defmodule Sportyweb.Inventory.RentalRule do
  use Ecto.Schema
  import Ecto.Changeset
  alias Sportyweb.Organization.Club
  alias Sportyweb.Inventory.Category
  alias Sportyweb.Inventory.Article


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "rental_rules" do
    belongs_to :club, Club
    belongs_to :category, Category
    belongs_to :article, Article

    field :scope, :string, virtual: true
    field :choose_rental_period, :boolean, default: false
    field :for_club_members, :boolean, default: false
    field :for_non_members, :boolean, default: false
    field :rental_period, :integer
    field :rental_period_unit, :string, default: "Tage"
    field :allow_renewal, :boolean, default: false
    field :max_renewals, :integer, default: 2
    field :renewal_period, :integer, default: 7

    timestamps(type: :utc_datetime)
  end

  @doc false
  @doc false
def changeset(rental_rule, attrs) do
  rental_rule
  |> cast(attrs, [
    :club_id,
    :category_id,
    :article_id,
    :scope,
    :choose_rental_period,
    :for_club_members,
    :for_non_members,
    :rental_period,
    :rental_period_unit,
    :allow_renewal,
    :max_renewals,
    :renewal_period
  ])
  |> validate_required([:club_id])
  |> foreign_key_constraint(:club_id)
  |> foreign_key_constraint(:category_id)
  |> foreign_key_constraint(:article_id)
end
end
