defmodule SportywebWeb.RentalFeeLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.RentalFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_rental_fee(_) do
    rental_fee = rental_fee_fixture()
    %{rental_fee: rental_fee}
  end

  describe "Index" do
    setup [:create_rental_fee]

    test "lists all rental_fee", %{conn: conn, rental_fee: rental_fee} do
      {:ok, _index_live, html} = live(conn, ~p"/rental_fee")

      assert html =~ "Listing Rental fee"
      assert html =~ rental_fee.name
    end

    test "saves new rental_fee", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/rental_fee")

      assert index_live |> element("a", "New Rental fee") |> render_click() =~
               "New Rental fee"

      assert_patch(index_live, ~p"/rental_fee/new")

      assert index_live
             |> form("#rental_fee-form", rental_fee: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#rental_fee-form", rental_fee: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/rental_fee")

      html = render(index_live)
      assert html =~ "Rental fee created successfully"
      assert html =~ "some name"
    end

    test "updates rental_fee in listing", %{conn: conn, rental_fee: rental_fee} do
      {:ok, index_live, _html} = live(conn, ~p"/rental_fee")

      assert index_live |> element("#rental_fee-#{rental_fee.id} a", "Edit") |> render_click() =~
               "Edit Rental fee"

      assert_patch(index_live, ~p"/rental_fee/#{rental_fee}/edit")

      assert index_live
             |> form("#rental_fee-form", rental_fee: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#rental_fee-form", rental_fee: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/rental_fee")

      html = render(index_live)
      assert html =~ "Rental fee updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes rental_fee in listing", %{conn: conn, rental_fee: rental_fee} do
      {:ok, index_live, _html} = live(conn, ~p"/rental_fee")

      assert index_live |> element("#rental_fee-#{rental_fee.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#rental_fee-#{rental_fee.id}")
    end
  end

  describe "Show" do
    setup [:create_rental_fee]

    test "displays rental_fee", %{conn: conn, rental_fee: rental_fee} do
      {:ok, _show_live, html} = live(conn, ~p"/rental_fee/#{rental_fee}")

      assert html =~ "Show Rental fee"
      assert html =~ rental_fee.name
    end

    test "updates rental_fee within modal", %{conn: conn, rental_fee: rental_fee} do
      {:ok, show_live, _html} = live(conn, ~p"/rental_fee/#{rental_fee}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Rental fee"

      assert_patch(show_live, ~p"/rental_fee/#{rental_fee}/show/edit")

      assert show_live
             |> form("#rental_fee-form", rental_fee: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#rental_fee-form", rental_fee: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/rental_fee/#{rental_fee}")

      html = render(show_live)
      assert html =~ "Rental fee updated successfully"
      assert html =~ "some updated name"
    end
  end
end
