defmodule GithubistWeb.GraphQL.DeveloperTest do
  use GithubistWeb.ConnCase

  import GithubistWeb.TestSupport.GraphQLHelper

  alias Githubist.TestSupport.DevelopersHelper
  alias Githubist.TestSupport.LanguagesHelper
  alias Githubist.TestSupport.LocationsHelper
  alias Githubist.TestSupport.RepositoriesHelper

  @basic_query """
    query($username: String!) {
      developer(username: $username) {
        id
        username
        github_id
        name
        avatar_url
        bio
        company
        github_location
        github_url
        followers
        following
        public_repos
        total_starred
        score
        github_created_at
        stats {
          rank
          locationRank
          repositoriesCount
        }
      }
    }
  """

  @with_repositories_query """
    query($username: String!) {
      developer(username: $username) {
        id
        repositories(limit: 10, offset: 0, orderBy: {direction: DESC, field: NAME}) {
          name
        }
      }
    }
  """

  @with_language_usage_query """
    query($username: String!) {
      developer(username: $username) {
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
    language = LanguagesHelper.create_language(%{name: "language", slug: "language-1"})

    location =
      LocationsHelper.create_location(%{
        name: "Location 1",
        slug: "location-1"
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

    {:ok, %{developer: developer}}
  end

  test "returns basic data", %{conn: conn, developer: developer} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", %{query: @basic_query, variables: %{username: "username"}})

    assert json_response(conn, 200) === %{
             "data" => %{
               "developer" => %{
                 "id" => to_string(developer.id),
                 "username" => developer.username,
                 "github_id" => developer.github_id,
                 "name" => developer.name,
                 "avatar_url" => developer.avatar_url,
                 "bio" => developer.bio,
                 "company" => developer.company,
                 "github_location" => developer.github_location,
                 "github_url" => developer.github_url,
                 "followers" => developer.followers,
                 "following" => developer.following,
                 "public_repos" => developer.public_repos,
                 "total_starred" => developer.total_starred,
                 "score" => developer.score,
                 "github_created_at" => DateTime.to_iso8601(developer.github_created_at),
                 "stats" => %{
                   "rank" => 1,
                   "locationRank" => 1,
                   "repositoriesCount" => 1
                 }
               }
             }
           }
  end

  test "returns repositories for developer", %{conn: conn, developer: developer} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", %{query: @with_repositories_query, variables: %{username: "username"}})

    assert json_response(conn, 200) === %{
             "data" => %{
               "developer" => %{
                 "id" => to_string(developer.id),
                 "repositories" => [
                   %{"name" => "repository"}
                 ]
               }
             }
           }
  end

  test "returns language usage for developer", %{conn: conn, developer: developer} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", %{query: @with_language_usage_query, variables: %{username: "username"}})

    assert json_response(conn, 200) === %{
             "data" => %{
               "developer" => %{
                 "id" => to_string(developer.id),
                 "languageUsage" => [
                   %{"language" => %{"name" => "language"}, "repositoriesCount" => 1}
                 ]
               }
             }
           }
  end
end
