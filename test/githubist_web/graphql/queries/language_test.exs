defmodule GithubistWeb.GraphQL.LanguageTest do
  use GithubistWeb.ConnCase

  import GithubistWeb.TestSupport.GraphQLHelper

  alias Githubist.TestSupport.DevelopersHelper
  alias Githubist.TestSupport.LanguagesHelper
  alias Githubist.TestSupport.LocationsHelper
  alias Githubist.TestSupport.RepositoriesHelper

  @basic_query """
    query($slug: String!) {
      language(slug: $slug) {
        id
        name
        slug
        score
        totalStars
        totalRepositories
        totalDevelopers
        stats {
          rank
          repositoriesCountRank
        }
      }
    }
  """

  @with_repositories_query """
    query($slug: String!) {
      language(slug: $slug) {
        id
        repositories(limit: 10, offset: 0, orderBy: {direction: DESC, field: NAME}) {
          name
        }
      }
    }
  """

  @with_location_usage_query """
    query($slug: String!) {
      language(slug: $slug) {
        id
        locationUsage(limit: 10, offset: 0) {
          location {
            name
          }

          repositoriesCount
        }
      }
    }
  """

  @with_developer_usage_query """
    query($slug: String!) {
      language(slug: $slug) {
        id
        developerUsage(limit: 10, offset: 0) {
          developer {
            name
          }

          repositoriesCount
        }
      }
    }
  """

  setup do
    language = LanguagesHelper.create_language(%{name: "language", slug: "language-1"})

    location =
      LocationsHelper.create_location(%{
        name: "Location 1",
        slug: "location-1",
        score: 1.0
      })

    developer =
      DevelopersHelper.create_developer(%{
        location_id: location.id,
        name: "Developer 1",
        username: "username"
      })

    RepositoriesHelper.create_repository(%{
      name: "repository",
      language_id: language.id,
      developer_id: developer.id
    })

    {:ok, %{language: language}}
  end

  test "returns basic data", %{conn: conn, language: language} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", %{query: @basic_query, variables: %{slug: "language-1"}})

    assert json_response(conn, 200) === %{
             "data" => %{
               "language" => %{
                 "id" => to_string(language.id),
                 "name" => language.name,
                 "slug" => language.slug,
                 "score" => language.score,
                 "totalStars" => language.total_stars,
                 "totalRepositories" => language.total_repositories,
                 "totalDevelopers" => language.total_developers,
                 "stats" => %{
                   "rank" => 1,
                   "repositoriesCountRank" => 1
                 }
               }
             }
           }
  end

  test "returns repositories for language", %{conn: conn, language: language} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", %{query: @with_repositories_query, variables: %{slug: "language-1"}})

    assert json_response(conn, 200) === %{
             "data" => %{
               "language" => %{
                 "id" => to_string(language.id),
                 "repositories" => [
                   %{"name" => "repository"}
                 ]
               }
             }
           }
  end

  test "returns location usage for language", %{conn: conn, language: language} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", %{query: @with_location_usage_query, variables: %{slug: "language-1"}})

    assert json_response(conn, 200) === %{
             "data" => %{
               "language" => %{
                 "id" => to_string(language.id),
                 "locationUsage" => [
                   %{"location" => %{"name" => "Location 1"}, "repositoriesCount" => 1}
                 ]
               }
             }
           }
  end

  test "returns developer usage for language", %{conn: conn, language: language} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", %{query: @with_developer_usage_query, variables: %{slug: "language-1"}})

    assert json_response(conn, 200) === %{
             "data" => %{
               "language" => %{
                 "id" => to_string(language.id),
                 "developerUsage" => [
                   %{"developer" => %{"name" => "Developer 1"}, "repositoriesCount" => 1}
                 ]
               }
             }
           }
  end
end
