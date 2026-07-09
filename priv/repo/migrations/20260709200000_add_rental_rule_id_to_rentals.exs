defmodule Sportyweb.Repo.Migrations.AddRentalRuleIdToRentals do

  use Ecto.Migration

  def change do
    alter table(:rentals) do
      add :rental_rule_id, references(:rental_rules, on_delete: :restrict, type: :binary_id), null: false

    end

    create index(:rentals, [:rental_rule_id])
    create index(:rental_rules, [:archived_at])
  end
end
