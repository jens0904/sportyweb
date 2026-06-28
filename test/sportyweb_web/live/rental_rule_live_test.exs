defmodule SportywebWeb.RentalRuleLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.InventoryFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_rental_rule(_) do
    rental_rule = rental_rule_fixture()
    %{rental_rule: rental_rule}
  end

  describe "Index" do
    setup [:create_rental_rule]

    test "lists all rental_rules", %{conn: conn, rental_rule: rental_rule} do
      {:ok, _index_live, html} = live(conn, ~p"/rental_rules")

      assert html =~ "Listing Rental rules"
      assert html =~ rental_rule.name
    end

    test "saves new rental_rule", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/rental_rules")

      assert index_live |> element("a", "New Rental rule") |> render_click() =~
               "New Rental rule"

      assert_patch(index_live, ~p"/rental_rules/new")

      assert index_live
             |> form("#rental_rule-form", rental_rule: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#rental_rule-form", rental_rule: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/rental_rules")

      html = render(index_live)
      assert html =~ "Rental rule created successfully"
      assert html =~ "some name"
    end

    test "updates rental_rule in listing", %{conn: conn, rental_rule: rental_rule} do
      {:ok, index_live, _html} = live(conn, ~p"/rental_rules")

      assert index_live |> element("#rental_rules-#{rental_rule.id} a", "Edit") |> render_click() =~
               "Edit Rental rule"

      assert_patch(index_live, ~p"/rental_rules/#{rental_rule}/edit")

      assert index_live
             |> form("#rental_rule-form", rental_rule: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#rental_rule-form", rental_rule: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/rental_rules")

      html = render(index_live)
      assert html =~ "Rental rule updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes rental_rule in listing", %{conn: conn, rental_rule: rental_rule} do
      {:ok, index_live, _html} = live(conn, ~p"/rental_rules")

      assert index_live |> element("#rental_rules-#{rental_rule.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#rental_rules-#{rental_rule.id}")
    end
  end

  describe "Show" do
    setup [:create_rental_rule]

    test "displays rental_rule", %{conn: conn, rental_rule: rental_rule} do
      {:ok, _show_live, html} = live(conn, ~p"/rental_rules/#{rental_rule}")

      assert html =~ "Show Rental rule"
      assert html =~ rental_rule.name
    end

    test "updates rental_rule within modal", %{conn: conn, rental_rule: rental_rule} do
      {:ok, show_live, _html} = live(conn, ~p"/rental_rules/#{rental_rule}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Rental rule"

      assert_patch(show_live, ~p"/rental_rules/#{rental_rule}/show/edit")

      assert show_live
             |> form("#rental_rule-form", rental_rule: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#rental_rule-form", rental_rule: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/rental_rules/#{rental_rule}")

      html = render(show_live)
      assert html =~ "Rental rule updated successfully"
      assert html =~ "some updated name"
    end
  end
end
