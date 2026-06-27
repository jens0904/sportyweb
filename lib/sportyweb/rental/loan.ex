defmodule Sportyweb.Rental.Loan do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Asset.Location
  alias Sportyweb.Finance.Fee
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Rental.Article
  alias Sportyweb.Rental.Unit
  alias Sportyweb.Rental.RentalFee


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "loans" do
    belongs_to :article, Article
    belongs_to :contact, Contact
    belongs_to :location, Location
    belongs_to :unit, Unit
    belongs_to :rental_fee, RentalFee
    field :loan_number, :string
    field :loan_date, :date, default: Date.utc_today()
    field :return_date, :date
    field :renewal_count, :integer, default: 0
    field :return_comment, :string
    field :status, :string, default: "returned"

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
  def changeset(loan, attrs) do
    loan
    |> cast(attrs, [:return_date, :location_id, :article_id, :unit_id, :contact_id, :loan_date, :renewal_count, :return_comment, :status])
    |> validate_required([:return_date, :location_id, :article_id, :unit_id, :contact_id, :loan_date])
    |> validate_dates_order(:loan_date, :return_date, "Das Rückgabedatum muss nach dem Ausleihdatum liegen.")
    |> validate_max_loan_duration(180)
    |> validate_inclusion(:status, get_valid_statuses() |> Enum.map(&(&1[:value])))

  end


end
