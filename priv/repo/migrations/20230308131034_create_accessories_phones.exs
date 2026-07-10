defmodule Sportyweb.Repo.Migrations.CreateAccessoriesPhones do
  use Ecto.Migration

  def change do
    create table(:accessories_phones, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :accessories_id, references(:accessories, on_delete: :delete_all, type: :binary_id),
        null: false

      add :phone_id, references(:phones, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:accessories_phones, [:accessories_id])
    create unique_index(:accessories_phones, [:phone_id])
  end
end
