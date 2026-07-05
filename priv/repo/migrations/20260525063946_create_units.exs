defmodule Sportyweb.Repo.Migrations.CreateUnits do
  use Ecto.Migration

  def change do
    create table(:units, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :serial_number, :string, null: false
      add :for_lending, :boolean, default: true, null: false
      add :purchase_date, :date, null: true
      add :commission_date, :date, null: true
      add :decommission_date, :date, null: true

      add :article_id, references(:articles, on_delete: :delete_all, type: :binary_id),
        null: false

      add :location_id, references(:locations, on_delete: :delete_all, type: :binary_id),
        null: false

      add :condition_status, :string, null: false
      add :condition_note, :string, null: true
      add :damaged_on, :utc_datetime, null: true
      add :lost_on, :utc_datetime, null: true

      timestamps(type: :utc_datetime)
    end
  end
end
