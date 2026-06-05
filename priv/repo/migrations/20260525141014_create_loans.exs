defmodule Sportyweb.Repo.Migrations.CreateLoans do
  use Ecto.Migration

  def change do
    create table(:loans, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :loan_number, :string
      add :return_date, :date, null: false

      add :article_id, references(:articles, on_delete: :delete_all, type: :binary_id),
        null: false

      add :location_id, references(:locations, on_delete: :delete_all, type: :binary_id),
        null: false

      add :contact_id, references(:contacts, on_delete: :delete_all, type: :binary_id),
        null: false

      add :unit_id, references(:units, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
