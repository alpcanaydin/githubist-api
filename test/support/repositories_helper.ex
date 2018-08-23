defmodule Githubist.TestSupport.RepositoriesHelper do
  @moduledoc """
  Test helper for location related logic
  """

  alias Githubist.Repositories
  alias Githubist.Repositories.Repository

  @repository_attrs %{
    name: "repo",
    slug: "username/repo",
    github_id: 123,
    github_url: "https://github.com/username/repo",
    stars: 100,
    forks: 100,
    github_created_at: DateTime.utc_now()
  }

  @spec create_repository(map()) :: Repository.t()
  def create_repository(attrs \\ %{}) do
    merged_attrs =
      @repository_attrs
      |> Map.merge(attrs)

    {:ok, repository} = Repositories.create_repository(merged_attrs)

    repository
  end

  @spec get_repository_attrs() :: map()
  def get_repository_attrs do
    @repository_attrs
  end
end
