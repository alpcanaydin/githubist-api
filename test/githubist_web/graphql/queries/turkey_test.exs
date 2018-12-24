defmodule GithubistWeb.GraphQL.TurkeyTests do
  use GithubistWeb.ConnCase

  import GithubistWeb.TestSupport.GraphQLHelper

  alias Githubist.TestSupport.DevelopersHelper
  alias Githubist.TestSupport.LanguagesHelper
  alias Githubist.TestSupport.LocationsHelper
  alias Githubist.TestSupport.RepositoriesHelper

  @query """
    query {
      turkey {
        totalDevelopers
        totalLanguages
        totalLocations
        totalRepositories
      }
    }
  """

  setup do
    location = LocationsHelper.create_location()
    language = LanguagesHelper.create_language()
    developer = DevelopersHelper.create_developer(%{location_id: location.id})
    RepositoriesHelper.create_repository(%{developer_id: developer.id, language_id: language.id})

    :ok
  end

  test "runs correctly", %{conn: conn} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", @query)

    assert json_response(conn, 200) === %{
             "data" => %{
               "turkey" => %{
                 "totalDevelopers" => 1,
                 "totalLanguages" => 1,
                 "totalLocations" => 1,
                 "totalRepositories" => 1
               }
             }
           }
  end
end
