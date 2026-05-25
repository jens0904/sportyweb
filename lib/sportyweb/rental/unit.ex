defmodule Sportyweb.Rental.Unit do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Rental.Article

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "units" do
    belongs_to :article, Article
    field :serial_number, :integer
    field :for_lending, :boolean, default: false
    field :for_booking, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(unit, attrs) do
    unit
    |> cast(attrs, [:serial_number, :for_lending, :for_booking, :article_id])
    |> validate_required([:serial_number, :for_lending, :for_booking, :article_id])
  end
end
