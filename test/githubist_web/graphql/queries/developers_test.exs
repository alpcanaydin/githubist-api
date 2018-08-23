defmodule GithubistWeb.GraphQL.DevelopersTest do
  use GithubistWeb.ConnCase

  import GithubistWeb.TestSupport.GraphQLHelper

  alias Githubist.TestSupport.DevelopersHelper
  alias Githubist.TestSupport.LanguagesHelper
  alias Githubist.TestSupport.LocationsHelper
  alias Githubist.TestSupport.RepositoriesHelper

  @basic_query """
    query {
      developers(limit: 2, offset: 0, orderBy:{direction: DESC, field: SCORE}) {
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
    query {
      developers(limit: 2, offset: 0, orderBy:{direction: DESC, field: SCORE}) {
        name
        repositories(limit: 2, offset: 0, orderBy: {direction: ASC, field: NAME}) {
          name
        }
      }
    }
  """

  @with_language_usage_query """
    query {
      developers(limit: 2, offset: 0, orderBy:{direction: DESC, field: SCORE}) {
        name
        languageUsage(limit: 2, offset: 0) {
          language {
            name
          }

          repositoriesCount
        }
      }
    }
  """

  setup do
    location = LocationsHelper.create_location(%{name: "Location 1"})
    language = LanguagesHelper.create_language(%{name: "Language 1"})

    developer1 =
      DevelopersHelper.create_developer(%{
        name: "Developer 1",
        username: "developer-1",
        github_id: 1,
        score: 1.0,
        location_id: location.id
      })

    developer2 =
      DevelopersHelper.create_developer(%{
        name: "Developer 2",
        username: "developer-2",
        github_id: 2,
        score: 2.0,
        location_id: location.id
      })

    developer3 =
      DevelopersHelper.create_developer(%{
        name: "Developer 3",
        username: "developer-3",
        github_id: 3,
        score: 3.0,
        location_id: location.id
      })

    RepositoriesHelper.create_repository(%{
      name: "Repository 1",
      slug: "repository-1",
      developer_id: developer3.id,
      language_id: language.id
    })

    RepositoriesHelper.create_repository(%{
      name: "Repository 2",
      slug: "repository-2",
      developer_id: developer3.id,
      language_id: language.id
    })

    RepositoriesHelper.create_repository(%{
      name: "Repository 3",
      slug: "repository-3",
      developer_id: developer2.id,
      language_id: language.id
    })

    {:ok, %{developers: {developer1, developer2, developer3}}}
  end

  test "returns basic data", %{conn: conn, developers: {_, developer2, developer3}} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", @basic_query)

    assert json_response(conn, 200) === %{
             "data" => %{
               "developers" => [
                 %{
                   "id" => to_string(developer3.id),
                   "username" => developer3.username,
                   "github_id" => developer3.github_id,
                   "name" => developer3.name,
                   "avatar_url" => developer3.avatar_url,
                   "bio" => developer3.bio,
                   "company" => developer3.company,
                   "github_location" => developer3.github_location,
                   "github_url" => developer3.github_url,
                   "followers" => developer3.followers,
                   "following" => developer3.following,
                   "public_repos" => developer3.public_repos,
                   "total_starred" => developer3.total_starred,
                   "score" => developer3.score,
                   "github_created_at" => DateTime.to_iso8601(developer3.github_created_at),
                   "stats" => %{
                     "rank" => 1,
                     "locationRank" => 1,
                     "repositoriesCount" => 2
                   }
                 },
                 %{
                   "id" => to_string(developer2.id),
                   "username" => developer2.username,
                   "github_id" => developer2.github_id,
                   "name" => developer2.name,
                   "avatar_url" => developer2.avatar_url,
                   "bio" => developer2.bio,
                   "company" => developer2.company,
                   "github_location" => developer2.github_location,
                   "github_url" => developer2.github_url,
                   "followers" => developer2.followers,
                   "following" => developer2.following,
                   "public_repos" => developer2.public_repos,
                   "total_starred" => developer2.total_starred,
                   "score" => developer2.score,
                   "github_created_at" => DateTime.to_iso8601(developer2.github_created_at),
                   "stats" => %{
                     "rank" => 2,
                     "locationRank" => 2,
                     "repositoriesCount" => 1
                   }
                 }
               ]
             }
           }
  end

  test "returns repositories of developer", %{conn: conn} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", @with_repositories_query)

    assert json_response(conn, 200) === %{
             "data" => %{
               "developers" => [
                 %{
                   "name" => "Developer 3",
                   "repositories" => [
                     %{"name" => "Repository 1"},
                     %{"name" => "Repository 2"}
                   ]
                 },
                 %{
                   "name" => "Developer 2",
                   "repositories" => [
                     %{"name" => "Repository 3"}
                   ]
                 }
               ]
             }
           }
  end

  test "returns language usage of developer", %{conn: conn} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", @with_language_usage_query)

    assert json_response(conn, 200) === %{
             "data" => %{
               "developers" => [
                 %{
                   "name" => "Developer 3",
                   "languageUsage" => [
                     %{"language" => %{"name" => "Language 1"}, "repositoriesCount" => 2}
                   ]
                 },
                 %{
                   "name" => "Developer 2",
                   "languageUsage" => [
                     %{"language" => %{"name" => "Language 1"}, "repositoriesCount" => 1}
                   ]
                 }
               ]
             }
           }
  end
end
