defmodule Sportyweb.Repo.Migrations.CreateUnits do
  use Ecto.Migration

  def change do
    create table(:units, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :serial_number, :integer, null: false
      add :for_lending, :boolean, default: false, null: false
      add :for_booking, :boolean, default: false, null: false

      add :article_id, references(:articles, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end
  end
end
