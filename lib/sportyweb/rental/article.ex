defmodule Sportyweb.Rental.Article do
  use Ecto.Schema
  import Ecto.Changeset
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.Department
  alias Sportyweb.Rental.Category
  alias Sportyweb.Rental.Unit
  alias Sportyweb.Rental.Loan

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "articles" do
    belongs_to :club, Club
    belongs_to :department, Department
    has_many :units, Unit
    has_many :loans, Loan
    field :name, :string
    field :description, :string
    field :reference_number, :string
    field :costs_of_loss, Money.Ecto.Composite.Type, default_currency: :EUR

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [
      :name,
      :description,
      :reference_number,
      :costs_of_loss,
      :club_id,
      :department_id
    ])
    |> validate_required([
      :name,
      :description,
      :reference_number,
      :costs_of_loss,
      :club_id
    ])
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
  end
end
