defmodule GithubistWeb.GraphQL.RepositoriesTest do
  use GithubistWeb.ConnCase

  import GithubistWeb.TestSupport.GraphQLHelper

  alias Githubist.TestSupport.DevelopersHelper
  alias Githubist.TestSupport.LanguagesHelper
  alias Githubist.TestSupport.LocationsHelper
  alias Githubist.TestSupport.RepositoriesHelper

  @basic_query """
    query {
      repositories(limit: 2, offset: 0, orderBy:{direction: DESC, field: STARS}) {
        id
        name
        slug
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
    query {
      repositories(limit: 2, offset: 0, orderBy:{direction: DESC, field: STARS}) {
        name
        developer {
          name
        }
      }
    }
  """

  @with_language_query """
    query {
      repositories(limit: 2, offset: 0, orderBy:{direction: DESC, field: STARS}) {
        name
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

    repository1 =
      RepositoriesHelper.create_repository(%{
        name: "Repository 1",
        slug: "repository-1",
        developer_id: developer.id,
        language_id: language.id,
        stars: 1
      })

    repository2 =
      RepositoriesHelper.create_repository(%{
        name: "Repository 2",
        slug: "repository-2",
        developer_id: developer.id,
        language_id: language.id,
        stars: 2
      })

    repository3 =
      RepositoriesHelper.create_repository(%{
        name: "Repository 3",
        slug: "repository-3",
        developer_id: developer.id,
        language_id: language.id,
        stars: 3
      })

    {:ok, %{repositories: {repository1, repository2, repository3}}}
  end

  test "returns basic data", %{conn: conn, repositories: {_, repository2, repository3}} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", @basic_query)

    assert json_response(conn, 200) === %{
             "data" => %{
               "repositories" => [
                 %{
                   "id" => to_string(repository3.id),
                   "name" => repository3.name,
                   "slug" => repository3.slug,
                   "github_id" => repository3.github_id,
                   "github_url" => repository3.github_url,
                   "stars" => repository3.stars,
                   "forks" => repository3.forks,
                   "github_created_at" => DateTime.to_iso8601(repository3.github_created_at),
                   "stats" => %{
                     "rank" => 1,
                     "languageRank" => 1
                   }
                 },
                 %{
                   "id" => to_string(repository2.id),
                   "name" => repository2.name,
                   "slug" => repository2.slug,
                   "github_id" => repository2.github_id,
                   "github_url" => repository2.github_url,
                   "stars" => repository2.stars,
                   "forks" => repository2.forks,
                   "github_created_at" => DateTime.to_iso8601(repository2.github_created_at),
                   "stats" => %{
                     "rank" => 2,
                     "languageRank" => 2
                   }
                 }
               ]
             }
           }
  end

  test "returns developer of repository", %{conn: conn} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", @with_developer_query)

    assert json_response(conn, 200) === %{
             "data" => %{
               "repositories" => [
                 %{
                   "name" => "Repository 3",
                   "developer" => %{"name" => "Developer 1"}
                 },
                 %{
                   "name" => "Repository 2",
                   "developer" => %{"name" => "Developer 1"}
                 }
               ]
             }
           }
  end

  test "returns language of repository", %{conn: conn} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", @with_language_query)

    assert json_response(conn, 200) === %{
             "data" => %{
               "repositories" => [
                 %{
                   "name" => "Repository 3",
                   "language" => %{"name" => "Language 1"}
                 },
                 %{
                   "name" => "Repository 2",
                   "language" => %{"name" => "Language 1"}
                 }
               ]
             }
           }
  end
end
