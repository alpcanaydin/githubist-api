defmodule GithubistWeb.Resolvers.TurkeyResolver do
  @moduledoc false

  alias Githubist.Developers
  alias Githubist.Languages
  alias Githubist.Locations
  alias Githubist.Repositories

  def get(_parent, _params, _resolution) do
    total_developers = Developers.get_developers_count()
    total_languages = Languages.get_languages_count()
    total_locations = Locations.get_locations_count()
    total_repositories = Repositories.get_repositories_count()

    {:ok,
     %{
       total_developers: total_developers,
       total_languages: total_languages,
       total_locations: total_locations,
       total_repositories: total_repositories
     }}
  end
end
