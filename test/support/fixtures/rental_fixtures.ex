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

  @doc """
  Generate a unit.
  """
  def unit_fixture(attrs \\ %{}) do
    {:ok, unit} =
      attrs
      |> Enum.into(%{
        for_booking: true,
        for_lending: true,
        serial_number: 42
      })
      |> Sportyweb.Rental.create_unit()

    unit
  end

  @doc """
  Generate a loan.
  """
  def loan_fixture(attrs \\ %{}) do
    {:ok, loan} =
      attrs
      |> Enum.into(%{
        loan_number: "some loan_number",
        return_date: ~D[2026-05-24]
      })
      |> Sportyweb.Rental.create_loan()

    loan
  end

  @doc """
  Generate a rental_fee.
  """
  def rental_fee_fixture(attrs \\ %{}) do
    {:ok, rental_fee} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Sportyweb.Rental.create_rental_fee()

    rental_fee
  end
end
