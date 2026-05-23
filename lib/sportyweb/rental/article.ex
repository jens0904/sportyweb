defmodule Sportyweb.Rental.Article do
  use Ecto.Schema
  import Ecto.Changeset
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.Department
  alias Sportyweb.Rental.Category

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "articles" do
    belongs_to :club, Club
    field :name, :string
    field :description, :string
    field :reference_number, :string
    field :costs_of_loss, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:name, :description, :reference_number, :costs_of_loss, :club_id])
    |> validate_required([:name, :description, :reference_number, :costs_of_loss, :club_id])
  end
end
