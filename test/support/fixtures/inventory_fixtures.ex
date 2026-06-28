defmodule Sportyweb.InventoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Inventory` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        description: "some description",
        rental_period: 42,
        name: "some name"
      })
      |> Sportyweb.Inventory.create_category()

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
      |> Sportyweb.Inventory.create_article()

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
      |> Sportyweb.Inventory.create_unit()

    unit
  end

  @doc """
  Generate a rental.
  """
  def rental_fixture(attrs \\ %{}) do
    {:ok, rental} =
      attrs
      |> Enum.into(%{
        rental_number: "some rental_number",
        return_date: ~D[2026-05-24]
      })
      |> Sportyweb.Inventory.create_rental()

    rental
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
      |> Sportyweb.Inventory.create_rental_fee()

    rental_fee
  end

  @doc """
  Generate a rental_rule.
  """
  def rental_rule_fixture(attrs \\ %{}) do
    {:ok, rental_rule} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Sportyweb.Inventory.create_rental_rule()

    rental_rule
  end
end
