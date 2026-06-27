defmodule Sportyweb.Repo.Migrations.AddRentalFeeIdToLoans do

  use Ecto.Migration

  def change do
    alter table(:loans) do
      add :rental_fee_id, references(:rental_fees, on_delete: :delete_all, type: :binary_id), null: false
    end

    create index(:loans, [:rental_fee_id])
  end
end
