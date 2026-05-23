defmodule Sportyweb.Rental.Category do
  use Ecto.Schema
  import Ecto.Changeset
  alias Sportyweb.Organization.Club

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "categories" do
    belongs_to :club, Club
    field :name, :string
    field :description, :string
    field :loan_period, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description, :loan_period, :club_id])
    |> validate_required([:name, :description, :loan_period, :club_id])
  end
end
