defmodule Sportyweb.Repo.Migrations.AddRentalFeeIdToRentals do

  use Ecto.Migration

  def change do
    alter table(:rentals) do
      add :rental_fee_id, references(:rental_fees, on_delete: :delete_all, type: :binary_id), null: false
    end

    create index(:rentals, [:rental_fee_id])
  end
end
