defmodule Sportyweb.Repo.Migrations.CreateAccessoriesNotes do
  use Ecto.Migration

  def change do
    create table(:accessories_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :accessories_id, references(:accessories, on_delete: :delete_all, type: :binary_id),
        null: false

      add :note_id, references(:notes, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:accessories_notes, [:accessories_id])
    create unique_index(:accessories_notes, [:note_id])
  end
end
