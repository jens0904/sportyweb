defmodule Sportyweb.InventoryTest do
  use Sportyweb.DataCase

  alias Sportyweb.Inventory

  describe "categories" do
    alias Sportyweb.Inventory.Category

    import Sportyweb.InventoryFixtures

    @invalid_attrs %{name: nil, description: nil, rental_period: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Inventory.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Inventory.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name", description: "some description", rental_period: 42}

      assert {:ok, %Category{} = category} = Inventory.create_category(valid_attrs)
      assert category.name == "some name"
      assert category.description == "some description"
      assert category.rental_period == 42
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", rental_period: 43}

      assert {:ok, %Category{} = category} = Inventory.update_category(category, update_attrs)
      assert category.name == "some updated name"
      assert category.description == "some updated description"
      assert category.rental_period == 43
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_category(category, @invalid_attrs)
      assert category == Inventory.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Inventory.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Inventory.change_category(category)
    end
  end

  describe "articles" do
    alias Sportyweb.Inventory.Article

    import Sportyweb.InventoryFixtures

    @invalid_attrs %{name: nil, description: nil, reference_number: nil, costs_of_loss: nil}

    test "list_articles/0 returns all articles" do
      article = article_fixture()
      assert Inventory.list_articles() == [article]
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture()
      assert Inventory.get_article!(article.id) == article
    end

    test "create_article/1 with valid data creates a article" do
      valid_attrs = %{name: "some name", description: "some description", reference_number: "some reference_number", costs_of_loss: 42}

      assert {:ok, %Article{} = article} = Inventory.create_article(valid_attrs)
      assert article.name == "some name"
      assert article.description == "some description"
      assert article.reference_number == "some reference_number"
      assert article.costs_of_loss == 42
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_article(@invalid_attrs)
    end

    test "update_article/2 with valid data updates the article" do
      article = article_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", reference_number: "some updated reference_number", costs_of_loss: 43}

      assert {:ok, %Article{} = article} = Inventory.update_article(article, update_attrs)
      assert article.name == "some updated name"
      assert article.description == "some updated description"
      assert article.reference_number == "some updated reference_number"
      assert article.costs_of_loss == 43
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = article_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_article(article, @invalid_attrs)
      assert article == Inventory.get_article!(article.id)
    end

    test "delete_article/1 deletes the article" do
      article = article_fixture()
      assert {:ok, %Article{}} = Inventory.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_article!(article.id) end
    end

    test "change_article/1 returns a article changeset" do
      article = article_fixture()
      assert %Ecto.Changeset{} = Inventory.change_article(article)
    end
  end

  describe "units" do
    alias Sportyweb.Inventory.Unit

    import Sportyweb.InventoryFixtures

    @invalid_attrs %{serial_number: nil, for_lending: nil, for_booking: nil}

    test "list_units/0 returns all units" do
      unit = unit_fixture()
      assert Inventory.list_units() == [unit]
    end

    test "get_unit!/1 returns the unit with given id" do
      unit = unit_fixture()
      assert Inventory.get_unit!(unit.id) == unit
    end

    test "create_unit/1 with valid data creates a unit" do
      valid_attrs = %{serial_number: 42, for_lending: true, for_booking: true}

      assert {:ok, %Unit{} = unit} = Inventory.create_unit(valid_attrs)
      assert unit.serial_number == 42
      assert unit.for_lending == true
      assert unit.for_booking == true
    end

    test "create_unit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_unit(@invalid_attrs)
    end

    test "update_unit/2 with valid data updates the unit" do
      unit = unit_fixture()
      update_attrs = %{serial_number: 43, for_lending: false, for_booking: false}

      assert {:ok, %Unit{} = unit} = Inventory.update_unit(unit, update_attrs)
      assert unit.serial_number == 43
      assert unit.for_lending == false
      assert unit.for_booking == false
    end

    test "update_unit/2 with invalid data returns error changeset" do
      unit = unit_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_unit(unit, @invalid_attrs)
      assert unit == Inventory.get_unit!(unit.id)
    end

    test "delete_unit/1 deletes the unit" do
      unit = unit_fixture()
      assert {:ok, %Unit{}} = Inventory.delete_unit(unit)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_unit!(unit.id) end
    end

    test "change_unit/1 returns a unit changeset" do
      unit = unit_fixture()
      assert %Ecto.Changeset{} = Inventory.change_unit(unit)
    end
  end

  describe "rentals" do
    alias Sportyweb.Inventory.Rental

    import Sportyweb.InventoryFixtures

    @invalid_attrs %{rental_number: nil, return_date: nil}

    test "list_rentals/0 returns all rentals" do
      rental = rental_fixture()
      assert Inventory.list_rentals() == [rental]
    end

    test "get_rental!/1 returns the rental with given id" do
      rental = rental_fixture()
      assert Inventory.get_rental!(rental.id) == rental
    end

    test "create_rental/1 with valid data creates a rental" do
      valid_attrs = %{rental_number: "some rental_number", return_date: ~D[2026-05-24]}

      assert {:ok, %Rental{} = rental} = Inventory.create_rental(valid_attrs)
      assert rental.rental_number == "some rental_number"
      assert rental.return_date == ~D[2026-05-24]
    end

    test "create_rental/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_rental(@invalid_attrs)
    end

    test "update_rental/2 with valid data updates the rental" do
      rental = rental_fixture()
      update_attrs = %{rental_number: "some updated rental_number", return_date: ~D[2026-05-25]}

      assert {:ok, %Rental{} = rental} = Inventory.update_rental(rental, update_attrs)
      assert rental.rental_number == "some updated rental_number"
      assert rental.return_date == ~D[2026-05-25]
    end

    test "update_rental/2 with invalid data returns error changeset" do
      rental = rental_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_rental(rental, @invalid_attrs)
      assert rental == Inventory.get_rental!(rental.id)
    end

    test "delete_rental/1 deletes the rental" do
      rental = rental_fixture()
      assert {:ok, %Rental{}} = Inventory.delete_rental(rental)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_rental!(rental.id) end
    end

    test "change_rental/1 returns a rental changeset" do
      rental = rental_fixture()
      assert %Ecto.Changeset{} = Inventory.change_rental(rental)
    end
  end

  describe "rental_fee" do
    alias Sportyweb.Inventory.RentalFee

    import Sportyweb.InventoryFixtures

    @invalid_attrs %{name: nil}

    test "list_rental_fee/0 returns all rental_fee" do
      rental_fee = rental_fee_fixture()
      assert Inventory.list_rental_fee() == [rental_fee]
    end

    test "get_rental_fee!/1 returns the rental_fee with given id" do
      rental_fee = rental_fee_fixture()
      assert Inventory.get_rental_fee!(rental_fee.id) == rental_fee
    end

    test "create_rental_fee/1 with valid data creates a rental_fee" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %RentalFee{} = rental_fee} = Inventory.create_rental_fee(valid_attrs)
      assert rental_fee.name == "some name"
    end

    test "create_rental_fee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_rental_fee(@invalid_attrs)
    end

    test "update_rental_fee/2 with valid data updates the rental_fee" do
      rental_fee = rental_fee_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %RentalFee{} = rental_fee} = Inventory.update_rental_fee(rental_fee, update_attrs)
      assert rental_fee.name == "some updated name"
    end

    test "update_rental_fee/2 with invalid data returns error changeset" do
      rental_fee = rental_fee_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_rental_fee(rental_fee, @invalid_attrs)
      assert rental_fee == Inventory.get_rental_fee!(rental_fee.id)
    end

    test "delete_rental_fee/1 deletes the rental_fee" do
      rental_fee = rental_fee_fixture()
      assert {:ok, %RentalFee{}} = Inventory.delete_rental_fee(rental_fee)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_rental_fee!(rental_fee.id) end
    end

    test "change_rental_fee/1 returns a rental_fee changeset" do
      rental_fee = rental_fee_fixture()
      assert %Ecto.Changeset{} = Inventory.change_rental_fee(rental_fee)
    end
  end

  describe "rental_rule" do
    alias Sportyweb.Inventory.RentalRule

    import Sportyweb.InventoryFixtures

    @invalid_attrs %{name: nil}

    test "list_rental_rule/0 returns all rental_rule" do
      rental_rule = rental_rule_fixture()
      assert Inventory.list_rental_rule() == [rental_rule]
    end

    test "get_rental_rule!/1 returns the rental_rule with given id" do
      rental_rule = rental_rule_fixture()
      assert Inventory.get_rental_rule!(rental_rule.id) == rental_rule
    end

    test "create_rental_rule/1 with valid data creates a rental_rule" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %RentalRule{} = rental_rule} = Inventory.create_rental_rule(valid_attrs)
      assert rental_rule.name == "some name"
    end

    test "create_rental_rule/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_rental_rule(@invalid_attrs)
    end

    test "update_rental_rule/2 with valid data updates the rental_rule" do
      rental_rule = rental_rule_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %RentalRule{} = rental_rule} = Inventory.update_rental_rule(rental_rule, update_attrs)
      assert rental_rule.name == "some updated name"
    end

    test "update_rental_rule/2 with invalid data returns error changeset" do
      rental_rule = rental_rule_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_rental_rule(rental_rule, @invalid_attrs)
      assert rental_rule == Inventory.get_rental_rule!(rental_rule.id)
    end

    test "delete_rental_rule/1 deletes the rental_rule" do
      rental_rule = rental_rule_fixture()
      assert {:ok, %RentalRule{}} = Inventory.delete_rental_rule(rental_rule)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_rental_rule!(rental_rule.id) end
    end

    test "change_rental_rule/1 returns a rental_rule changeset" do
      rental_rule = rental_rule_fixture()
      assert %Ecto.Changeset{} = Inventory.change_rental_rule(rental_rule)
    end
  end

  describe "rental_rules" do
    alias Sportyweb.Inventory.RentalRule

    import Sportyweb.InventoryFixtures

    @invalid_attrs %{name: nil}

    test "list_rental_rules/0 returns all rental_rules" do
      rental_rule = rental_rule_fixture()
      assert Inventory.list_rental_rules() == [rental_rule]
    end

    test "get_rental_rule!/1 returns the rental_rule with given id" do
      rental_rule = rental_rule_fixture()
      assert Inventory.get_rental_rule!(rental_rule.id) == rental_rule
    end

    test "create_rental_rule/1 with valid data creates a rental_rule" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %RentalRule{} = rental_rule} = Inventory.create_rental_rule(valid_attrs)
      assert rental_rule.name == "some name"
    end

    test "create_rental_rule/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_rental_rule(@invalid_attrs)
    end

    test "update_rental_rule/2 with valid data updates the rental_rule" do
      rental_rule = rental_rule_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %RentalRule{} = rental_rule} = Inventory.update_rental_rule(rental_rule, update_attrs)
      assert rental_rule.name == "some updated name"
    end

    test "update_rental_rule/2 with invalid data returns error changeset" do
      rental_rule = rental_rule_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_rental_rule(rental_rule, @invalid_attrs)
      assert rental_rule == Inventory.get_rental_rule!(rental_rule.id)
    end

    test "delete_rental_rule/1 deletes the rental_rule" do
      rental_rule = rental_rule_fixture()
      assert {:ok, %RentalRule{}} = Inventory.delete_rental_rule(rental_rule)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_rental_rule!(rental_rule.id) end
    end

    test "change_rental_rule/1 returns a rental_rule changeset" do
      rental_rule = rental_rule_fixture()
      assert %Ecto.Changeset{} = Inventory.change_rental_rule(rental_rule)
    end
  end
end
