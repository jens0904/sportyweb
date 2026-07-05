defmodule Sportyweb.Inventory.OldRentals do
  use Ecto.Schema
  import Ecto.Changeset
  alias Sportyweb.Organization.Club
  alias Sportyweb.Inventory.Article
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Asset.Location
  alias Sportyweb.Inventory.Unit

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "old_rentals" do
    belongs_to :article, Article
    belongs_to :club, Club
    belongs_to :contact, Contact
    belongs_to :location, Location
    belongs_to :unit, Unit

    field :rental_date, :utc_datetime
    field :return_date, :utc_datetime
    field :renewal_count, :integer, default: 0
    field :return_comment, :string
    field :total_fee, Money.Ecto.Composite.Type, default_currency: :EUR
    field :vat_fee, Money.Ecto.Composite.Type, default_currency: :EUR
    # Zeitpunkt der tatsächlichen Rückgabe/Archivierung
    field :returned_at, :utc_datetime

    field :fee_required, :boolean, default: false
    field :condition_status, :string
    field :condition_note, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(old_rental, attrs) do
    old_rental
    |> cast(attrs, [
      :article_id,
      :contact_id,
      :club_id,
      :location_id,
      :unit_id,
      :rental_date,
      :return_date,
      :renewal_count,
      :return_comment,
      :returned_at,
      :fee_required,
      :total_fee,
      :vat_fee,
      :condition_status,
      :condition_note
    ])
    |> validate_required([
      :article_id,
      :contact_id,
      :location_id,
      :unit_id,
      :rental_date,
      :return_date,
      :returned_at,
      :condition_status
    ])
  end

  def condition_status_label(%__MODULE__{condition_status: status}) do
    condition_status_label(status)
  end

  def condition_status_label("ok"), do: "In Ordnung"
  def condition_status_label("damaged"), do: "Beschädigt"
  def condition_status_label("lost"), do: "Verloren"
  def condition_status_label(_), do: "-"
end
