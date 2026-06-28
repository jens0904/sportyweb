defmodule SportywebWeb.RentalLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.InventoryFixtures

  @create_attrs %{rental_number: "some rental_number", return_date: "2026-05-24"}
  @update_attrs %{rental_number: "some updated rental_number", return_date: "2026-05-25"}
  @invalid_attrs %{rental_number: nil, return_date: nil}

  defp create_rental(_) do
    rental = rental_fixture()
    %{rental: rental}
  end

  describe "Index" do
    setup [:create_rental]

    test "lists all rentals", %{conn: conn, rental: rental} do
      {:ok, _index_live, html} = live(conn, ~p"/rentals")

      assert html =~ "Listing Rentals"
      assert html =~ rental.rental_number
    end

    test "saves new rental", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/rentals")

      assert index_live |> element("a", "New Rental") |> render_click() =~
               "New Rental"

      assert_patch(index_live, ~p"/rentals/new")

      assert index_live
             |> form("#rental-form", rental: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#rental-form", rental: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/rentals")

      html = render(index_live)
      assert html =~ "Rental created successfully"
      assert html =~ "some rental_number"
    end

    test "updates rental in listing", %{conn: conn, rental: rental} do
      {:ok, index_live, _html} = live(conn, ~p"/rentals")

      assert index_live |> element("#rentals-#{rental.id} a", "Edit") |> render_click() =~
               "Edit Rental"

      assert_patch(index_live, ~p"/rentals/#{rental}/edit")

      assert index_live
             |> form("#rental-form", rental: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#rental-form", rental: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/rentals")

      html = render(index_live)
      assert html =~ "Rental updated successfully"
      assert html =~ "some updated rental_number"
    end

    test "deletes rental in listing", %{conn: conn, rental: rental} do
      {:ok, index_live, _html} = live(conn, ~p"/rentals")

      assert index_live |> element("#rentals-#{rental.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#rentals-#{rental.id}")
    end
  end

  describe "Show" do
    setup [:create_rental]

    test "displays rental", %{conn: conn, rental: rental} do
      {:ok, _show_live, html} = live(conn, ~p"/rentals/#{rental}")

      assert html =~ "Show Rental"
      assert html =~ rental.rental_number
    end

    test "updates rental within modal", %{conn: conn, rental: rental} do
      {:ok, show_live, _html} = live(conn, ~p"/rentals/#{rental}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Rental"

      assert_patch(show_live, ~p"/rentals/#{rental}/show/edit")

      assert show_live
             |> form("#rental-form", rental: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#rental-form", rental: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/rentals/#{rental}")

      html = render(show_live)
      assert html =~ "Rental updated successfully"
      assert html =~ "some updated rental_number"
    end
  end
end
