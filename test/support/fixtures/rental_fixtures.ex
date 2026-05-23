defmodule Sportyweb.RentalFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Rental` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        description: "some description",
        loan_period: 42,
        name: "some name"
      })
      |> Sportyweb.Rental.create_category()

    category
  end

  @doc """
  Generate a article.
  """
  def article_fixture(attrs \\ %{}) do
    {:ok, article} =
      attrs
      |> Enum.into(%{
        costs_of_loss: 42,
        description: "some description",
        name: "some name",
        reference_number: "some reference_number"
      })
      |> Sportyweb.Rental.create_article()

    article
  end
end
