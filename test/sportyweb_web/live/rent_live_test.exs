defmodule SportywebWeb.RentLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.InventoryFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_rent(_) do
    rent = rent_fixture()
    %{rent: rent}
  end

  describe "Index" do
    setup [:create_rent]

    test "lists all rents", %{conn: conn, rent: rent} do
      {:ok, _index_live, html} = live(conn, ~p"/rents")

      assert html =~ "Listing Rents"
      assert html =~ rent.name
    end

    test "saves new rent", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/rents")

      assert index_live |> element("a", "New Rent") |> render_click() =~
               "New Rent"

      assert_patch(index_live, ~p"/rents/new")

      assert index_live
             |> form("#rent-form", rent: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#rent-form", rent: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/rents")

      html = render(index_live)
      assert html =~ "Rent created successfully"
      assert html =~ "some name"
    end

    test "updates rent in listing", %{conn: conn, rent: rent} do
      {:ok, index_live, _html} = live(conn, ~p"/rents")

      assert index_live |> element("#rents-#{rent.id} a", "Edit") |> render_click() =~
               "Edit Rent"

      assert_patch(index_live, ~p"/rents/#{rent}/edit")

      assert index_live
             |> form("#rent-form", rent: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#rent-form", rent: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/rents")

      html = render(index_live)
      assert html =~ "Rent updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes rent in listing", %{conn: conn, rent: rent} do
      {:ok, index_live, _html} = live(conn, ~p"/rents")

      assert index_live |> element("#rents-#{rent.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#rents-#{rent.id}")
    end
  end

  describe "Show" do
    setup [:create_rent]

    test "displays rent", %{conn: conn, rent: rent} do
      {:ok, _show_live, html} = live(conn, ~p"/rents/#{rent}")

      assert html =~ "Show Rent"
      assert html =~ rent.name
    end

    test "updates rent within modal", %{conn: conn, rent: rent} do
      {:ok, show_live, _html} = live(conn, ~p"/rents/#{rent}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Rent"

      assert_patch(show_live, ~p"/rents/#{rent}/show/edit")

      assert show_live
             |> form("#rent-form", rent: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#rent-form", rent: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/rents/#{rent}")

      html = render(show_live)
      assert html =~ "Rent updated successfully"
      assert html =~ "some updated name"
    end
  end
end
