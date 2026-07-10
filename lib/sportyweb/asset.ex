defmodule Sportyweb.Asset do
  @moduledoc """
  The Asset context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Asset.Accessories
  alias Sportyweb.Asset.AccessoriesFee
  alias Sportyweb.Asset.Location
  alias Sportyweb.Asset.LocationFee
  alias Sportyweb.Finance.Fee
  alias Sportyweb.Inventory.Rental

  @spec list_locations(any()) :: any()
  @doc """
  Returns a clubs list of locations.

  ## Examples

      iex> list_locations(1)
      [%Location{}, ...]

  """
  def list_locations(club_id) do
    query = from(v in Location, where: v.club_id == ^club_id, order_by: v.name)
    Repo.all(query)
  end

  @spec list_locations_with_units(any(), any()) :: any()
  @doc """
  Returns a clubs list of locations with available units for a given article.
  ## Examples

      iex> list_locations_with_units(1, 1)
      [%Location{}, ...]

  """
def list_locations_with_units(club_id, article_id) do
  query =
    from v in Location,
      join: u in assoc(v, :units),
      left_join: r in Rental,
        on: r.unit_id == u.id and r.status == "active",
      where: v.club_id == ^club_id,
      where: u.article_id == ^article_id,
      where: u.condition_status == "ok",
      where: is_nil(r.id),
      order_by: v.name,
      distinct: v.id

  Repo.all(query)
end
  @doc """
  Returns a clubs list of locations. Preloads associations.

  ## Examples

      iex> list_locations(1, [:accessories])
      [%Location{}, ...]

  """
  def list_locations(club_id, preloads) do
    Repo.preload(list_locations(club_id), preloads)
  end

  @doc """
  Gets a single location.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location!(123)
      %Location{}

      iex> get_location!(456)
      ** (Ecto.NoResultsError)

  """
  def get_location!(id), do: Repo.get!(Location, id)

  @doc """
  Gets a single location. Preloads associations.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location!(123, [:club])
      %Location{}

      iex> get_location!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_location!(id, preloads) do
    Location
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a location.

  ## Examples

      iex> create_location(%{field: value})
      {:ok, %Location{}}

      iex> create_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_location(attrs \\ %{}) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a location.

  ## Examples

      iex> update_location(location, %{field: new_value})
      {:ok, %Location{}}

      iex> update_location(location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a location.

  ## Examples

      iex> delete_location(location)
      {:ok, %Location{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(%Location{} = location) do
    Repo.delete(location)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.

  ## Examples

      iex> change_location(location)
      %Ecto.Changeset{data: %Location{}}

  """
  def change_location(%Location{} = location, attrs \\ %{}) do
    Location.changeset(location, attrs)
  end

  @doc """
  Creates a location_fee (many_to_many).

  ## Examples

      iex> create_location_fee(location, fee)
      {:ok, %LocationFee{}}

      iex> create_location_fee(location, fee)
      {:error, %Ecto.Changeset{}}

  """
  def create_location_fee(%Location{} = location, %Fee{} = fee) do
    Repo.insert(%LocationFee{
      location_id: location.id,
      fee_id: fee.id
    })
  end

  alias Sportyweb.Asset.Accessories

  @doc """
  Returns a locations list of accessories.

  ## Examples

      iex> list_accessories(1)
      [%Accessories{}, ...]

  """
  def list_accessories(location_id) do
    query = from(e in Accessories, where: e.location_id == ^location_id, order_by: e.name)
    Repo.all(query)
  end

  @doc """
  Returns a locations list of accessories. Preloads associations.

  ## Examples

      iex> list_accessories(1, [:location])
      [%Accessories{}, ...]

  """
  def list_accessories(location_id, preloads) do
    Repo.preload(list_accessories(location_id), preloads)
  end

  @doc """
  Gets a single accessories.

  Raises `Ecto.NoResultsError` if the Accessories does not exist.

  ## Examples

      iex> get_accessories!(123)
      %Accessories{}

      iex> get_accessories!(456)
      ** (Ecto.NoResultsError)

  """
  def get_accessories!(id), do: Repo.get!(Accessories, id)

  @doc """
  Gets a single accessories. Preloads associations.

  Raises `Ecto.NoResultsError` if the Accessories does not exist.

  ## Examples

      iex> get_accessories!(123, [:location])
      %Department{}

      iex> get_accessories!(456, [:location])
      ** (Ecto.NoResultsError)

  """
  def get_accessories!(id, preloads) do
    Accessories
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a accessories.

  ## Examples

      iex> create_accessories(%{field: value})
      {:ok, %Accessories{}}

      iex> create_accessories(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_accessories(attrs \\ %{}) do
    %Accessories{}
    |> Accessories.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a accessories.

  ## Examples

      iex> update_accessories(accessories, %{field: new_value})
      {:ok, %Accessories{}}

      iex> update_accessories(accessories, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_accessories(%Accessories{} = accessories, attrs) do
    accessories
    |> Accessories.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a accessories.

  ## Examples

      iex> delete_accessories(accessories)
      {:ok, %Accessories{}}

      iex> delete_accessories(accessories)
      {:error, %Ecto.Changeset{}}

  """
  def delete_accessories(%Accessories{} = accessories) do
    Repo.delete(accessories)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking accessories changes.

  ## Examples

      iex> change_accessories(accessories)
      %Ecto.Changeset{data: %Accessories{}}

  """
  def change_accessories(%Accessories{} = accessories, attrs \\ %{}) do
    Accessories.changeset(accessories, attrs)
  end

  @doc """
  Creates a accessories_fee (many_to_many).

  ## Examples

      iex> create_accessories_fee(accessories, fee)
      {:ok, %AccessoriesFee{}}

      iex> create_accessories_fee(accessories, fee)
      {:error, %Ecto.Changeset{}}

  """
  def create_accessories_fee(%Accessories{} = accessories, %Fee{} = fee) do
    Repo.insert(%AccessoriesFee{
      accessories_id: accessories.id,
      fee_id: fee.id
    })
  end
end
