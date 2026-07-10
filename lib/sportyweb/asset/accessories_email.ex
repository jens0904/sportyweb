defmodule Sportyweb.Asset.AccessoriesEmail do
  @moduledoc """
  Associative entity, part of a [polymorphic association with many to many](https://hexdocs.pm/ecto/polymorphic-associations-with-many-to-many.html).
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Accessories
  alias Sportyweb.Polymorphic.Email

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accessories_emails" do
    belongs_to :accessories, Accessories
    belongs_to :email, Email

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(accessories_email, attrs) do
    accessories_email
    |> cast(attrs, [:accessories_id, :email_id])
    |> validate_required([:accessories_id, :email_id])
    |> unique_constraint(:email_id, name: "accessories_emails_email_id_index")
  end
end
