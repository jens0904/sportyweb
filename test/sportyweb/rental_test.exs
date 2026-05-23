defmodule Sportyweb.RentalTest do
  use Sportyweb.DataCase

  alias Sportyweb.Rental

  describe "categories" do
    alias Sportyweb.Rental.Category

    import Sportyweb.RentalFixtures

    @invalid_attrs %{name: nil, description: nil, loan_period: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Rental.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Rental.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name", description: "some description", loan_period: 42}

      assert {:ok, %Category{} = category} = Rental.create_category(valid_attrs)
      assert category.name == "some name"
      assert category.description == "some description"
      assert category.loan_period == 42
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rental.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", loan_period: 43}

      assert {:ok, %Category{} = category} = Rental.update_category(category, update_attrs)
      assert category.name == "some updated name"
      assert category.description == "some updated description"
      assert category.loan_period == 43
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Rental.update_category(category, @invalid_attrs)
      assert category == Rental.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Rental.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Rental.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Rental.change_category(category)
    end
  end

  describe "articles" do
    alias Sportyweb.Rental.Article

    import Sportyweb.RentalFixtures

    @invalid_attrs %{name: nil, description: nil, reference_number: nil, costs_of_loss: nil}

    test "list_articles/0 returns all articles" do
      article = article_fixture()
      assert Rental.list_articles() == [article]
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture()
      assert Rental.get_article!(article.id) == article
    end

    test "create_article/1 with valid data creates a article" do
      valid_attrs = %{name: "some name", description: "some description", reference_number: "some reference_number", costs_of_loss: 42}

      assert {:ok, %Article{} = article} = Rental.create_article(valid_attrs)
      assert article.name == "some name"
      assert article.description == "some description"
      assert article.reference_number == "some reference_number"
      assert article.costs_of_loss == 42
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rental.create_article(@invalid_attrs)
    end

    test "update_article/2 with valid data updates the article" do
      article = article_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", reference_number: "some updated reference_number", costs_of_loss: 43}

      assert {:ok, %Article{} = article} = Rental.update_article(article, update_attrs)
      assert article.name == "some updated name"
      assert article.description == "some updated description"
      assert article.reference_number == "some updated reference_number"
      assert article.costs_of_loss == 43
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = article_fixture()
      assert {:error, %Ecto.Changeset{}} = Rental.update_article(article, @invalid_attrs)
      assert article == Rental.get_article!(article.id)
    end

    test "delete_article/1 deletes the article" do
      article = article_fixture()
      assert {:ok, %Article{}} = Rental.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> Rental.get_article!(article.id) end
    end

    test "change_article/1 returns a article changeset" do
      article = article_fixture()
      assert %Ecto.Changeset{} = Rental.change_article(article)
    end
  end
end
