defmodule Sportyweb.Rental.Unit do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Asset.Location
  alias Sportyweb.Rental.Article
  alias Sportyweb.Rental.Loan

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "units" do
    belongs_to :article, Article
    belongs_to :location, Location
    has_many :loans, Loan
    field :serial_number, :integer
    field :for_lending, :boolean, default: true
    field :occupied, :boolean, default: false
    field :purchase_date, :date, default: nil
    field :commission_date, :date, default: nil
    field :decommission_date, :date, default: nil

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(unit, attrs) do
    unit
    |> cast(attrs, [
      :serial_number,
      :for_lending,
      :occupied,
      :purchase_date,
      :commission_date,
      :decommission_date,
      :article_id,
      :location_id
    ])
    |> validate_required([:serial_number, :article_id, :location_id])
    |> validate_length(:serial_number, max: 250)
    |> validate_dates_order(
      :purchase_date,
      :commission_date,
      "Muss zeitlich später als oder gleich \"Gekauft am\" sein!"
    )
    |> validate_dates_order(
      :commission_date,
      :decommission_date,
      "Muss zeitlich später als oder gleich \"Nutzung ab\" sein!"
    )
  end
end
