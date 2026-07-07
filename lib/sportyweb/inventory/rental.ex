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
    belongs_to :rental_fee, RentalFee
    field :rental_date, :utc_datetime
    field :return_date, :utc_datetime
    field :renewal_count, :integer, default: 0
    field :return_comment, :string
    field :status, :string, default: "returned"
    field :return_time, :time, virtual: true
    field :total_fee, Money.Ecto.Composite.Type, default_currency: :EUR
    field :returned_at, :utc_datetime, default: nil
    field :vat_fee, Money.Ecto.Composite.Type, default_currency: :EUR
    field :fee_required, :boolean, default: false
    field :condition_status, :string, default: "ok"
    field :condition_note, :string

    timestamps(type: :utc_datetime)
  end

  def get_valid_statuses do
  [
    [key: "Aktiv", value: "active"],
    [key: "Zurückgegeben", value: "returned"]
  ]
end

def get_condition_statuses do
  [
    [key: "In Ordnung", value: "ok"],
    [key: "Beschädigt", value: "damaged"],
    [key: "Verloren", value: "lost"]
  ]
end

  @doc false
  def changeset(rental, attrs, max_return_date \\ nil, rental_rule \\ nil) do
    rental
    |> cast(attrs, [
      :return_date,
      :location_id,
      :article_id,
      :unit_id,
      :contact_id,
      :rental_date,
      :renewal_count,
      :return_comment,
      :status,
      :total_fee,
      :rental_fee_id,
      :returned_at,
      :vat_fee,
      :fee_required,
      :condition_status,
      :condition_note
    ])
    |> validate_required([
      :return_date,
      :location_id,
      :article_id,
      :unit_id,
      :contact_id,
      :rental_date,
      :total_fee,
      :rental_fee_id
    ])
    |> validate_datetimes_order(
      :rental_date,
      :return_date,
      "Das Rückgabedatum muss nach dem Ausleihdatum liegen."
    )
    |> validate_return_date_after_previous_return_date(rental.return_date)
    |> validate_inclusion(:status, get_valid_statuses() |> Enum.map(& &1[:value]))
    |> validate_return_date_within_max_return_date(max_return_date)
    |> validate_same_weekday_for_weekly_rental(rental_rule)
    |> validate_rental_date_in_season(rental_rule)
    |> unique_constraint(
      :unit_id,
      name: :rentals_unique_active_unit_index
    )
  end

  def return_changeset(rental, attrs) do
    rental
    |> cast(attrs, [
      :status,
      :return_date,
      :returned_at,
      :return_comment,
      :total_fee,
      :vat_fee,
      :fee_required,
      :condition_status,
      :condition_note
    ])
    |> validate_required([:status, :return_date, :returned_at])
    |> validate_inclusion(:status, ["active", "returned"])
    |> validate_inclusion(:condition_status, ["ok", "damaged", "lost"])
  end

  def active?(%__MODULE__{status: "active"}), do: true
  def active?(_), do: false

  def inactive?(%__MODULE__{status: "returned"}), do: true
def inactive?(_), do: false

  defp validate_same_weekday_for_weekly_rental(changeset, %{rental_period_unit: "Wochen"}) do
    rental_date = get_field(changeset, :rental_date)
    return_date = get_field(changeset, :return_date)

    if rental_date &&
         return_date &&
         Date.day_of_week(DateTime.to_date(rental_date)) !=
           Date.day_of_week(DateTime.to_date(return_date)) do
      add_error(
        changeset,
        :return_date,
        "muss auf denselben Wochentag wie das Ausleihdatum fallen"
      )
    else
      changeset
    end
  end

  defp validate_same_weekday_for_weekly_rental(changeset, _), do: changeset

  defp validate_return_date_within_max_return_date(changeset, nil), do: changeset

  defp validate_return_date_within_max_return_date(changeset, max_return_date) do
    return_date = get_field(changeset, :return_date)

    if return_date &&
         DateTime.compare(return_date, max_return_date) == :gt do
      add_error(
        changeset,
        :return_date,
        "darf nicht nach der maximalen Ausleihdauer liegen"
      )
    else
      changeset
    end
  end

  defp validate_return_date_after_previous_return_date(changeset, nil), do: changeset

  defp validate_return_date_after_previous_return_date(changeset, previous_return_date) do
    new_return_date = get_field(changeset, :return_date)

    if new_return_date && DateTime.compare(new_return_date, previous_return_date) == :lt do
      add_error(
        changeset,
        :return_date,
        "darf nicht vor dem bisherigen Rückgabedatum liegen"
      )
    else
      changeset
    end
  end

  defp validate_rental_date_in_season(changeset, %{rental_period_unit: "Saison"} = rental_rule) do
    rental_date = get_field(changeset, :rental_date)
    season_start_date = rental_rule.season_start_date
    season_end_date = rental_rule.season_end_date

    if rental_date &&
         season_start_date &&
         season_end_date &&
         Date.compare(DateTime.to_date(rental_date), season_start_date) in [:eq, :gt] &&
         Date.compare(DateTime.to_date(rental_date), season_end_date) in [:eq, :lt] do
      changeset
    else
      add_error(changeset, :rental_date, "liegt außerhalb der Saison")
    end
  end

  defp validate_rental_date_in_season(changeset, _), do: changeset
end
