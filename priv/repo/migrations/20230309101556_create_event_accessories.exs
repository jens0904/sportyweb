defmodule Sportyweb.Repo.Migrations.CreateEventAccessories do
  use Ecto.Migration

  def change do
    create table(:event_accessories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :delete_all, type: :binary_id), null: false

      add :accessories_id, references(:accessories, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:event_accessories, [:event_id])
    create unique_index(:event_accessories, [:accessories_id])
  end
end
