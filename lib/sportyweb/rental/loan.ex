defmodule Sportyweb.Rental.Loan do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "loans" do
    belongs_to :club, Club
    field :loan_number, :string
    field :return_date, :date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(loan, attrs) do
    loan
    |> cast(attrs, [:loan_number, :return_date, :club_id])
    |> validate_required([:loan_number, :return_date, :club_id])
  end
end
