defmodule GithubistWeb.GraphQL.LocationTest do
  use GithubistWeb.ConnCase

  import GithubistWeb.TestSupport.GraphQLHelper

  alias Githubist.TestSupport.DevelopersHelper
  alias Githubist.TestSupport.LanguagesHelper
  alias Githubist.TestSupport.LocationsHelper
  alias Githubist.TestSupport.RepositoriesHelper

  @basic_query """
    query($slug: String!) {
      location(slug: $slug) {
        id
        name
        slug
        score
        totalRepositories
        totalDevelopers
        stats {
          rank
        }
      }
    }
  """

  @with_developers_query """
    query($slug: String!) {
      location(slug: $slug) {
        id
        developers(limit: 10, offset: 0, orderBy: {direction: DESC, field: NAME}) {
          username
        }
      }
    }
  """

  @with_repositories_query """
    query($slug: String!) {
      location(slug: $slug) {
        id
        repositories(limit: 10, offset: 0, orderBy: {direction: DESC, field: NAME}) {
          name
        }
      }
    }
  """

  @with_language_usage_query """
    query($slug: String!) {
      location(slug: $slug) {
        id
        languageUsage(limit: 10, offset: 0) {
          language {
            name
          }

          repositoriesCount
        }
      }
    }
  """

  setup do
    location =
      LocationsHelper.create_location(%{
        name: "Location 1",
        slug: "location-1",
        score: 1.0,
        totalRepositories: 1,
        totalDevelopers: 1
      })

    language = LanguagesHelper.create_language(%{name: "language"})

    developer =
      DevelopersHelper.create_developer(%{location_id: location.id, username: "username"})

    RepositoriesHelper.create_repository(%{
      name: "repository",
      language_id: language.id,
      developer_id: developer.id
    })

    {:ok, %{location: location}}
  end

  test "returns basic data", %{conn: conn, location: location} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", %{query: @basic_query, variables: %{slug: "location-1"}})

    assert json_response(conn, 200) === %{
             "data" => %{
               "location" => %{
                 "id" => to_string(location.id),
                 "name" => location.name,
                 "slug" => location.slug,
                 "score" => location.score,
                 "totalRepositories" => location.total_repositories,
                 "totalDevelopers" => location.total_developers,
                 "stats" => %{
                   "rank" => 1
                 }
               }
             }
           }
  end

  test "returns developers for location", %{conn: conn, location: location} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", %{query: @with_developers_query, variables: %{slug: "location-1"}})

    assert json_response(conn, 200) === %{
             "data" => %{
               "location" => %{
                 "id" => to_string(location.id),
                 "developers" => [
                   %{"username" => "username"}
                 ]
               }
             }
           }
  end

  test "returns repositories for location", %{conn: conn, location: location} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", %{query: @with_repositories_query, variables: %{slug: "location-1"}})

    assert json_response(conn, 200) === %{
             "data" => %{
               "location" => %{
                 "id" => to_string(location.id),
                 "repositories" => [
                   %{"name" => "repository"}
                 ]
               }
             }
           }
  end

  test "returns language usage for location", %{conn: conn, location: location} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", %{query: @with_language_usage_query, variables: %{slug: "location-1"}})

    assert json_response(conn, 200) === %{
             "data" => %{
               "location" => %{
                 "id" => to_string(location.id),
                 "languageUsage" => [
                   %{"language" => %{"name" => "language"}, "repositoriesCount" => 1}
                 ]
               }
             }
           }
  end
end
