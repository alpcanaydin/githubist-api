defmodule GithubistWeb.GraphQL.RepositoryTest do
  use GithubistWeb.ConnCase

  import GithubistWeb.TestSupport.GraphQLHelper

  alias Githubist.TestSupport.DevelopersHelper
  alias Githubist.TestSupport.LanguagesHelper
  alias Githubist.TestSupport.LocationsHelper
  alias Githubist.TestSupport.RepositoriesHelper

  @basic_query """
    query($slug: String!) {
      repository(slug: $slug) {
        id
        name
        slug
        description
        github_id
        github_url
        stars
        forks
        github_created_at
        stats {
          rank
          languageRank
        }
      }
    }
  """

  @with_developer_query """
    query($slug: String!) {
      repository(slug: $slug) {
        id
        developer {
          name
        }
      }
    }
  """

  @with_language_query """
    query($slug: String!) {
      repository(slug: $slug) {
        id
        language {
          name
        }
      }
    }
  """

  setup do
    language = LanguagesHelper.create_language(%{name: "Language 1"})
    location = LocationsHelper.create_location(%{name: "Location 1"})

    developer =
      DevelopersHelper.create_developer(%{location_id: location.id, name: "Developer 1"})

    repository =
      RepositoriesHelper.create_repository(%{
        name: "repository",
        slug: "repository-1",
        description: "Lorem ipsum",
        language_id: language.id,
        developer_id: developer.id
      })

    {:ok, %{repository: repository}}
  end

  test "returns basic data", %{conn: conn, repository: repository} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", %{query: @basic_query, variables: %{slug: "repository-1"}})

    assert json_response(conn, 200) === %{
             "data" => %{
               "repository" => %{
                 "id" => to_string(repository.id),
                 "name" => repository.name,
                 "slug" => repository.slug,
                 "description" => repository.description,
                 "github_id" => repository.github_id,
                 "github_url" => repository.github_url,
                 "stars" => repository.stars,
                 "forks" => repository.forks,
                 "github_created_at" => DateTime.to_iso8601(repository.github_created_at),
                 "stats" => %{
                   "rank" => 1,
                   "languageRank" => 1
                 }
               }
             }
           }
  end

  test "returns developer of repository", %{conn: conn, repository: repository} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", %{query: @with_developer_query, variables: %{slug: "repository-1"}})

    assert json_response(conn, 200) === %{
             "data" => %{
               "repository" => %{
                 "id" => to_string(repository.id),
                 "developer" => %{"name" => "Developer 1"}
               }
             }
           }
  end

  test "returns language of repository", %{conn: conn, repository: repository} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", %{query: @with_language_query, variables: %{slug: "repository-1"}})

    assert json_response(conn, 200) === %{
             "data" => %{
               "repository" => %{
                 "id" => to_string(repository.id),
                 "language" => %{"name" => "Language 1"}
               }
             }
           }
  end
end
