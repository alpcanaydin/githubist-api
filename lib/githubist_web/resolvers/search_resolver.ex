defmodule GithubistWeb.Resolvers.SearchResolver do
  @moduledoc false

  alias Githubist.Developers
  alias Githubist.Languages
  alias Githubist.Locations
  alias Githubist.Repositories

  def search(_parent, %{query: query}, _resolution) do
    limit = 5

    developer_results = Developers.search(query, limit)
    language_results = Languages.search(query, limit)
    location_results = Locations.search(query, limit)
    repository_results = Repositories.search(query, limit)

    results =
      developer_results
      |> Enum.concat(language_results)
      |> Enum.concat(location_results)
      |> Enum.concat(repository_results)
      |> Enum.take(limit)

    {:ok, results}
  end
end
