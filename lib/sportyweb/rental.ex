defmodule Sportyweb.Rental do
  @moduledoc """
  The Rental context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo
  alias Sportyweb.Rental.Category
  alias Sportyweb.Rental.Article
  alias Sportyweb.Rental.RentalFee
  alias Sportyweb.Rental.ArticleRentalFee
  alias Sportyweb.Rental.CategoryRentalFee
  alias Sportyweb.Rental.Unit
  alias Sportyweb.Rental.Loan
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact

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

  def get_article_with_active_loans!(id) do
    active_loans_query = from(l in Loan, where: l.status == "active")
    Article
    |> Repo.get!(id)
    |> Repo.preload([:club, :department, :category, :rental_fees, units: :location, loans: {active_loans_query, [:unit, :location, :contact]}])
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

  def list_available_units(article_id, location_id) do
    if is_nil(location_id) || (is_binary(location_id) && String.trim(location_id) == "") do
      []
    else
      query =
        from(u in Unit,
          where: u.location_id == ^location_id,
          where: u.article_id == ^article_id,
          where: u.occupied == false,
          where: u.for_lending == true,
          order_by: u.serial_number
        )

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



  def get_unit_with_inactive_loans!(id) do
    inactive_loans_query = from(l in Loan, where: l.status != "active")
    Unit
    |> Repo.get!(id)
    |> Repo.preload([:location, article: :club, loans: {inactive_loans_query, [:article, :location, :contact]}])
  end

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

  alias Sportyweb.Rental.Loan

  @doc """
  Returns the list of loans.

  ## Examples

      iex> list_loans()
      [%Loan{}, ...]

  """
  def list_loans do
    Repo.all(Loan)
  end

  @doc """
  Gets a single loan.

  Raises `Ecto.NoResultsError` if the Loan does not exist.

  ## Examples

      iex> get_loan!(123)
      %Loan{}

      iex> get_loan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_loan!(id), do: Repo.get!(Loan, id)

  @doc """
  Gets a single loan. Preloads associations.

  Raises `Ecto.NoResultsError` if the Loan does not exist.

  ## Examples

      iex> get_loan!(123, [:club])
      %Unit{}

      iex> get_loan!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_loan!(id, preloads) do
    Loan
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a loan under a transaction. Also updates the occupied status of the unit.

  ## Examples

      iex> c reate_loan(%{field: value})
      {:ok, %Loan{}}

      iex> create_loan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_loan(attrs \\ %{}) do
    loan_attrs = Map.merge(attrs, %{
      "status" => "active"
    })

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:loan, Loan.changeset(%Loan{}, loan_attrs))
    |> Ecto.Multi.update(:unit, fn %{loan: loan} ->
      Unit.changeset(
        get_unit!(loan.unit_id),
        %{
          occupied: true
        }
      )
    end)
    |> Repo.transaction()
  end

  @doc """
  Updates a loan.

  ## Examples

      iex> update_loan(loan, %{field: new_value})
      {:ok, %Loan{}}

      iex> update_loan(loan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_loan(%Loan{} = loan, attrs) do
    loan
    |> Loan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a loan.

  ## Examples

      iex> delete_loan(loan)
      {:ok, %Loan{}}

      iex> delete_loan(loan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_loan(%Loan{} = loan) do
    Repo.delete(loan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking loan changes.

  ## Examples

      iex> change_loan(loan)
      %Ecto.Changeset{data: %Loan{}}

  """
  def change_loan(%Loan{} = loan, attrs \\ %{}) do
    Loan.changeset(loan, attrs)
  end

  @doc """
  Calculates the return date for a given article based on the loan period defined in the article or its category.
  ## Examples

      iex> calculate_return_date(article_id)
      ~D[2024-07-01]

      iex> calculate_return_date(article_id_with_no_loan_period)
      nil
  """

  def calculate_return_date(article_id, loan_date) do
    article = get_article!(article_id, :category)

    loan_period =
      article.loan_period ||
      if article.category, do: article.category.loan_period, else: nil

    if loan_period do
    Date.add(loan_date, loan_period)
    else
      nil
    end
  end


  def renew_loan(%Loan{} = loan, attrs) do
    loan
    |> Loan.changeset(attrs)
    |> Loan.changeset(%{renewal_count: loan.renewal_count + 1})
    |> Repo.update()
  end

  def return_loan(%Loan{} = loan, attrs) do
    unit = get_unit!(loan.unit_id)

    loan_attrs = Map.merge(attrs, %{
      "status" => "returned"
    })

    Ecto.Multi.new()
    |> Ecto.Multi.update(:loan, Loan.changeset(loan, loan_attrs))
    |> Ecto.Multi.update(:unit, Unit.changeset(unit, %{occupied: false}))
    |> Repo.transaction()
  end
  def calculate_new_return_date(%Loan{} = loan, article_id) do
    article = get_article!(article_id, :loans)

    case article.renewal_period do
      nil ->
        nil

      renewal_period ->
        Date.add(loan.return_date, renewal_period)
    end
  end

  alias Sportyweb.Rental.RentalFee

  @doc """
  Returns the list of rental_fee.

  ## Examples

      iex> list_rental_fee()
      [%RentalFee{}, ...]

  """
  def list_rental_fee do
    Repo.all(RentalFee)
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

  def create_category_rental_fee(%Category{} = category, %RentalFee{} = rental_fee) do
    Repo.insert(%CategoryRentalFee{
      category_id: category.id,
      rental_fee_id: rental_fee.id
    })
  end

  def create_article_rental_fee(%Article{} = article, %RentalFee{} = rental_fee) do
    Repo.insert(%ArticleRentalFee{
      article_id: article.id,
      rental_fee_id: rental_fee.id
    })
  end



def list_belonging_rental_fees(article_id, contact_id) do
  IO.inspect(article_id, label: "article")
  IO.inspect(contact_id, label: "contact")

  if is_nil(contact_id) || (is_binary(contact_id) && String.trim(contact_id) == "") do
    []
  else
    contact = Personal.get_contact!(contact_id, [:contracts])

    query =
    from rf in RentalFee,
    where: rf.article_id == ^article_id

    query =
  if Contact.has_active_membership_contract?(contact) do
    from rf in query,
      where: rf.member_type == ^:member,
      order_by: [asc: rf.name]
  else
    from rf in query,
      where: rf.member_type == ^:non_member or is_nil(rf.member_type),
      order_by: [asc: rf.name]
  end

    query =
      if Contact.is_person?(contact) do
        contact_age_in_years = Contact.age_in_years(contact)

        from rf in query,
          where:
            is_nil(rf.minimum_age_in_years) or
              rf.minimum_age_in_years <= ^contact_age_in_years,
          where:
            is_nil(rf.maximum_age_in_years) or
              rf.maximum_age_in_years >= ^contact_age_in_years
      else
        query
      end
    IO.inspect(Repo.all(query), label: "Rental Fees")
    Repo.all(query)
  end
end

end
