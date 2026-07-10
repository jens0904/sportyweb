defmodule SportywebWeb.AccessoriesLiveTest do
  use SportywebWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.AssetFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  @create_attrs %{
    commission_date: ~D[2022-11-10],
    decommission_date: ~D[2022-11-15],
    description: "some description",
    name: "some name",
    purchase_date: ~D[2022-11-05],
    reference_number: "some reference_number",
    serial_number: "some serial_number"
  }
  @update_attrs %{
    commission_date: ~D[2022-11-11],
    decommission_date: ~D[2022-11-16],
    description: "some updated description",
    name: "some updated name",
    purchase_date: ~D[2022-11-06],
    reference_number: "some updated reference_number",
    serial_number: "some updated serial_number"
  }
  @invalid_attrs %{
    commission_date: nil,
    decommission_date: nil,
    description: nil,
    name: nil,
    purchase_date: nil,
    reference_number: nil,
    serial_number: nil
  }

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_accessories(_) do
    accessories = accessories_fixture()
    %{accessories: accessories}
  end

  describe "Index" do
    setup [:create_accessories]

    test "lists all accessories - default redirect", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/accessories")

      conn = conn |> log_in_user(user)

      {:ok, conn} =
        conn
        |> live(~p"/accessories")
        |> follow_redirect(conn, ~p"/clubs")

      assert conn.resp_body =~ "Vereinsübersicht"
    end

    test "lists all accessories - redirect", %{conn: conn, user: user, accessories: accessories} do
      {:error, _} = live(conn, ~p"/locations/#{accessories.location_id}/accessories")

      conn = conn |> log_in_user(user)

      {:ok, conn} =
        conn
        |> live(~p"/locations/#{accessories.location_id}/accessories")
        |> follow_redirect(conn, ~p"/locations/#{accessories.location_id}")

      assert conn.resp_body =~ "Standort:"
    end
  end

  describe "New/Edit" do
    setup [:create_accessories]

    test "saves new accessories", %{conn: conn, user: user} do
      location = location_fixture()

      {:error, _} = live(conn, ~p"/locations/#{location}/accessories/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/locations/#{location}/accessories/new")

      assert html =~ "Accessories erstellen"

      assert new_live
             |> form("#accessories-form", accessories: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        new_live
        |> form("#accessories-form", accessories: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/locations/#{location}")

      assert html =~ "Accessories erfolgreich erstellt"
      assert html =~ "some name"
    end

    test "cancels save new accessories", %{conn: conn, user: user} do
      location = location_fixture()

      conn = conn |> log_in_user(user)
      {:ok, new_live, _html} = live(conn, ~p"/locations/#{location}/accessories/new")

      {:ok, _, _html} =
        new_live
        |> element("#accessories-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/locations/#{location}")
    end

    test "updates accessories", %{conn: conn, user: user, accessories: accessories} do
      {:error, _} = live(conn, ~p"/accessories/#{accessories}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/accessories/#{accessories}/edit")

      assert html =~ "Accessories bearbeiten"

      assert edit_live
             |> form("#accessories-form", accessories: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        edit_live
        |> form("#accessories-form", accessories: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/accessories/#{accessories}")

      assert html =~ "Accessories erfolgreich aktualisiert"
      assert html =~ "some updated name"
    end

    test "cancels updates accessories", %{conn: conn, user: user, accessories: accessories} do
      conn = conn |> log_in_user(user)
      {:ok, edit_live, _html} = live(conn, ~p"/accessories/#{accessories}/edit")

      {:ok, _, _html} =
        edit_live
        |> element("#accessories-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/accessories/#{accessories}")
    end

    test "deletes accessories", %{conn: conn, user: user, accessories: accessories} do
      {:error, _} = live(conn, ~p"/accessories/#{accessories}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/accessories/#{accessories}/edit")
      assert html =~ "some serial_number"

      {:ok, _, html} =
        edit_live
        |> element("#accessories-form button", "Löschen")
        |> render_click()
        |> follow_redirect(conn, ~p"/locations/#{accessories.location_id}")

      assert html =~ "Accessories erfolgreich gelöscht"
      assert html =~ "Accessories"
      refute html =~ "some serial_number"
    end
  end

  describe "Show" do
    setup [:create_accessories]

    test "displays accessories", %{conn: conn, user: user, accessories: accessories} do
      {:error, _} = live(conn, ~p"/accessories/#{accessories}")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/accessories/#{accessories}")

      assert html =~ "Accessories:"
      assert html =~ accessories.name
    end
  end

  describe "FeeNew" do
    setup [:create_accessories]

    test "saves new accessories fee", %{conn: conn, user: user, accessories: accessories} do
      {:error, _} = live(conn, ~p"/accessories/#{accessories}/fees/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/accessories/#{accessories}/fees/new")

      assert html =~ "Spezifische Gebühr erstellen (Accessories)"

      assert new_live
             |> form("#fee-form", fee: %{})
             |> render_change() =~ "can&#39;t be blank"

      create_attrs = %{
        amount: "30 €",
        amount_one_time: "10 €",
        name: "some name",
        internal_events: %{
          "0" => %{
            commission_date: ~D[2022-11-03]
          }
        }
      }

      {:ok, _, html} =
        new_live
        |> form("#fee-form", fee: create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/accessories/#{accessories}")

      assert html =~ "Gebühr erfolgreich erstellt"
      assert html =~ accessories.name
    end
  end
end
