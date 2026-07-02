defmodule Sportyweb.Repo.Migrations.CreateRentalFee do
  use Ecto.Migration

  def change do
    create table(:rental_fees, primary_key: false) do
       add :id, :binary_id, primary_key: true
       add :name, :string, null: false, default: ""

       add :member_type, :string, null: false

      add :amount_currency, :string, null: false, default: "EUR"
      add :amount, :money_with_currency, null: false


      add :minimum_age_in_years, :integer, null: true
      add :maximum_age_in_years, :integer, null: true
      add :flat_fee, :boolean, default: false, null: false

      add :rental_duration, :string, null: false

      add :category_id, references(:categories, on_delete: :delete_all, type: :binary_id)
      add :article_id, references(:articles, on_delete: :delete_all, type: :binary_id)

      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id),
        null: false

      add :successor_id, references(:rental_fees, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:rental_fees, [:successor_id])
  end
end
