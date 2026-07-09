defmodule Sportyweb.Repo.Migrations.CreateRentalRules do
  use Ecto.Migration

  def change do
    create table(:rental_rules, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id),
        null: false
      add :category_id, references(:categories, on_delete: :delete_all, type: :binary_id), null: true
      add :article_id, references(:articles, on_delete: :delete_all, type: :binary_id), null: true

      add :choose_rental_period, :boolean, default: false, null: false
      add :for_club_members, :boolean, default: false, null: false
      add :for_non_members, :boolean, default: false, null: false
      add :allow_renewal, :boolean, default: false, null: false

      add :season_start_date, :date, null: true
      add :season_end_date, :date, null: true

      add :rental_period, :integer
      add :rental_period_unit, :string, default: "days"
      add :archived_at, :utc_datetime, null: true

      add :max_renewals, :integer, default: 2
      add :renewal_period, :integer, default: 7
      timestamps(type: :utc_datetime)


    end


       create unique_index(:rental_rules, [:club_id],
          name: :rental_rules_unique_active_club_rule_index,
          where: "article_id IS NULL AND category_id IS NULL AND archived_at IS NULL"
        )
      create unique_index(:rental_rules, [:category_id],
          name: :rental_rules_unique_active_category_id_index,
          where: "archived_at IS NULL"
        )
      create unique_index(:rental_rules, [:article_id],
          name: :rental_rules_unique_active_article_id_index,
          where: "archived_at IS NULL"
        )
  end
end
