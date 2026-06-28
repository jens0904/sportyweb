defmodule Sportyweb.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text, null: false
      add :reference_number, :string, null: false
      add :costs_of_loss, :money_with_currency, null: false
      add :choose_rental_period, :boolean, default: false
      add :for_club_members, :boolean, default: false
      add :for_non_members, :boolean, default: false
      add :rental_period, :integer, null: true
      add :rental_period_unit, :string, null: true
      add :allow_renewal, :boolean, default: false
      add :max_renewals, :integer
      add :renewal_period, :integer

      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

      add :department_id, references(:departments, on_delete: :nilify_all, type: :binary_id),
        null: true

      add :category_id, references(:categories, on_delete: :nilify_all, type: :binary_id),
        null: true

      timestamps(type: :utc_datetime)
    end
  end
end
