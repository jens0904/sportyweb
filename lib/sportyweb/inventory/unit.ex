defmodule Sportyweb.Inventory.Unit do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Asset.Location
  alias Sportyweb.Inventory.Article
  alias Sportyweb.Inventory.Rental


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "units" do
    belongs_to :article, Article
    belongs_to :location, Location
    has_many :rentals, Rental
    field :serial_number, :string
    field :purchase_date, :date, default: nil
    field :commission_date, :date, default: nil
    field :decommission_date, :date, default: nil
    field :condition_status, :string, default: "ok"
    field :condition_note, :string, default: nil
    field :damaged_on, :utc_datetime, default: nil
    field :lost_on, :utc_datetime, default: nil

    timestamps(type: :utc_datetime)
  end



  def get_condition_statuses do
  [
    [key: "In Ordnung", value: "ok"],
    [key: "Beschädigt", value: "damaged"],
    [key: "Verloren", value: "lost"]
  ]
  end
  @doc false
def changeset(unit, attrs) do
  unit
  |> cast(attrs, [
    :serial_number,
    :purchase_date,
    :commission_date,
    :decommission_date,
    :article_id,
    :location_id,
    :condition_status,
    :condition_note,
    :damaged_on,
    :lost_on
  ])
  |> validate_required([:serial_number, :article_id, :location_id])
  |> validate_inclusion(:condition_status, ["ok", "damaged", "lost"])
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
  |> maybe_set_condition_dates()
end

  def return_condition_changeset(unit, attrs) do
  unit
  |> cast(attrs, [:condition_status, :condition_note])
  |> validate_inclusion(:condition_status, ["ok", "damaged", "lost"])
  |> maybe_set_condition_dates()
end

defp maybe_set_condition_dates(changeset) do
  now =
    DateTime.utc_now()
    |> DateTime.truncate(:second)

  case get_change(changeset, :condition_status) do
    "damaged" -> put_change(changeset, :damaged_on, now)
    "lost" -> put_change(changeset, :lost_on, now)
    _ -> changeset
  end
end


end
