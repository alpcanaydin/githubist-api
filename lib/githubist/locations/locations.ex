defmodule Githubist.Locations do
  @moduledoc """
  The Locations context.
  """

  import Ecto.Query, warn: false
  alias Githubist.Repo

  alias Ecto.Changeset
  alias Githubist.Developers.Developer
  alias Githubist.Locations.Location
  alias Githubist.Repositories.Repository

  @type order_direction :: :desc | :asc

  @type order_field :: :name | :score

  @type list_params :: %{
          limit: integer(),
          offset: integer(),
          order_by: {order_direction(), order_field()}
        }

  @doc """
  Gets a single location.
  """
  @spec get_location(integer()) :: Location.t() | nil
  def get_location(id), do: Repo.get(Location, id)

  @doc """
  Gets a single location and raise an exception if it does not exist.
  """
  @spec get_location!(integer()) :: Location.t() | no_return()
  def get_location!(id), do: Repo.get!(Location, id)

  @doc """
  Gets a single location by slug.
  """
  @spec get_location_by_slug(String.t()) :: Location.t() | nil
  def get_location_by_slug(slug), do: Repo.get_by(Location, slug: slug)

  @doc """
  Gets a single location by slug and raise an exception if it does not exist.
  """
  @spec get_location_by_slug!(String.t()) :: Location.t() | no_return()
  def get_location_by_slug!(slug), do: Repo.get_by!(Location, slug: slug)

  @doc """
  Creates a location.
  """
  @spec create_location(map()) :: {:ok, Location.t()} | {:error, Changeset.t()}
  def create_location(attrs \\ %{}) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Get all locations with limit and order
  """
  @spec all(list_params()) :: list(Location.t())
  def all(%{limit: limit, order_by: order_by, offset: offset}) do
    query = from(Location, order_by: ^order_by, limit: ^limit, offset: ^offset)

    Repo.all(query)
  end

  @doc """
  Get locations count
  """
  @spec get_locations_count() :: integer()
  def get_locations_count do
    query = from(l in Location, select: count(l.id))

    Repo.one(query)
  end

  @doc """
  Get developers at the location with limit and order
  """
  @spec get_developers(Location.t(), list_params()) :: list(Developer.t())
  def get_developers(%Location{} = location, params) do
    query =
      from(d in Developer,
        where: d.location_id == ^location.id,
        order_by: ^params.order_by,
        limit: ^params.limit,
        offset: ^params.offset
      )

    Repo.all(query)
  end

  @doc """
  Get repositories at the location
  """
  @spec get_repositories(Location.t(), list_params()) :: list(Repository.t())
  def get_repositories(%Location{} = location, params) do
    query =
      from(r in Repository,
        select: r,
        join: d in Developer,
        on: d.id == r.developer_id,
        where: d.location_id == ^location.id,
        order_by: ^params.order_by,
        limit: ^params.limit,
        offset: ^params.offset
      )

    Repo.all(query)
  end

  @doc """
  Get the postion of location
  """
  @spec get_rank(Location.t()) :: integer()
  def get_rank(%Location{} = location) do
    rank_query =
      from(l in Location,
        select: %{id: l.id, rank: fragment("RANK() OVER(ORDER BY ? DESC)", l.score)}
      )

    query = from(r in subquery(rank_query), select: r.rank, where: r.id == ^location.id)

    Repo.one(query)
  end

  @doc """
  Get count of developers in a location
  """
  @spec get_developers_count(Location.t()) :: integer()
  def get_developers_count(%Location{} = location) do
    query = from(d in Developer, select: count(d.id), where: d.location_id == ^location.id)

    Repo.one(query)
  end

  @doc """
  Get repositories count of developers who lives in a location
  """
  @spec get_repositories_count(Location.t()) :: integer()
  def get_repositories_count(%Location{} = location) do
    query =
      from(r in Repository,
        select: count(r.id),
        join: d in Developer,
        on: d.id == r.developer_id,
        where: d.location_id == ^location.id
      )

    Repo.one(query)
  end
end
