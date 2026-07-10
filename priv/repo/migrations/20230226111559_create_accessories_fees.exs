defmodule Sportyweb.Repo.Migrations.CreateAccessoriesFees do
  use Ecto.Migration

  def change do
    create table(:accessories_fees, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :accessories_id, references(:accessories, on_delete: :delete_all, type: :binary_id),
        null: false

      add :fee_id, references(:fees, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:accessories_fees, [:accessories_id])
    create unique_index(:accessories_fees, [:fee_id])
  end
end
