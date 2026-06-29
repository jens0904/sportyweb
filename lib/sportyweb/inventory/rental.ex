defmodule Sportyweb.Inventory.Rental do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Asset.Location
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Inventory.Article
  alias Sportyweb.Inventory.Unit
  alias Sportyweb.Inventory.RentalFee


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "rentals" do
    belongs_to :article, Article
    belongs_to :contact, Contact
    belongs_to :location, Location
    belongs_to :unit, Unit
    field :rental_number, :string
    field :rental_date, :utc_datetime
    field :return_date, :utc_datetime
    field :renewal_count, :integer, default: 0
    field :return_comment, :string
    field :status, :string, default: "returned"
    field :return_time, :time, virtual: true
    field :return_hour, :integer, virtual: true
    field :return_minute, :integer, virtual: true
    timestamps(type: :utc_datetime)
  end

  def get_valid_statuses do
    [
      [key: "Aktiv", value: "active"],
      [key: "Zurückgegeben", value: "returned"],
      [key: "Verloren", value: "lost"]
    ]
  end

  @doc false
  def changeset(rental, attrs, max_return_date \\ nil) do
    rental
    |> cast(attrs, [:return_date, :location_id, :article_id, :unit_id, :contact_id, :rental_date, :renewal_count, :return_comment, :status])
    |> validate_required([:return_date, :location_id, :article_id, :unit_id, :contact_id, :rental_date])
    |> validate_datetimes_order(:rental_date, :return_date, "Das Rückgabedatum muss nach dem Ausleihdatum liegen.")
    |> validate_max_rental_duration(180)
    |> validate_inclusion(:status, get_valid_statuses() |> Enum.map(&(&1[:value])))
    |> validate_return_date_within_max_return_date(max_return_date)
  end

  defp validate_return_date_within_max_return_date(changeset, nil), do: changeset

  defp validate_return_date_within_max_return_date(changeset, max_return_date) do
    return_date = get_field(changeset, :return_date)

    if return_date && DateTime.compare(return_date, max_return_date) == :gt do
      add_error(changeset, :return_date, "darf nicht nach der maximalen Ausleihdauer liegen")
    else
      changeset
    end
  end
end
