defmodule GithubistWeb.Resolvers.RepositoryResolver do
  @moduledoc false

  alias Githubist.Developers
  alias Githubist.Developers.Developer
  alias Githubist.GraphQLArgumentParser
  alias Githubist.Languages
  alias Githubist.Languages.Language
  alias Githubist.Locations
  alias Githubist.Locations.Location
  alias Githubist.Repositories
  alias Githubist.Repositories.Repository

  def all(%Developer{} = developer, params, _resolution) do
    params =
      params
      |> GraphQLArgumentParser.parse_limit(max_limit: 100)
      |> GraphQLArgumentParser.parse_order_by()

    repositories = Developers.get_repositories(developer, params)

    {:ok, repositories}
  end

  def all(%Language{} = language, params, _resolution) do
    params =
      params
      |> GraphQLArgumentParser.parse_limit(max_limit: 100)
      |> GraphQLArgumentParser.parse_order_by()

    repositories = Languages.get_repositories(language, params)

    {:ok, repositories}
  end

  def all(%Location{} = location, params, _resolution) do
    params =
      params
      |> GraphQLArgumentParser.parse_limit(max_limit: 100)
      |> GraphQLArgumentParser.parse_order_by()

    repositories = Locations.get_repositories(location, params)

    {:ok, repositories}
  end

  def all(_parent, params, _resolution) do
    params =
      params
      |> GraphQLArgumentParser.parse_limit(max_limit: 100)
      |> GraphQLArgumentParser.parse_order_by()

    repositories = Repositories.all(params)

    {:ok, repositories}
  end

  def get(_parent, %{slug: slug}, _resolution) do
    case Repositories.get_repository_by_slug(slug) do
      nil -> {:error, message: "Repository with slug #{slug} could not be found.", code: 404}
      repository -> {:ok, repository}
    end
  end

  def get_stats(%Repository{} = repository, _params, _resolution) do
    stats = %{
      rank: Repositories.get_rank(repository, :turkey),
      language_rank: Repositories.get_rank(repository, :in_language)
    }

    {:ok, stats}
  end
end
