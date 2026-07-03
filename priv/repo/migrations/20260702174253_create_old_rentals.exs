defmodule Sportyweb.Repo.Migrations.CreateOldRentals do
  use Ecto.Migration

  def change do
      create table(:old_rentals, primary_key: false) do
        add(:id, :binary_id, primary_key: true)

        add(:article_id, references(:articles, on_delete: :restrict, type: :binary_id),
          null: false
        )

        add(:contact_id, references(:contacts, on_delete: :restrict, type: :binary_id),
          null: false
        )

        add :location_id, references(:locations, on_delete: :restrict, type: :binary_id),
          null: false


        add :unit_id, references(:units, on_delete: :restrict, type: :binary_id), null: false

        add :rental_date, :utc_datetime, null: false
        add :return_date, :utc_datetime, null: false
        add :renewal_count, :integer, default: 0, null: false
        add :return_comment, :text
        add :total_fee, :money_with_currency, null: false

        add :returned_at, :utc_datetime, null: false
        add :fee_required, :boolean, null: false

        add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

        timestamps(type: :utc_datetime)
      end

      create index(:old_rentals, [:article_id])
      create index(:old_rentals, [:contact_id])
      create index(:old_rentals, [:location_id])
      create index(:old_rentals, [:unit_id])
      create index(:old_rentals, [:club_id])
      create index(:old_rentals, [:returned_at])
    end
  end
