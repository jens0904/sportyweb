defmodule Sportyweb.Rental.Loan do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Location
  alias Sportyweb.Organization.Club
  alias Sportyweb.Rental.Article

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "loans" do
    belongs_to :club, Club
    belongs_to :article, Article
    belongs_to :location, Location
    field :loan_number, :string
    field :return_date, :date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(loan, attrs) do
    loan
    |> cast(attrs, [:loan_number, :return_date, :club_id, :location_id, :article_id])
    |> validate_required([:loan_number, :return_date, :club_id, :location_id, :article_id])
  end
end
