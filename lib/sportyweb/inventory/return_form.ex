defmodule Sportyweb.Inventory.ReturnForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :condition_status, :string
    field :condition_note, :string
  end

  def changeset(return_form, attrs \\ %{}) do
    return_form
    |> cast(attrs, [:condition_status, :condition_note])
    |> validate_required([:condition_status])
    |> validate_inclusion(:condition_status, ["ok", "damaged", "lost"])
  end
end
