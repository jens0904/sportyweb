defmodule Sportyweb.Repo.Migrations.CreateArticleRentalFee do
  use Ecto.Migration

  def change do
    create table(:article_rental_fees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :article_id, references(:articles, on_delete: :delete_all, type: :binary_id), null: false

      add :rental_fee_id, references(:rental_fees, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:article_rental_fees, [:article_id])
    create index(:article_rental_fees, [:rental_fee_id])
  end
end
