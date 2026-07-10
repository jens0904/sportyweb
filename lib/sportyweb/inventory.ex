defmodule Sportyweb.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Query, warn: false

  alias Sportyweb.Repo
  alias Sportyweb.Inventory.Category
  alias Sportyweb.Inventory.Article
  alias Sportyweb.Inventory.RentalFee

  alias Sportyweb.Inventory.Unit
  alias Sportyweb.Inventory.Rental
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Inventory.RentalRule

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories(club_id) do
    query = from(c in Category, where: c.club_id == ^club_id, order_by: c.name)
    Repo.all(query)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Gets a single category. Preloads associations.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123, [:club])
      %Category{}

      iex> get_category!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_category!(id, preloads) do
    Category
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  @doc """
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """

  # def list_articles do
  # Repo.all(Article)
  # end

  def list_articles(club_id) do
    query = from(v in Article, where: v.club_id == ^club_id, order_by: v.name)
    Repo.all(query)
  end

  @doc """
  Gets a single article.

  Raises `Ecto.NoResultsError` if the Article does not exist.

  ## Examples

      iex> get_article!(123)
      %Article{}

      iex> get_article!(456)
      ** (Ecto.NoResultsError)

  """
  def get_article!(id), do: Repo.get!(Article, id)

  @doc """
  Gets a single article. Preloads associations.

  Raises `Ecto.NoResultsError` if the Article does not exist.

  ## Examples

      iex> get_article!(123, [:club])
      %Article{}

      iex> get_article!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_article!(id, preloads) do
    Article
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Checks whether an article has at least one available unit.
  A unit is considered available if it
  - belongs to the specified article
  - has the condition status `"ok"`, and
  - is not currently associated with an active rental.

  Returns `true`if at least one matching unit exists, otherwise `false``

  ## Examples

  iex > has available units(3)
  true

  iex > has available units(5)
  false
  """
  def has_available_units?(article_id) do
    query =
      from u in Unit,
        left_join: r in Rental,
        on: r.unit_id == u.id and r.status == "active",
        where: u.article_id == ^article_id,
        where: u.condition_status == "ok",
        where: is_nil(r.id)

    Repo.exists?(query)
  end

  @doc """
  Creates a article.

  ## Examples

      iex> create_article(%{field: value})
      {:ok, %Article{}}

      iex> create_article(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_article(attrs \\ %{}) do
    %Article{}
    |> Article.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a article.

  ## Examples

      iex> update_article(article, %{field: new_value})
      {:ok, %Article{}}

      iex> update_article(article, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_article(%Article{} = article, attrs) do
    article
    |> Article.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a article.

  ## Examples

      iex> delete_article(article)
      {:ok, %Article{}}

      iex> delete_article(article)
      {:error, %Ecto.Changeset{}}

  """
  def delete_article(%Article{} = article) do
    Repo.delete(article)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking article changes.

  ## Examples

      iex> change_article(article)
      %Ecto.Changeset{data: %Article{}}

  """
  def change_article(%Article{} = article, attrs \\ %{}) do
    Article.changeset(article, attrs)
  end

  @doc """
  Returns the list of units.

  ## Examples

      iex> list_units()
      [%Unit{}, ...]

  """
  def list_units do
    Repo.all(Unit)
  end

  @doc """
  Lists available units for given article and location.

  If location_id is nil or an empty string, an empty list is returned.


  ##Examples

    iex> list_available_units(article_id, nil)
    []
    iex> list_available_units(article_id, "")
    []
    iex> list_available_units(article_id, location_id)
    [%Unit{}, ...]
  """

  def list_available_units(article_id, location_id) do
    if is_nil(location_id) || String.trim(location_id) == "" do
      []
    else
      query =
        from u in Unit,
          left_join: r in Rental,
          on: r.unit_id == u.id and r.status == "active",
          where: u.location_id == ^location_id,
          where: u.article_id == ^article_id,
          where: u.condition_status == "ok",
          where: is_nil(r.id),
          order_by: u.serial_number

      Repo.all(query)
    end
  end

  @doc """
  Gets a single unit.

  Raises `Ecto.NoResultsError` if the Unit does not exist.

  ## Examples

      iex> get_unit!(123)
      %Unit{}

      iex> get_unit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_unit!(id), do: Repo.get!(Unit, id)

  @doc """
  Gets a single unit. Preloads associations.

  Raises `Ecto.NoResultsError` if the Unit does not exist.

  ## Examples

      iex> get_unit!(123, [:club])
      %Unit{}

      iex> get_unit!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_unit!(id, preloads) do
    Unit
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a unit.

  ## Examples

      iex> create_unit(%{field: value})
      {:ok, %Unit{}}

      iex> create_unit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_unit(attrs \\ %{}) do
    %Unit{}
    |> Unit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a unit.

  ## Examples

      iex> update_unit(unit, %{field: new_value})
      {:ok, %Unit{}}

      iex> update_unit(unit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_unit(%Unit{} = unit, attrs) do
    unit
    |> Unit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a unit.

  ## Examples

      iex> delete_unit(unit)
      {:ok, %Unit{}}

      iex> delete_unit(unit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_unit(%Unit{} = unit) do
    Repo.delete(unit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking unit changes.

  ## Examples

      iex> change_unit(unit)
      %Ecto.Changeset{data: %Unit{}}

  """
  def change_unit(%Unit{} = unit, attrs \\ %{}) do
    Unit.changeset(unit, attrs)
  end

  @doc """
  Returns the list of rentals.

  ## Examples

      iex> list_rentals()
      [%Rental{}, ...]

  """
  def list_rentals do
    Repo.all(Rental)
  end

  @doc """
  Gets a single rental.

  Raises `Ecto.NoResultsError` if the Rental does not exist.

  ## Examples

      iex> get_rental!(123)
      %Rental{}

      iex> get_rental!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rental!(id), do: Repo.get!(Rental, id)

  @doc """
  Gets a single rental. Preloads associations.

  Raises `Ecto.NoResultsError` if the Rental does not exist.

  ## Examples

      iex> get_rental!(123, [:club])
      %Unit{}

      iex> get_rental!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_rental!(id, preloads) do
    Rental
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a rental under a transaction. Also changes sets the rental status to "active".
  Then gets the applicable rental rule for the article or the underlying category or club.
  Extends the rental attributes with the associated rental rule.
  Calculates the total fee by multiplying the taking the fee from rental attributes and the time unit by the associated rental rule.
  Extends the rental attributes with total fee.
  Calculates the maximum return date based on the rental date and the articles rental rules.


  ## Examples

      iex> create_rental(%{field: value})
      {:ok, %Rental{}}

      iex> create_rental(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rental(attrs \\ %{}) do
    rental_attrs =
      Map.merge(attrs, %{
        "status" => "active"
      })

    rental_rule =
      get_applicable_rental_rule(rental_attrs["article_id"])

    rental_attrs =
      Map.put(rental_attrs, "rental_rule_id", rental_rule.id)

    total_fee =
      calculate_total_fee(rental_attrs, rental_rule)

    rental_attrs =
      Map.put(rental_attrs, "total_fee", total_fee)

    max_return_date =
      calculate_max_return_date(
        rental_attrs["article_id"],
        rental_attrs["rental_date"]
      )

    %Rental{}
    |> Rental.changeset(rental_attrs, max_return_date, rental_rule)
    |> Repo.insert()
  end

  @doc """
  Updates a rental.
  Calculates the maximum return date based on the rental_date from the new
  Gets the applicable rental rule for the article first.
  Then calcultes the new max return_date based on the new rental date and the associated rental_rule. If a new date is not set. it takes the old rental date

  ## Examples

      iex> update_rental(rental, %{field: new_value})
      {:ok, %Rental{}}

      iex> update_rental(rental, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rental(%Rental{} = rental, attrs) do
    rental_rule = get_applicable_rental_rule(rental.article_id)

    max_return_date =
      calculate_max_return_date(rental.article_id, attrs["rental_date"] || rental.rental_date)

    rental
    |> Rental.changeset(attrs, max_return_date, rental_rule)
    |> Repo.update()
  end

  @doc """
  Deletes a rental.

  ## Examples

      iex> delete_rental(rental)
      {:ok, %Rental{}}

      iex> delete_rental(rental)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rental(%Rental{} = rental) do
    Repo.delete(rental)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rental changes.
  First takes the article_id and the rental_date by the rental attributes.
  Then gets the rental_rule for the selected article.
  Then calculates the maximum return date based on the rental_rule and the rental_date if data is available.

  ## Examples

      iex> change_rental(rental)
      %Ecto.Changeset{data: %Rental{}}

  """
  def change_rental(%Rental{} = rental, attrs \\ %{}) do
    article_id = attrs["article_id"] || rental.article_id
    rental_date = attrs["rental_date"] || rental.rental_date

    rental_rule =
      if article_id do
        get_applicable_rental_rule(article_id)
      end

    max_return_date =
      if article_id && rental_date do
        calculate_max_return_date(article_id, rental_date)
      end

    Rental.changeset(
      rental,
      attrs,
      max_return_date,
      rental_rule
    )
  end

  @doc """
  Calculates maximum return_date based on the rental_rule and rental_date.
  Ensures that rental_date is normalized to datetime.
  Then get applicable rental_rule with chosen rental_period und rental_period_unit.
  Adding rental period to rental date
  """

  @spec calculate_max_return_date(any(), any()) :: nil | DateTime.t()
  def calculate_max_return_date(article_id, rental_date) do
    rental_date = normalize_datetime(rental_date)

    if rental_date do
      rental_rule = get_applicable_rental_rule(article_id)

      if rental_rule &&
           rental_rule.choose_rental_period &&
           rental_rule.rental_period do
        add_period(
          rental_date,
          rental_rule.rental_period,
          rental_rule.rental_period_unit
        )
      else
        nil
      end
    else
      nil
    end
  end

  # Leave datetime values unchanged
  defp normalize_datetime(%DateTime{} = datetime), do: datetime

  # Convert ISO 8601 strings to datetime values
  defp normalize_datetime(datetime) when is_binary(datetime) do
    case DateTime.from_iso8601(datetime) do
      {:ok, datetime, _offset} -> datetime
      _ -> nil
    end
  end

  # return nil for unsupported date formats
  defp normalize_datetime(_), do: nil

  # adding rental period according to configured time unit
  defp add_period(datetime, period, "Stunden"),
    do: DateTime.add(datetime, period * 3_600, :second)

  defp add_period(datetime, period, "Tage"),
    do: DateTime.add(datetime, period * 86_400, :second)

  defp add_period(datetime, period, "Wochen"),
    do: DateTime.add(datetime, period * 7 * 86_400, :second)

  defp add_period(datetime, _period, _unit), do: datetime

  @doc """
  Calculates the return date for a given article based on the rental period defined in the article or its category.
  ## Examples

      iex> calculate_return_date(article_id)
      ~D[2024-07-01]

      iex> calculate_return_date(article_id_with_no_rental_period)
      nil
  """

  def calculate_return_date(article_id, rental_date) do
    case get_applicable_rental_rule(article_id) do
      %{choose_rental_period: true, rental_period: rental_period, rental_period_unit: unit}
      when not is_nil(rental_period) and unit in ["Tage", "days"] ->
        DateTime.add(rental_date, rental_period * 24 * 60 * 60, :second)

      %{choose_rental_period: true, rental_period: rental_period, rental_period_unit: unit}
      when not is_nil(rental_period) and unit in ["Stunden", "hours"] ->
        DateTime.add(rental_date, rental_period * 60 * 60, :second)

      _ ->
        nil
    end
  end

  @doc """
  Renews an existing rental.
  Increments the renewal count and updates the rental with the provided attributes.
  Returns {:ok, rental} on success or {:error, %Ecto.Changeset{} = changeset} if the update fails.
  """
  def renew_rental(%Rental{} = rental, attrs) do
    attrs =
      attrs
      |> Map.put("renewal_count", rental.renewal_count + 1)

    rental
    |> Rental.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an existing rental.
  Gets rental and preloads associated article, rental fee and unit.
  Gets applicable rental_rule for article.
  Sets return date.
  Prepares the data for final fee calculation
  """
  def return_rental(%Rental{} = rental, attrs) do
    rental = get_rental!(rental.id, [:article, :rental_fee, :unit])

    rental_rule = get_applicable_rental_rule(rental.article_id)
    returned_at = DateTime.utc_now() |> DateTime.truncate(:second)

    fee_attrs = %{
      "rental_fee_id" => rental.rental_fee_id,
      "rental_date" => rental.rental_date,
      "return_date" => returned_at
    }

    # Calculates the final fee and the VAT
    total_fee = calculate_total_fee(fee_attrs, rental_rule)
    vat_fee = vat_money_for_total_fee(total_fee, rental.rental_fee)

    # Merges calculated values into the updated rental values
    rental_attrs =
      Map.merge(attrs, %{
        "status" => "returned",
        "return_date" => returned_at,
        "returned_at" => returned_at,
        "total_fee" => total_fee,
        "vat_fee" => vat_fee,
        "fee_required" => fee_required?(total_fee),
        "condition_status" => Map.get(attrs, "condition_status"),
        "condition_note" => Map.get(attrs, "condition_note")
      })

    # Update the Rental and the unit, if necessary
    Ecto.Multi.new()
    |> Ecto.Multi.update(
      :rental,
      Rental.return_changeset(rental, rental_attrs)
    )
    |> maybe_update_unit_condition(rental, attrs)
    |> Repo.transaction()
  end

  # determine if fee was greater than 0
  defp fee_required?(%Money{amount: amount}) do
    Decimal.compare(amount, Decimal.new(0)) == :gt
  end

  defp fee_required?(nil), do: false

  # update unit_condition if it was returned "damaged" or "lost"
  defp maybe_update_unit_condition(multi, rental, attrs) do
    case Map.get(attrs, "condition_status") do
      status when status in ["damaged", "lost"] ->
        unit = get_unit!(rental.unit_id)

        Ecto.Multi.update(
          multi,
          :unit,
          Unit.return_condition_changeset(unit, attrs)
        )

      _ ->
        multi
    end
  end

  defp vat_money_for_total_fee(nil, _rental_fee), do: nil
  # determine VAT amount included in the total rental fee
  defp vat_money_for_total_fee(%Money{} = total_fee, %RentalFee{} = rental_fee) do
    vat_amount =
      total_fee.amount
      |> Decimal.mult(vat_rate(rental_fee))
      |> Decimal.div(Decimal.add(Decimal.new("1"), vat_rate(rental_fee)))
      |> Decimal.round(2)

    %{total_fee | amount: vat_amount}
  end

  @doc """
  Calculates a new return_date on a renewal
  Gets applicable rental_rule first. If renewal is not allowed and hence renewal period is not given, return nil.
  Otherwise add renewal period to return_date.
  """
  def calculate_new_return_date(%Rental{} = rental, article_id) do
    rental_rule = get_applicable_rental_rule(article_id)

    case rental_rule do
      nil ->
        nil

      %{allow_renewal: false} ->
        nil

      %{renewal_period: nil} ->
        nil

      %{renewal_period: renewal_period} ->
        Date.add(rental.return_date, renewal_period)
    end
  end

  @doc """
  Returns the list of rental_fee.

  ## Examples

      iex> list_rental_fee()
      [%RentalFee{}, ...]

  """
  def list_rental_fee do
    Repo.all(RentalFee)
  end

  def list_successor_rental_fee_options(%RentalFee{} = rental_fee, maximum_age_in_years) do
    cond do
      is_nil(maximum_age_in_years) ->
        []

      is_nil(rental_fee.member_type) ->
        []

      is_nil(rental_fee.rental_duration) ->
        []

      true ->
        query =
          from(rf in RentalFee,
            where: rf.club_id == ^rental_fee.club_id,
            where: rf.member_type == ^rental_fee.member_type,
            where: rf.rental_duration == ^rental_fee.rental_duration,
            where:
              is_nil(rf.minimum_age_in_years) or
                rf.minimum_age_in_years - 1 <= ^maximum_age_in_years,
            where:
              is_nil(rf.maximum_age_in_years) or
                rf.maximum_age_in_years > ^maximum_age_in_years,
            order_by: rf.name
          )

        query =
          case rental_fee.id do
            nil -> query
            _ -> from(rf in query, where: rf.id != ^rental_fee.id)
          end

        Repo.all(query)
    end
  end

  @doc """
  Archives rental_fee.
  Check if associated rentals to rental_fee exist and have the associated status "active"
  Raises an Error if rental_fee is associated with a rental. Otherwise extends attribute archived_at with the current date time to rental_fee.


  """
  def archive_rental_fee(%RentalFee{} = rental_fee) do
    active_rentals_exist? =
      Repo.exists?(
        from r in Rental,
          where:
            r.rental_fee_id == ^rental_fee.id and
              r.status == "active"
      )

    if active_rentals_exist? do
      {:error, :rental_fee_has_active_rentals}
    else
      rental_fee
      |> Ecto.Changeset.change(archived_at: DateTime.utc_now() |> DateTime.truncate(:second))
      |> Repo.update()
    end
  end

  @doc """
  Gets a single rental_fee.

  Raises `Ecto.NoResultsError` if the Rental fee does not exist.

  ## Examples

      iex> get_rental_fee!(123)
      %RentalFee{}

      iex> get_rental_fee!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rental_fee!(id), do: Repo.get!(RentalFee, id)

  @doc """
  Gets a single rental_fee. Preloads associations.

  Raises `Ecto.NoResultsError` if the RentalFee does not exist.

  ## Examples

      iex> get_rental_fee!(123, [:club])
      %RentalFee{}

      iex> get_rental_fee!(456, [:club])
      ** (Ecto.NoResultsError)
  """

  def get_rental_fee!(id, preloads) do
    RentalFee
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Gets the applicable rental fee for the given article_id.
  Gets the article for the article_id first and preloads category association first.
  Then gets the rental_fee for the article, if there is one associated and is not archived yet.
  Otherwise it gets the associated non-archived category rental_fee.
  If none is provided, it gets the associated rental_fee for the club
  """
  def get_applicable_rental_fee(article_id) do
    article = get_article!(article_id, [:category])

    get_article_rental_fee(article) ||
      get_category_rental_fee(article) ||
      get_club_rental_fee(article)
  end

  defp get_article_rental_fee(article) do
    RentalFee
    |> where(
      [r],
      r.article_id == ^article.id and
        is_nil(r.archived_at)
    )
    |> limit(1)
    |> Repo.one()
  end

  defp get_category_rental_fee(%{category_id: nil}), do: nil

  defp get_category_rental_fee(article) do
    RentalFee
    |> where(
      [r],
      r.category_id == ^article.category_id and
        is_nil(r.archived_at)
    )
    |> limit(1)
    |> Repo.one()
  end

  defp get_club_rental_fee(article) do
    from(r in RentalFee,
      where:
        r.club_id == ^article.club_id and
          is_nil(r.article_id) and
          is_nil(r.category_id) and
          is_nil(r.archived_at),
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Creates a rental_fee.

  ## Examples

      iex> create_rental_fee(%{field: value})
      {:ok, %RentalFee{}}

      iex> create_rental_fee(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rental_fee(attrs \\ %{}) do
    %RentalFee{}
    |> RentalFee.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rental_fee.

  ## Examples

      iex> update_rental_fee(rental_fee, %{field: new_value})
      {:ok, %RentalFee{}}

      iex> update_rental_fee(rental_fee, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rental_fee(%RentalFee{} = rental_fee, attrs) do
    rental_fee
    |> RentalFee.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a rental_fee.

  ## Examples

      iex> delete_rental_fee(rental_fee)
      {:ok, %RentalFee{}}

      iex> delete_rental_fee(rental_fee)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rental_fee(%RentalFee{} = rental_fee) do
    Repo.delete(rental_fee)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rental_fee changes.

  ## Examples

      iex> change_rental_fee(rental_fee)
      %Ecto.Changeset{data: %RentalFee{}}

  """
  def change_rental_fee(%RentalFee{} = rental_fee, attrs \\ %{}) do
    RentalFee.changeset(rental_fee, attrs)
  end

  @doc """
  Lists rental_fees depending on given article and contact.
  First gets contact with associated contracts. Then gets article
  Then finds all the active rental_fees that are associated with the article, category or club.
  Then asks if contact is a member. If this is the fact, finds all belonging fees to Members of the club.
  If this is not the case, finds all belonging fees to Non-Members of the Club.
  Then applies age restrictions only for personal contacts.
  ## Examples


  """
  def list_belonging_rental_fees(article_id, contact_id) do
    if is_nil(contact_id) || (is_binary(contact_id) && String.trim(contact_id) == "") do
      []
    else
      contact = Personal.get_contact!(contact_id, [:contracts])
      article = get_article!(article_id)

      query =
        from(rf in RentalFee,
          where:
            is_nil(rf.archived_at) and
              (rf.article_id == ^article.id or
                 rf.category_id == ^article.category_id or
                 (rf.club_id == ^article.club_id and
                    is_nil(rf.article_id) and
                    is_nil(rf.category_id))),
          preload: [:category, :article],
          distinct: true
        )

      query =
        if Contact.has_active_membership_contract?(contact) do
          from(rf in query,
            where: rf.member_type == ^:member,
            order_by: [asc: rf.name]
          )
        else
          from(rf in query,
            where: rf.member_type == ^:non_member or is_nil(rf.member_type),
            order_by: [asc: rf.name]
          )
        end

      query =
        if Contact.is_person?(contact) do
          contact_age_in_years = Contact.age_in_years(contact)

          from(rf in query,
            where:
              is_nil(rf.minimum_age_in_years) or
                rf.minimum_age_in_years <= ^contact_age_in_years,
            where:
              is_nil(rf.maximum_age_in_years) or
                rf.maximum_age_in_years >= ^contact_age_in_years
          )
        else
          query
        end

      Repo.all(query)
    end
  end

  @doc """
  Calculates the total fee based on the rental_fee and the rental_rule.
  Gets the rental fee first. If none is provided return nil. Also return nil if no rental_rule is provided.
  Then calculates gross amount. If a season is set as the period unit, return the total fee.
  Otherwise multiply money with billing units defined by the rental_period_unit within the rental_rule
  """
  def calculate_total_fee(attrs, %RentalRule{} = rental_rule) do
    rental_fee_id = Map.get(attrs, "rental_fee_id") || Map.get(attrs, :rental_fee_id)

    rental_fee =
      if rental_fee_id do
        get_rental_fee!(rental_fee_id)
      else
        nil
      end

    total_fee(rental_fee, rental_rule, attrs)
  end

  def calculate_total_fee(%{"rental_fee_id" => id}, _rental_rule)
      when id in [nil, ""],
      do: nil

  defp total_fee(nil, _rental_rule, _attrs), do: nil

  # calculates total_fee based on rental fee and rental_rule
  # using the gross amount as base fee
  defp total_fee(%RentalFee{} = rental_fee, %RentalRule{} = rental_rule, attrs) do
    base_fee = gross_money(rental_fee)


    if charge_once?(rental_fee, rental_rule) do
      base_fee
    else
      calculate_variable_fee(base_fee, attrs, rental_rule)
    end
  end

  defp charge_once?(rental_fee, rental_rule) do
    rental_fee.flat_fee || rental_rule.rental_period_unit == "Saison"
  end

  #calculates variable fee bases by multiplying the base fee with the billing_units
  defp calculate_variable_fee(base_fee, attrs, rental_rule) do
    case rental_units(attrs, rental_rule) do
      nil ->
        nil

      billing_units ->
        multiply_money(base_fee, billing_units)
    end
  end

  # Calculates the gross amount
  def gross_money(%RentalFee{} = rental_fee) do
    gross_amount =
      rental_fee.amount.amount
      |> Decimal.add(vat_money(rental_fee).amount)
      |> Decimal.round(2)

    %{rental_fee.amount | amount: gross_amount}
  end
  # Multiplies the money amount with the calculated billing units
  defp multiply_money(%Money{} = money, units) do
    %{money | amount: Decimal.mult(money.amount, units) |> Decimal.round(2)}
  end
  #determines the number of billing units based on the rental period
  defp rental_units(attrs, rental_rule) do
    rental_date = Map.get(attrs, "rental_date") || Map.get(attrs, :rental_date)
    return_date = Map.get(attrs, "return_date") || Map.get(attrs, :return_date)
    return_time = Map.get(attrs, "return_time") || Map.get(attrs, :return_time)

    case rental_rule.rental_period_unit do
      "Saison" ->
        Decimal.new(1)

      "Stunden" ->
        with {:ok, start_naive} <- parse_datetime(rental_date),
             {:ok, end_naive} <-
               end_datetime_for_hourly_rental(rental_date, return_date, return_time) do
          diff = NaiveDateTime.diff(end_naive, start_naive, :hour)
          Decimal.new(max(diff, 1))
        else
          _ -> nil
        end

      "Tage" ->
        with {:ok, start_date} <- parse_date_from_datetime(rental_date),
             {:ok, end_date} <- parse_date_from_datetime(return_date) do
          days = Date.diff(end_date, start_date)
          Decimal.new(max(days, 1))
        else
          _ -> nil
        end

      "Wochen" ->
        with {:ok, start_date} <- parse_date_from_datetime(rental_date),
             {:ok, end_date} <- parse_date_from_datetime(return_date) do
          days = Date.diff(end_date, start_date)
          weeks = Decimal.div(Decimal.new(max(days, 0)), Decimal.new(7))
          Decimal.round(weeks, 2)
        else
          _ -> nil
        end

      _ ->
        nil
    end
  end

  # Builds return_datetime for hourly_rentals
  defp end_datetime_for_hourly_rental(rental_date, return_date, nil) do
    parse_datetime(return_date)
  end

  defp end_datetime_for_hourly_rental(rental_date, return_date, "") do
    parse_datetime(return_date)
  end

  defp end_datetime_for_hourly_rental(rental_date, _return_date, return_time)
       when is_binary(return_time) do
    with {:ok, start_naive} <- parse_datetime(rental_date),
         {:ok, time} <- Time.from_iso8601(normalize_time(return_time)) do
      end_naive =
        start_naive
        |> NaiveDateTime.to_date()
        |> NaiveDateTime.new!(time)

      {:ok, end_naive}
    end
  end

  defp normalize_time(value) when is_binary(value) do
    cond do
      String.length(value) == 5 -> value <> ":00"
      true -> value
    end
  end

  # Parses Datetime to a NaiveDatetime
  defp parse_datetime(%DateTime{} = datetime), do: {:ok, DateTime.to_naive(datetime)}
  defp parse_datetime(%NaiveDateTime{} = datetime), do: {:ok, datetime}

  defp parse_datetime(value) when is_binary(value) do
    value =
      cond do
        String.length(value) == 16 -> value <> ":00"
        String.ends_with?(value, "Z") -> String.trim_trailing(value, "Z")
        true -> value
      end

    case NaiveDateTime.from_iso8601(value) do
      {:ok, naive} ->
        {:ok, naive}

      _ ->
        case DateTime.from_iso8601(value) do
          {:ok, datetime, _offset} -> {:ok, DateTime.to_naive(datetime)}
          _ -> :error
        end
    end
  end

  defp parse_datetime(_), do: :error

  defp parse_date_from_datetime(%DateTime{} = datetime), do: {:ok, DateTime.to_date(datetime)}

  defp parse_date_from_datetime(%NaiveDateTime{} = datetime),
    do: {:ok, NaiveDateTime.to_date(datetime)}

  defp parse_date_from_datetime(%Date{} = date), do: {:ok, date}

  defp parse_date_from_datetime(value) when is_binary(value) do
    value
    |> String.slice(0, 10)
    |> Date.from_iso8601()
  end

  defp parse_date_from_datetime(_), do: :error

  # Determines vat_rate in RentalFee depending on member_type

  def vat_rate(%RentalFee{member_type: member_type}) do
    case member_type do
      :member -> Decimal.new("0.07")
      "member" -> Decimal.new("0.07")
      :non_member -> Decimal.new("0.19")
      "non_member" -> Decimal.new("0.19")
      _ -> Decimal.new("0")
    end
  end

  # Determines vat_money depending on rental_fee.amount and adds it to RentalFee
  def vat_money(%RentalFee{} = rental_fee) do
    vat_amount =
      rental_fee.amount.amount
      |> Decimal.mult(vat_rate(rental_fee))
      |> Decimal.round(2)

    %{rental_fee.amount | amount: vat_amount}
  end

  @doc """
  Returns the list of rental_rules.

  ## Examples

      iex> list_rental_rules()
      [%RentalRule{}, ...]

  """
  def list_rental_rules do
    Repo.all(RentalRule)
  end

  @doc """
  Gets a single rental_rule.

  Raises `Ecto.NoResultsError` if the Rental rule does not exist.

  ## Examples

      iex> get_rental_rule!(123)
      %RentalRule{}

      iex> get_rental_rule!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rental_rule!(id), do: Repo.get!(RentalRule, id)

  @doc """
  Gets an applicable_rental_rule for the given article.
  Gets article first and preloads associated category.
  Gets the applicable rental_rule for the article and exludes archived rental_rules.
  If none is provided, gets the category active rental_rule. If none is provided again, gets the active rental_rule for the club
  """
  def get_applicable_rental_rule(article_id) do
    article = get_article!(article_id, [:category])

    get_article_rental_rule(article) ||
      get_category_rental_rule(article) ||
      get_club_rental_rule(article)
  end

  defp get_article_rental_rule(article) do
    from(r in RentalRule,
      where:
        r.article_id == ^article.id and
          is_nil(r.archived_at),
      limit: 1
    )
    |> Repo.one()
  end

  defp get_category_rental_rule(%{category_id: nil}), do: nil

  defp get_category_rental_rule(article) do
    from(r in RentalRule,
      where:
        r.category_id == ^article.category_id and
          is_nil(r.archived_at),
      limit: 1
    )
    |> Repo.one()
  end

  defp get_club_rental_rule(article) do
    from(r in RentalRule,
      where:
        r.club_id == ^article.club_id and
          is_nil(r.article_id) and
          is_nil(r.category_id) and
          is_nil(r.archived_at),
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Gets rental_rule. Preloads associations.
  """
  def get_rental_rule!(id, preloads) do
    RentalRule
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a rental_rule.

  ## Examples

      iex> create_rental_rule(%{field: value})
      {:ok, %RentalRule{}}

      iex> create_rental_rule(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rental_rule(attrs \\ %{}) do
    %RentalRule{}
    |> RentalRule.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rental_rule.

  ## Examples

      iex> update_rental_rule(rental_rule, %{field: new_value})
      {:ok, %RentalRule{}}

      iex> update_rental_rule(rental_rule, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rental_rule(%RentalRule{} = rental_rule, attrs) do
    rental_rule
    |> RentalRule.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a rental_rule.

  ## Examples

      iex> delete_rental_rule(rental_rule)
      {:ok, %RentalRule{}}

      iex> delete_rental_rule(rental_rule)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rental_rule(%RentalRule{} = rental_rule) do
    Repo.delete(rental_rule)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rental_rule changes.

  ## Examples

      iex> change_rental_rule(rental_rule)
      %Ecto.Changeset{data: %RentalRule{}}

  """
  def change_rental_rule(%RentalRule{} = rental_rule, attrs \\ %{}) do
    RentalRule.changeset(rental_rule, attrs)
  end

  @doc """
  Archives rental_rule.
  Checks if associated active rental exists.
  If it exists, it returns an error.
  If it notes exists, archive_date is extended to rental_rule.
  """
  def archive_rental_rule(%RentalRule{} = rental_rule) do
    active_rentals_exist? =
      Repo.exists?(
        from r in Rental,
          where:
            r.rental_rule_id == ^rental_rule.id and
              r.status == "active"
      )

    if active_rentals_exist? do
      {:error, :rental_rule_has_active_rentals}
    else
      rental_rule
      |> Ecto.Changeset.change(archived_at: DateTime.utc_now() |> DateTime.truncate(:second))
      |> Repo.update()
    end
  end
end
