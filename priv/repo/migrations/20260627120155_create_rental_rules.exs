defmodule Sportyweb.Repo.Migrations.CreateRentalRules do
  use Ecto.Migration

  def change do
    create table(:rental_rules, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id),
        null: false
      add :category_id, references(:categories, on_delete: :delete_all, type: :binary_id), null: true
      add :article_id, references(:articles, on_delete: :delete_all, type: :binary_id), null: true

      add :choose_loan_period, :boolean, default: false, null: false
      add :for_club_members, :boolean, default: false, null: false
      add :for_non_members, :boolean, default: false, null: false
      add :allow_renewal, :boolean, default: false, null: false

      add :loan_period, :integer
      add :loan_period_unit, :string, default: "days"

      add :max_renewals, :integer, default: 2
      add :renewal_period, :integer, default: 7
      timestamps(type: :utc_datetime)
    end
  end
end
