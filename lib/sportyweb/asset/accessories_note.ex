defmodule Sportyweb.Asset.AccessoriesNote do
  @moduledoc """
  Associative entity, part of a [polymorphic association with many to many](https://hexdocs.pm/ecto/polymorphic-associations-with-many-to-many.html).
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Accessories
  alias Sportyweb.Polymorphic.Note

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accessories_notes" do
    belongs_to :accessories, Accessories
    belongs_to :note, Note

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(accessories_note, attrs) do
    accessories_note
    |> cast(attrs, [:accessories_id, :note_id])
    |> validate_required([:accessories_id, :note_id])
    |> unique_constraint(:note_id, name: "accessories_notes_note_id_index")
  end
end
