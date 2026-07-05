defmodule Sportyweb.Repo.Migrations.CreateRentals do
  use Ecto.Migration

  def change do
    create table(:rentals, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :rental_number, :string
      add :rental_date, :utc_datetime, null: false
      add :return_date, :utc_datetime, null: false
      add :renewal_count, :integer, null: false
      add :return_comment, :string
      add :status, :string, null: false
      add :total_fee, :money_with_currency, null: false

      add :article_id, references(:articles, on_delete: :delete_all, type: :binary_id),
        null: false

      add :location_id, references(:locations, on_delete: :delete_all, type: :binary_id),
        null: false

      add :contact_id, references(:contacts, on_delete: :delete_all, type: :binary_id),
        null: false

      add :unit_id, references(:units, on_delete: :delete_all, type: :binary_id), null: false




      timestamps(type: :utc_datetime)
    end

    create unique_index(
      :rentals,
      [:unit_id],
      name: :rentals_unique_active_unit_index
    )
  end
end
