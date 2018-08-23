defmodule Githubist.Repositories do
  @moduledoc """
  The Repositories context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Changeset
  alias Githubist.Repo
  alias Githubist.Repositories.Repository

  @type order_direction :: :desc | :asc

  @type order_field :: :name | :stars | :forks | :github_created_at

  @type list_params :: %{
          limit: integer(),
          offset: integer(),
          order_by: {order_direction(), order_field()}
        }

  @doc """
  Gets a single repository.
  """
  @spec get_repository(integer()) :: Repository.t() | nil
  def get_repository(id), do: Repo.get(Repository, id)

  @doc """
  Gets a single repository and raise an exception if it does not exist.
  """
  @spec get_repository!(integer()) :: Repository.t() | no_return()
  def get_repository!(id), do: Repo.get!(Repository, id)

  @doc """
  Gets a single repository by slug.
  """
  @spec get_repository_by_slug(String.t()) :: Repository.t() | nil
  def get_repository_by_slug(slug), do: Repo.get_by(Repository, slug: slug)

  @doc """
  Gets a single repository by slug and raise an exception if it does not exist.
  """
  @spec get_repository_by_slug!(String.t()) :: Repository.t() | no_return()
  def get_repository_by_slug!(slug), do: Repo.get_by!(Repository, slug: slug)

  @doc """
  Creates a repository.
  """
  @spec create_repository(map()) :: {:ok, Repository.t()} | {:error, Changeset.t()}
  def create_repository(attrs \\ %{}) do
    %Repository{}
    |> Repository.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Get all repositories with limit and order
  """
  @spec all(list_params()) :: list(Repository.t())
  def all(%{limit: limit, order_by: order_by, offset: offset}) do
    query = from(Repository, order_by: ^order_by, limit: ^limit, offset: ^offset)

    Repo.all(query)
  end

  @doc """
  Get repositories count
  """
  @spec get_repositories_count() :: integer()
  def get_repositories_count do
    query = from(r in Repository, select: count(r.id))

    Repo.one(query)
  end

  @doc """
  Get the position of repository in Turkey
  """
  @spec get_rank(Repository.t(), :turkey | :in_language) :: integer()
  def get_rank(%Repository{} = repository, type) do
    # credo:disable-for-lines:3
    rank_query =
      (r in Repository)
      |> from()
      |> select([r], %{id: r.id, rank: fragment("RANK() OVER(ORDER BY ? DESC)", r.stars)})
      |> maybe_language_for_rank(repository, type)

    query = from(r in subquery(rank_query), select: r.rank, where: r.id == ^repository.id)

    Repo.one(query)
  end

  defp maybe_language_for_rank(query, repository, type) do
    case type do
      :turkey -> query
      :in_language -> query |> where([d], d.language_id == ^repository.language_id)
    end
  end
end
