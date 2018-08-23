defmodule Githubist.Developers do
  @moduledoc """
  The Developers context.
  """

  import Ecto.Query, warn: false
  alias Githubist.Repo

  alias Ecto.Changeset
  alias Githubist.Developers.Developer
  alias Githubist.Repositories.Repository

  @type order_direction :: :desc | :asc

  @type order_field :: :score | :total_starred | :followers | :github_created_at

  @type list_params :: %{
          limit: integer(),
          offset: integer(),
          order_by: {order_direction(), order_field()}
        }

  @doc """
  Gets a single developer.
  """
  @spec get_developer(integer()) :: Developer.t() | nil
  def get_developer(id), do: Repo.get(Developer, id)

  @doc """
  Gets a single developer and raise an exception if it does not exist.
  """
  @spec get_developer!(integer()) :: Developer.t() | no_return()
  def get_developer!(id), do: Repo.get!(Developer, id)

  @doc """
  Gets a single developer by username.
  """
  @spec get_developer_by_username(String.t()) :: Developer.t() | nil
  def get_developer_by_username(username), do: Repo.get_by(Developer, username: username)

  @doc """
  Gets a single developer by username and raise an exception if it does not exist.
  """
  @spec get_developer_by_username!(String.t()) :: Developer.t() | no_return()
  def get_developer_by_username!(username), do: Repo.get_by!(Developer, username: username)

  @doc """
  Creates a developer.
  """
  @spec create_developer(map()) :: {:ok, Developer.t()} | {:error, Changeset.t()}
  def create_developer(attrs \\ %{}) do
    %Developer{}
    |> Developer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Get all developers with limit and order
  """
  @spec all(list_params()) :: list(Developer.t())
  def all(%{limit: limit, offset: offset, order_by: order_by}) do
    query = from(Developer, order_by: ^order_by, limit: ^limit, offset: ^offset)

    Repo.all(query)
  end

  @doc """
  Get developers count
  """
  @spec get_developers_count() :: integer()
  def get_developers_count do
    query = from(d in Developer, select: count(d.id))

    Repo.one(query)
  end

  @doc """
  Get repositories of a developer with limit and order
  """
  @spec get_repositories(Developer.t(), list_params()) :: list(Developer.t())
  def get_repositories(%Developer{} = developer, params) do
    query =
      from(r in Repository,
        where: r.developer_id == ^developer.id,
        order_by: ^params.order_by,
        limit: ^params.limit,
        offset: ^params.offset
      )

    Repo.all(query)
  end

  @doc """
  Get the position of developer
  """
  @spec get_rank(Developer.t(), :turkey | :in_location) :: integer()
  def get_rank(%Developer{} = developer, type) do
    # credo:disable-for-lines:3
    rank_query =
      (d in Developer)
      |> from()
      |> select([d], %{id: d.id, rank: fragment("RANK() OVER(ORDER BY ? DESC)", d.score)})
      |> maybe_location_for_rank(developer, type)

    query = from(r in subquery(rank_query), select: r.rank, where: r.id == ^developer.id)

    Repo.one(query)
  end

  @doc """
  Get repositories count of developer
  """
  @spec get_repositories_count(Developer.t()) :: integer()
  def get_repositories_count(%Developer{} = developer) do
    query = from(r in Repository, select: count(r.id), where: r.developer_id == ^developer.id)

    Repo.one(query)
  end

  defp maybe_location_for_rank(query, developer, type) do
    case type do
      :turkey -> query
      :in_location -> query |> where([d], d.location_id == ^developer.location_id)
    end
  end
end
