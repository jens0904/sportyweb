defmodule Sportyweb.Rental.Loan do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Location
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Rental.Article
  alias Sportyweb.Rental.Unit

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "loans" do
    belongs_to :article, Article
    belongs_to :contact, Contact
    belongs_to :location, Location
    belongs_to :unit, Unit
    field :loan_number, :string
    field :return_date, :date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(loan, attrs) do
    loan
    |> cast(attrs, [:return_date, :location_id, :article_id, :unit_id, :contact_id])
    |> validate_required([:return_date, :location_id, :article_id, :unit_id, :contact_id])
  end
end
