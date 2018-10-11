defmodule Githubist.Languages do
  @moduledoc """
  The Languages context.
  """

  import Ecto.Query, warn: false
  alias Githubist.Repo

  alias Ecto.Changeset
  alias Githubist.Developers
  alias Githubist.Developers.Developer
  alias Githubist.Languages.Language
  alias Githubist.Locations
  alias Githubist.Locations.Location
  alias Githubist.Repositories
  alias Githubist.Repositories.Repository

  @type order_direction :: :desc | :asc

  @type order_field :: :name | :score | :total_stars | :total_repositories | :total_developers

  @type usage_params :: %{limit: integer(), offset: integer()}

  @type list_params :: %{
          limit: integer(),
          offset: integer(),
          order_by: {order_direction(), order_field()}
        }

  @doc """
  Gets a single language.
  """
  @spec get_language(integer()) :: Developer.t() | nil
  def get_language(id), do: Repo.get(Language, id)

  @doc """
  Gets a single language and raise an exception if it does not exist.
  """
  @spec get_language!(integer()) :: Developer.t() | no_return()
  def get_language!(id), do: Repo.get!(Language, id)

  @doc """
  Gets a single language by slug.
  """
  @spec get_language_by_slug(String.t()) :: Developer.t() | nil
  def get_language_by_slug(slug), do: Repo.get_by(Language, slug: slug)

  @doc """
  Gets a single language by slug and raise an exception if it does not exist.
  """
  @spec get_language_by_slug!(String.t()) :: Developer.t() | no_return()
  def get_language_by_slug!(slug), do: Repo.get_by!(Language, slug: slug)

  @doc """
  Creates a language.
  """
  @spec create_language(map()) :: {:ok, Language.t()} | {:error, Changeset.t()}
  def create_language(attrs \\ %{}) do
    %Language{}
    |> Language.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Get all languages with limit and order
  """
  @spec all(list_params()) :: list(Developer.t())
  def all(%{limit: limit, offset: offset, order_by: order_by}) do
    query =
      from(Language, order_by: ^order_by, order_by: {:asc, :id}, limit: ^limit, offset: ^offset)

    Repo.all(query)
  end

  @doc """
  Get languages count
  """
  @spec get_languages_count() :: integer()
  def get_languages_count do
    query = from(l in Language, select: count(l.id))

    Repo.one(query)
  end

  @doc """
  Get repositories in a language with limit and order
  """
  @spec get_repositories(Language.t(), Repositories.list_params()) :: list(Repository.t())
  def get_repositories(%Language{} = language, params) do
    query =
      from(r in Repository,
        where: r.language_id == ^language.id,
        order_by: ^params.order_by,
        order_by: {:asc, :id},
        limit: ^params.limit,
        offset: ^params.offset
      )

    Repo.all(query)
  end

  @doc """
  Get the postion of language
  """
  @spec get_rank(Language.t()) :: integer()
  def get_rank(%Language{} = language) do
    rank_query =
      from(l in Language,
        select: %{id: l.id, rank: fragment("RANK() OVER(ORDER BY ? DESC)", l.score)}
      )

    query = from(r in subquery(rank_query), select: r.rank, where: r.id == ^language.id)

    Repo.one(query)
  end

  @doc """
  Get the postion of language according to repositories count
  """
  @spec get_repositories_count_rank(Language.t()) :: integer()
  def get_repositories_count_rank(%Language{} = language) do
    rank_query =
      from(l in Language,
        select: %{id: l.id, rank: fragment("RANK() OVER(ORDER BY ? DESC)", l.total_repositories)}
      )

    query = from(r in subquery(rank_query), select: r.rank, where: r.id == ^language.id)

    Repo.one(query)
  end

  @doc """
  Get the postion of language according to developers count
  """
  @spec get_developers_count_rank(Language.t()) :: integer()
  def get_developers_count_rank(%Language{} = language) do
    rank_query =
      from(l in Language,
        select: %{id: l.id, rank: fragment("RANK() OVER(ORDER BY ? DESC)", l.total_developers)}
      )

    query = from(r in subquery(rank_query), select: r.rank, where: r.id == ^language.id)

    Repo.one(query)
  end

  @doc """
  Get repositories count which uses the given language
  """
  @spec get_repositories_count(Language.t()) :: integer()
  def get_repositories_count(%Language{} = language) do
    query = from(r in Repository, select: count(r.id), where: r.language_id == ^language.id)

    Repo.one(query)
  end

  @doc """
  Get repositories count which uses the given language
  """
  @spec get_developers_count(Language.t()) :: integer()
  def get_developers_count(%Language{} = language) do
    query =
      from(r in Repository,
        select: count(r.developer_id, :distinct),
        where: r.language_id == ^language.id
      )

    Repo.one(query)
  end

  @doc """
  Get language usage in a location
  """
  @spec get_location_usage(Location.t(), usage_params()) ::
          list(%{language: Language.t(), repositories_count: integer()})
  def get_location_usage(%Location{} = location, %{limit: limit, offset: offset}) do
    query =
      from(r in Repository,
        select: %{repositories_count: count(r.id), language_id: r.language_id},
        join: d in Developer,
        on: d.id == r.developer_id,
        where: d.location_id == ^location.id,
        group_by: r.language_id,
        order_by: [desc: count(r.id)],
        order_by: {:asc, r.language_id},
        limit: ^limit,
        offset: ^offset
      )

    results = Repo.all(query)

    Enum.map(results, fn item ->
      %{
        language: get_language(item.language_id),
        repositories_count: item.repositories_count
      }
    end)
  end

  @doc """
  Get language usage for a developer
  """
  @spec get_developer_usage(Developer.t(), usage_params()) ::
          list(%{language: Language.t(), repositories_count: integer()})
  def get_developer_usage(%Developer{} = developer, %{limit: limit, offset: offset}) do
    query =
      from(r in Repository,
        select: %{repositories_count: count(r.id), language_id: r.language_id},
        where: r.developer_id == ^developer.id,
        group_by: r.language_id,
        order_by: [desc: count(r.id)],
        order_by: {:asc, r.language_id},
        limit: ^limit,
        offset: ^offset
      )

    results = Repo.all(query)

    Enum.map(results, fn item ->
      %{
        language: get_language(item.language_id),
        repositories_count: item.repositories_count
      }
    end)
  end

  @doc """
  Get location stats for a language
  """
  @spec get_location_stats(Language.t(), usage_params()) ::
          list(%{location: Location.t(), repositories_count: integer()})
  def get_location_stats(%Language{} = language, %{limit: limit, offset: offset}) do
    query =
      from(r in Repository,
        join: d in Developer,
        on: d.id == r.developer_id,
        select: %{repositories_count: count(r.id), location_id: d.location_id},
        where: r.language_id == ^language.id,
        group_by: d.location_id,
        order_by: [desc: count(r.id)],
        order_by: {:asc, d.location_id},
        limit: ^limit,
        offset: ^offset
      )

    results = Repo.all(query)

    Enum.map(results, fn item ->
      %{
        location: Locations.get_location(item.location_id),
        repositories_count: item.repositories_count
      }
    end)
  end

  @doc """
  Get developer stats for a language
  """
  @spec get_developer_stats(Language.t(), usage_params()) ::
          list(%{developer: Developer.t(), repositories_count: integer()})
  def get_developer_stats(%Language{} = language, %{limit: limit, offset: offset}) do
    query =
      from(r in Repository,
        select: %{repositories_count: count(r.id), developer_id: r.developer_id},
        where: r.language_id == ^language.id,
        group_by: r.developer_id,
        order_by: [desc: count(r.id)],
        order_by: {:asc, r.developer_id},
        limit: ^limit,
        offset: ^offset
      )

    results = Repo.all(query)

    Enum.map(results, fn item ->
      %{
        developer: Developers.get_developer(item.developer_id),
        repositories_count: item.repositories_count
      }
    end)
  end
end
