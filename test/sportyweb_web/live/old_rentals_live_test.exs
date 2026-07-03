defmodule SportywebWeb.OldRentalsLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.InventoryFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_old_rentals(_) do
    old_rentals = old_rentals_fixture()
    %{old_rentals: old_rentals}
  end

  describe "Index" do
    setup [:create_old_rentals]

    test "lists all old_rentals", %{conn: conn, old_rentals: old_rentals} do
      {:ok, _index_live, html} = live(conn, ~p"/old_rentals")

      assert html =~ "Listing Old rentals"
      assert html =~ old_rentals.name
    end

    test "saves new old_rentals", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/old_rentals")

      assert index_live |> element("a", "New Old rentals") |> render_click() =~
               "New Old rentals"

      assert_patch(index_live, ~p"/old_rentals/new")

      assert index_live
             |> form("#old_rentals-form", old_rentals: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#old_rentals-form", old_rentals: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/old_rentals")

      html = render(index_live)
      assert html =~ "Old rentals created successfully"
      assert html =~ "some name"
    end

    test "updates old_rentals in listing", %{conn: conn, old_rentals: old_rentals} do
      {:ok, index_live, _html} = live(conn, ~p"/old_rentals")

      assert index_live |> element("#old_rentals-#{old_rentals.id} a", "Edit") |> render_click() =~
               "Edit Old rentals"

      assert_patch(index_live, ~p"/old_rentals/#{old_rentals}/edit")

      assert index_live
             |> form("#old_rentals-form", old_rentals: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#old_rentals-form", old_rentals: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/old_rentals")

      html = render(index_live)
      assert html =~ "Old rentals updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes old_rentals in listing", %{conn: conn, old_rentals: old_rentals} do
      {:ok, index_live, _html} = live(conn, ~p"/old_rentals")

      assert index_live |> element("#old_rentals-#{old_rentals.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#old_rentals-#{old_rentals.id}")
    end
  end

  describe "Show" do
    setup [:create_old_rentals]

    test "displays old_rentals", %{conn: conn, old_rentals: old_rentals} do
      {:ok, _show_live, html} = live(conn, ~p"/old_rentals/#{old_rentals}")

      assert html =~ "Show Old rentals"
      assert html =~ old_rentals.name
    end

    test "updates old_rentals within modal", %{conn: conn, old_rentals: old_rentals} do
      {:ok, show_live, _html} = live(conn, ~p"/old_rentals/#{old_rentals}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Old rentals"

      assert_patch(show_live, ~p"/old_rentals/#{old_rentals}/show/edit")

      assert show_live
             |> form("#old_rentals-form", old_rentals: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#old_rentals-form", old_rentals: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/old_rentals/#{old_rentals}")

      html = render(show_live)
      assert html =~ "Old rentals updated successfully"
      assert html =~ "some updated name"
    end
  end
end
