defmodule Sportyweb.AssetTest do
  use Sportyweb.DataCase, async: true

  alias Sportyweb.Asset

  describe "locations" do
    alias Sportyweb.Asset.Location
    alias Sportyweb.Asset.LocationFee

    import Sportyweb.AssetFixtures
    import Sportyweb.FinanceFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.PolymorphicFixtures

    @invalid_attrs %{
      description: nil,
      name: nil,
      reference_number: nil
    }

    test "list_locations/1 returns all locations of a given club" do
      location = location_fixture()
      assert List.first(Asset.list_locations(location.club_id)).id == location.id
    end

    test "list_locations/2 returns all locations of a given club with preloaded associations" do
      location = location_fixture()

      assert Asset.list_locations(location.club_id, [:emails, :notes, :phones, :postal_addresses]) ==
               [
                 location
               ]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert Asset.get_location!(location.id).id == location.id
    end

    test "get_location!/2 returns the location with given id and contains preloaded associations" do
      location = location_fixture()

      assert Asset.get_location!(location.id, [:emails, :notes, :phones, :postal_addresses]) ==
               location
    end

    test "create_location/1 with valid data creates a location" do
      club = club_fixture()

      valid_attrs = %{
        club_id: club.id,
        description: "some description",
        name: "some name",
        reference_number: "some reference_number",
        emails: [email_attrs()],
        notes: [note_attrs()],
        phones: [phone_attrs()],
        postal_addresses: [postal_address_attrs()]
      }

      assert {:ok, %Location{} = location} = Asset.create_location(valid_attrs)
      assert location.description == "some description"
      assert location.name == "some name"
      assert location.reference_number == "some reference_number"
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Asset.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()

      update_attrs = %{
        description: "some updated description",
        name: "some updated name",
        reference_number: "some updated reference_number"
      }

      assert {:ok, %Location{} = location} = Asset.update_location(location, update_attrs)
      assert location.description == "some updated description"
      assert location.name == "some updated name"
      assert location.reference_number == "some updated reference_number"
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = Asset.update_location(location, @invalid_attrs)
      assert location.id == Asset.get_location!(location.id).id
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = Asset.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> Asset.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = Asset.change_location(location)
    end

    test "create_location_fee/2 with valid data" do
      location = location_fixture()
      fee = fee_fixture()
      assert {:ok, %LocationFee{}} = Asset.create_location_fee(location, fee)
    end
  end

  describe "accessories" do
    alias Sportyweb.Asset.Accessories
    alias Sportyweb.Asset.AccessoriesFee

    import Sportyweb.AssetFixtures
    import Sportyweb.FinanceFixtures
    import Sportyweb.PolymorphicFixtures

    @invalid_attrs %{
      commission_date: nil,
      decommission_date: nil,
      description: nil,
      name: nil,
      purchase_date: nil,
      reference_number: nil,
      serial_number: nil
    }

    test "list_accessories/1 returns all accessories of a given location" do
      accessories = accessories_fixture()
      assert List.first(Asset.list_accessories(accessories.location_id)).id == accessories.id
    end

    test "list_accessories/2 returns all accessories of a given location with preloaded associations" do
      accessories = accessories_fixture()

      assert Asset.list_accessories(accessories.location_id, [:emails, :notes, :phones]) == [
               accessories
             ]
    end

    test "get_accessories!/1 returns the accessories with given id" do
      accessories = accessories_fixture()
      assert Asset.get_accessories!(accessories.id).id == accessories.id
    end

    test "get_accessories!/2 returns the accessories with given id and contains preloaded associations" do
      accessories = accessories_fixture()
      assert Asset.get_accessories!(accessories.id, [:emails, :notes, :phones]) == accessories
    end

    test "create_accessories/1 with valid data creates a accessories" do
      location = location_fixture()

      valid_attrs = %{
        location_id: location.id,
        commission_date: ~D[2023-02-14],
        decommission_date: ~D[2023-02-14],
        description: "some description",
        name: "some name",
        purchase_date: ~D[2023-02-14],
        reference_number: "some reference_number",
        serial_number: "some serial_number",
        emails: [email_attrs()],
        notes: [note_attrs()],
        phones: [phone_attrs()]
      }

      assert {:ok, %Accessories{} = accessories} = Asset.create_accessories(valid_attrs)
      assert accessories.commission_date == ~D[2023-02-14]
      assert accessories.decommission_date == ~D[2023-02-14]
      assert accessories.description == "some description"
      assert accessories.name == "some name"
      assert accessories.purchase_date == ~D[2023-02-14]
      assert accessories.reference_number == "some reference_number"
      assert accessories.serial_number == "some serial_number"
    end

    test "create_accessories/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Asset.create_accessories(@invalid_attrs)
    end

    test "update_accessories/2 with valid data updates the accessories" do
      accessories = accessories_fixture()

      update_attrs = %{
        commission_date: ~D[2023-02-15],
        decommission_date: ~D[2023-02-15],
        description: "some updated description",
        name: "some updated name",
        purchase_date: ~D[2023-02-15],
        reference_number: "some updated reference_number",
        serial_number: "some updated serial_number"
      }

      assert {:ok, %Accessories{} = accessories} = Asset.update_accessories(accessories, update_attrs)
      assert accessories.commission_date == ~D[2023-02-15]
      assert accessories.decommission_date == ~D[2023-02-15]
      assert accessories.description == "some updated description"
      assert accessories.name == "some updated name"
      assert accessories.purchase_date == ~D[2023-02-15]
      assert accessories.reference_number == "some updated reference_number"
      assert accessories.serial_number == "some updated serial_number"
    end

    test "update_accessories/2 with invalid data returns error changeset" do
      accessories = accessories_fixture()
      assert {:error, %Ecto.Changeset{}} = Asset.update_accessories(accessories, @invalid_attrs)
      assert accessories == Asset.get_accessories!(accessories.id, [:emails, :phones, :notes])
    end

    test "delete_accessories/1 deletes the accessories" do
      accessories = accessories_fixture()
      assert {:ok, %Accessories{}} = Asset.delete_accessories(accessories)
      assert_raise Ecto.NoResultsError, fn -> Asset.get_accessories!(accessories.id) end
    end

    test "change_accessories/1 returns a accessories changeset" do
      accessories = accessories_fixture()
      assert %Ecto.Changeset{} = Asset.change_accessories(accessories)
    end

    test "create_accessories_fee/2 with valid data" do
      accessories = accessories_fixture()
      fee = fee_fixture()
      assert {:ok, %AccessoriesFee{}} = Asset.create_accessories_fee(accessories, fee)
    end
  end
end
