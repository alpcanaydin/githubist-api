defmodule GithubistWeb.Resolvers.DeveloperResolver do
  @moduledoc false

  alias Githubist.Developers
  alias Githubist.Developers.Developer
  alias Githubist.GraphQLArgumentParser
  alias Githubist.Locations
  alias Githubist.Locations.Location

  def all(%Location{} = location, params, _resolution) do
    params =
      params
      |> GraphQLArgumentParser.parse_limit(max_limit: 100)
      |> GraphQLArgumentParser.parse_order_by()

    developers = Locations.get_developers(location, params)

    {:ok, developers}
  end

  def all(_parent, params, _resolution) do
    params =
      params
      |> GraphQLArgumentParser.parse_limit(max_limit: 100)
      |> GraphQLArgumentParser.parse_order_by()

    developers = Developers.all(params)

    {:ok, developers}
  end

  def get(_parent, %{username: username}, _resolution) do
    case Developers.get_developer_by_username(username) do
      nil -> {:error, "Developer with username #{username} could not be found."}
      developer -> {:ok, developer}
    end
  end

  def get_stats(%Developer{} = developer, _params, _resolution) do
    stats = %{
      rank: Developers.get_rank(developer, :turkey),
      location_rank: Developers.get_rank(developer, :in_location),
      repositories_count: Developers.get_repositories_count(developer)
    }

    {:ok, stats}
  end
end
