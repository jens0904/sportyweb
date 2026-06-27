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

  describe "units" do
    alias Sportyweb.Rental.Unit

    import Sportyweb.RentalFixtures

    @invalid_attrs %{serial_number: nil, for_lending: nil, for_booking: nil}

    test "list_units/0 returns all units" do
      unit = unit_fixture()
      assert Rental.list_units() == [unit]
    end

    test "get_unit!/1 returns the unit with given id" do
      unit = unit_fixture()
      assert Rental.get_unit!(unit.id) == unit
    end

    test "create_unit/1 with valid data creates a unit" do
      valid_attrs = %{serial_number: 42, for_lending: true, for_booking: true}

      assert {:ok, %Unit{} = unit} = Rental.create_unit(valid_attrs)
      assert unit.serial_number == 42
      assert unit.for_lending == true
      assert unit.for_booking == true
    end

    test "create_unit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rental.create_unit(@invalid_attrs)
    end

    test "update_unit/2 with valid data updates the unit" do
      unit = unit_fixture()
      update_attrs = %{serial_number: 43, for_lending: false, for_booking: false}

      assert {:ok, %Unit{} = unit} = Rental.update_unit(unit, update_attrs)
      assert unit.serial_number == 43
      assert unit.for_lending == false
      assert unit.for_booking == false
    end

    test "update_unit/2 with invalid data returns error changeset" do
      unit = unit_fixture()
      assert {:error, %Ecto.Changeset{}} = Rental.update_unit(unit, @invalid_attrs)
      assert unit == Rental.get_unit!(unit.id)
    end

    test "delete_unit/1 deletes the unit" do
      unit = unit_fixture()
      assert {:ok, %Unit{}} = Rental.delete_unit(unit)
      assert_raise Ecto.NoResultsError, fn -> Rental.get_unit!(unit.id) end
    end

    test "change_unit/1 returns a unit changeset" do
      unit = unit_fixture()
      assert %Ecto.Changeset{} = Rental.change_unit(unit)
    end
  end

  describe "loans" do
    alias Sportyweb.Rental.Loan

    import Sportyweb.RentalFixtures

    @invalid_attrs %{loan_number: nil, return_date: nil}

    test "list_loans/0 returns all loans" do
      loan = loan_fixture()
      assert Rental.list_loans() == [loan]
    end

    test "get_loan!/1 returns the loan with given id" do
      loan = loan_fixture()
      assert Rental.get_loan!(loan.id) == loan
    end

    test "create_loan/1 with valid data creates a loan" do
      valid_attrs = %{loan_number: "some loan_number", return_date: ~D[2026-05-24]}

      assert {:ok, %Loan{} = loan} = Rental.create_loan(valid_attrs)
      assert loan.loan_number == "some loan_number"
      assert loan.return_date == ~D[2026-05-24]
    end

    test "create_loan/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rental.create_loan(@invalid_attrs)
    end

    test "update_loan/2 with valid data updates the loan" do
      loan = loan_fixture()
      update_attrs = %{loan_number: "some updated loan_number", return_date: ~D[2026-05-25]}

      assert {:ok, %Loan{} = loan} = Rental.update_loan(loan, update_attrs)
      assert loan.loan_number == "some updated loan_number"
      assert loan.return_date == ~D[2026-05-25]
    end

    test "update_loan/2 with invalid data returns error changeset" do
      loan = loan_fixture()
      assert {:error, %Ecto.Changeset{}} = Rental.update_loan(loan, @invalid_attrs)
      assert loan == Rental.get_loan!(loan.id)
    end

    test "delete_loan/1 deletes the loan" do
      loan = loan_fixture()
      assert {:ok, %Loan{}} = Rental.delete_loan(loan)
      assert_raise Ecto.NoResultsError, fn -> Rental.get_loan!(loan.id) end
    end

    test "change_loan/1 returns a loan changeset" do
      loan = loan_fixture()
      assert %Ecto.Changeset{} = Rental.change_loan(loan)
    end
  end

  describe "rental_fee" do
    alias Sportyweb.Rental.RentalFee

    import Sportyweb.RentalFixtures

    @invalid_attrs %{name: nil}

    test "list_rental_fee/0 returns all rental_fee" do
      rental_fee = rental_fee_fixture()
      assert Rental.list_rental_fee() == [rental_fee]
    end

    test "get_rental_fee!/1 returns the rental_fee with given id" do
      rental_fee = rental_fee_fixture()
      assert Rental.get_rental_fee!(rental_fee.id) == rental_fee
    end

    test "create_rental_fee/1 with valid data creates a rental_fee" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %RentalFee{} = rental_fee} = Rental.create_rental_fee(valid_attrs)
      assert rental_fee.name == "some name"
    end

    test "create_rental_fee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rental.create_rental_fee(@invalid_attrs)
    end

    test "update_rental_fee/2 with valid data updates the rental_fee" do
      rental_fee = rental_fee_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %RentalFee{} = rental_fee} = Rental.update_rental_fee(rental_fee, update_attrs)
      assert rental_fee.name == "some updated name"
    end

    test "update_rental_fee/2 with invalid data returns error changeset" do
      rental_fee = rental_fee_fixture()
      assert {:error, %Ecto.Changeset{}} = Rental.update_rental_fee(rental_fee, @invalid_attrs)
      assert rental_fee == Rental.get_rental_fee!(rental_fee.id)
    end

    test "delete_rental_fee/1 deletes the rental_fee" do
      rental_fee = rental_fee_fixture()
      assert {:ok, %RentalFee{}} = Rental.delete_rental_fee(rental_fee)
      assert_raise Ecto.NoResultsError, fn -> Rental.get_rental_fee!(rental_fee.id) end
    end

    test "change_rental_fee/1 returns a rental_fee changeset" do
      rental_fee = rental_fee_fixture()
      assert %Ecto.Changeset{} = Rental.change_rental_fee(rental_fee)
    end
  end

  describe "rental_rule" do
    alias Sportyweb.Rental.RentalRule

    import Sportyweb.RentalFixtures

    @invalid_attrs %{name: nil}

    test "list_rental_rule/0 returns all rental_rule" do
      rental_rule = rental_rule_fixture()
      assert Rental.list_rental_rule() == [rental_rule]
    end

    test "get_rental_rule!/1 returns the rental_rule with given id" do
      rental_rule = rental_rule_fixture()
      assert Rental.get_rental_rule!(rental_rule.id) == rental_rule
    end

    test "create_rental_rule/1 with valid data creates a rental_rule" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %RentalRule{} = rental_rule} = Rental.create_rental_rule(valid_attrs)
      assert rental_rule.name == "some name"
    end

    test "create_rental_rule/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rental.create_rental_rule(@invalid_attrs)
    end

    test "update_rental_rule/2 with valid data updates the rental_rule" do
      rental_rule = rental_rule_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %RentalRule{} = rental_rule} = Rental.update_rental_rule(rental_rule, update_attrs)
      assert rental_rule.name == "some updated name"
    end

    test "update_rental_rule/2 with invalid data returns error changeset" do
      rental_rule = rental_rule_fixture()
      assert {:error, %Ecto.Changeset{}} = Rental.update_rental_rule(rental_rule, @invalid_attrs)
      assert rental_rule == Rental.get_rental_rule!(rental_rule.id)
    end

    test "delete_rental_rule/1 deletes the rental_rule" do
      rental_rule = rental_rule_fixture()
      assert {:ok, %RentalRule{}} = Rental.delete_rental_rule(rental_rule)
      assert_raise Ecto.NoResultsError, fn -> Rental.get_rental_rule!(rental_rule.id) end
    end

    test "change_rental_rule/1 returns a rental_rule changeset" do
      rental_rule = rental_rule_fixture()
      assert %Ecto.Changeset{} = Rental.change_rental_rule(rental_rule)
    end
  end

  describe "rental_rules" do
    alias Sportyweb.Rental.RentalRule

    import Sportyweb.RentalFixtures

    @invalid_attrs %{name: nil}

    test "list_rental_rules/0 returns all rental_rules" do
      rental_rule = rental_rule_fixture()
      assert Rental.list_rental_rules() == [rental_rule]
    end

    test "get_rental_rule!/1 returns the rental_rule with given id" do
      rental_rule = rental_rule_fixture()
      assert Rental.get_rental_rule!(rental_rule.id) == rental_rule
    end

    test "create_rental_rule/1 with valid data creates a rental_rule" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %RentalRule{} = rental_rule} = Rental.create_rental_rule(valid_attrs)
      assert rental_rule.name == "some name"
    end

    test "create_rental_rule/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rental.create_rental_rule(@invalid_attrs)
    end

    test "update_rental_rule/2 with valid data updates the rental_rule" do
      rental_rule = rental_rule_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %RentalRule{} = rental_rule} = Rental.update_rental_rule(rental_rule, update_attrs)
      assert rental_rule.name == "some updated name"
    end

    test "update_rental_rule/2 with invalid data returns error changeset" do
      rental_rule = rental_rule_fixture()
      assert {:error, %Ecto.Changeset{}} = Rental.update_rental_rule(rental_rule, @invalid_attrs)
      assert rental_rule == Rental.get_rental_rule!(rental_rule.id)
    end

    test "delete_rental_rule/1 deletes the rental_rule" do
      rental_rule = rental_rule_fixture()
      assert {:ok, %RentalRule{}} = Rental.delete_rental_rule(rental_rule)
      assert_raise Ecto.NoResultsError, fn -> Rental.get_rental_rule!(rental_rule.id) end
    end

    test "change_rental_rule/1 returns a rental_rule changeset" do
      rental_rule = rental_rule_fixture()
      assert %Ecto.Changeset{} = Rental.change_rental_rule(rental_rule)
    end
  end
end
