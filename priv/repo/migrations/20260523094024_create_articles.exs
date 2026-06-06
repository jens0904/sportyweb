defmodule Sportyweb.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :text
      add :reference_number, :string
      add :costs_of_loss, :money_with_currency
      add :loan_period, :integer
      add :allow_renewal, :boolean, default: false

      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

      add :department_id, references(:departments, on_delete: :nilify_all, type: :binary_id),
        null: true

      add :category_id, references(:categories, on_delete: :nilify_all, type: :binary_id),
        null: true

      timestamps(type: :utc_datetime)
    end
  end
end
