defmodule Sportyweb.Repo.Migrations.CreateCategoryRentalFee do
  use Ecto.Migration

  def change do
    create table(:category_rental_fees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :category_id, references(:categories, on_delete: :delete_all, type: :binary_id), null: false

      add :rental_fee_id, references(:rental_fees, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:category_rental_fees, [:category_id])
    create index(:category_rental_fees, [:rental_fee_id])
  end
end
