defmodule Sportyweb.Repo.Migrations.CreateCategoryFees do
  use Ecto.Migration

  def change do
    create table(:category_fees, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :category_id, references(:categories, on_delete: :delete_all, type: :binary_id),
        null: false

      add :fee_id, references(:fees, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:category_fees, [:category_id])
    create unique_index(:category_fees, [:fee_id])
  end
end
