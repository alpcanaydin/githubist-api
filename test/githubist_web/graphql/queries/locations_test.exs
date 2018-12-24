defmodule GithubistWeb.GraphQL.LocationsTest do
  use GithubistWeb.ConnCase

  import GithubistWeb.TestSupport.GraphQLHelper

  alias Githubist.TestSupport.DevelopersHelper
  alias Githubist.TestSupport.LanguagesHelper
  alias Githubist.TestSupport.LocationsHelper
  alias Githubist.TestSupport.RepositoriesHelper

  @basic_query """
    query {
      locations(limit: 2, offset: 0, orderBy:{direction: DESC, field: SCORE}) {
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
    query {
      locations(limit: 2, offset: 0, orderBy:{direction: DESC, field: SCORE}) {
        id
        developers(limit: 1, offset: 0, orderBy:{direction: DESC, field: NAME}) {
          username
        }
      }
    }
  """

  @with_repositories_query """
    query {
      locations(limit: 2, offset: 0, orderBy:{direction: DESC, field: SCORE}) {
        id
        repositories(limit: 1, offset: 0, orderBy:{direction: DESC, field: NAME}) {
          slug
        }
      }
    }
  """

  @with_language_usage_query """
    query {
      locations(limit: 2, offset: 0, orderBy:{direction: DESC, field: SCORE}) {
        id
        languageUsage(limit: 1, offset: 0) {
          language {
            slug
          }
          repositoriesCount
        }
      }
    }
  """

  setup do
    location1 =
      LocationsHelper.create_location(%{
        name: "Location 1",
        slug: "location-1",
        score: 1.0,
        totalRepositories: 1,
        totalDevelopers: 1
      })

    location2 =
      LocationsHelper.create_location(%{
        name: "Location 2",
        slug: "location-2",
        score: 2.0,
        totalRepositories: 2,
        totalDevelopers: 1
      })

    location3 =
      LocationsHelper.create_location(%{
        name: "Location 3",
        slug: "location-3",
        score: 3.0,
        totalRepositories: 3,
        totalDevelopers: 1
      })

    language = LanguagesHelper.create_language(%{slug: "language-slug"})

    developer1 =
      DevelopersHelper.create_developer(%{
        location_id: location2.id,
        username: "username1"
      })

    developer2 =
      DevelopersHelper.create_developer(%{
        location_id: location3.id,
        username: "username2"
      })

    RepositoriesHelper.create_repository(%{
      language_id: language.id,
      developer_id: developer1.id,
      slug: "slug1"
    })

    RepositoriesHelper.create_repository(%{
      language_id: language.id,
      developer_id: developer2.id,
      slug: "slug2"
    })

    {:ok, %{locations: {location1, location2, location3}, language: language}}
  end

  test "returns basic data", %{conn: conn, locations: {_, location2, location3}} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", @basic_query)

    assert json_response(conn, 200) === %{
             "data" => %{
               "locations" => [
                 %{
                   "id" => to_string(location3.id),
                   "name" => location3.name,
                   "slug" => location3.slug,
                   "score" => location3.score,
                   "totalRepositories" => location3.total_repositories,
                   "totalDevelopers" => location3.total_developers,
                   "stats" => %{
                     "rank" => 1
                   }
                 },
                 %{
                   "id" => to_string(location2.id),
                   "name" => location2.name,
                   "slug" => location2.slug,
                   "score" => location2.score,
                   "totalRepositories" => location2.total_repositories,
                   "totalDevelopers" => location2.total_developers,
                   "stats" => %{
                     "rank" => 2
                   }
                 }
               ]
             }
           }
  end

  test "returns developers in this location", %{conn: conn, locations: {_, location2, location3}} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", @with_developers_query)

    assert json_response(conn, 200) === %{
             "data" => %{
               "locations" => [
                 %{
                   "id" => to_string(location3.id),
                   "developers" => [
                     %{"username" => "username2"}
                   ]
                 },
                 %{
                   "id" => to_string(location2.id),
                   "developers" => [
                     %{"username" => "username1"}
                   ]
                 }
               ]
             }
           }
  end

  test "returns repositories in this location", %{
    conn: conn,
    locations: {_, location2, location3}
  } do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", @with_repositories_query)

    assert json_response(conn, 200) === %{
             "data" => %{
               "locations" => [
                 %{
                   "id" => to_string(location3.id),
                   "repositories" => [
                     %{"slug" => "slug2"}
                   ]
                 },
                 %{
                   "id" => to_string(location2.id),
                   "repositories" => [
                     %{"slug" => "slug1"}
                   ]
                 }
               ]
             }
           }
  end

  test "returns language usage in this location", %{
    conn: conn,
    locations: {_, location2, location3},
    language: language
  } do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", @with_language_usage_query)

    assert json_response(conn, 200) === %{
             "data" => %{
               "locations" => [
                 %{
                   "id" => to_string(location3.id),
                   "languageUsage" => [
                     %{"language" => %{"slug" => language.slug}, "repositoriesCount" => 1}
                   ]
                 },
                 %{
                   "id" => to_string(location2.id),
                   "languageUsage" => [
                     %{"language" => %{"slug" => language.slug}, "repositoriesCount" => 1}
                   ]
                 }
               ]
             }
           }
  end
end
