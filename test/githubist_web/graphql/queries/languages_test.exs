defmodule GithubistWeb.GraphQL.LanguagesTest do
  use GithubistWeb.ConnCase

  import GithubistWeb.TestSupport.GraphQLHelper

  alias Githubist.TestSupport.DevelopersHelper
  alias Githubist.TestSupport.LanguagesHelper
  alias Githubist.TestSupport.LocationsHelper
  alias Githubist.TestSupport.RepositoriesHelper

  @basic_query """
    query {
      languages(limit: 2, offset: 0, orderBy:{direction: DESC, field: SCORE}) {
        id
        name
        slug
        score
        totalStars
        totalRepositories
        stats {
          rank
          repositoriesCountRank
          developersCount
          repositoriesCount
        }
      }
    }
  """

  @with_repositories_query """
    query {
      languages(limit: 2, offset: 0, orderBy:{direction: DESC, field: SCORE}) {
        name
        repositories(limit: 2, offset: 0, orderBy: {direction: ASC, field: NAME}) {
          name
        }
      }
    }
  """

  @with_location_usage_query """
    query {
      languages(limit: 2, offset: 0, orderBy:{direction: DESC, field: SCORE}) {
        name
        locationUsage(limit: 2, offset: 0) {
          location {
            name
          }

          repositoriesCount
        }
      }
    }
  """

  @with_developer_usage_query """
    query {
      languages(limit: 2, offset: 0, orderBy:{direction: DESC, field: SCORE}) {
        name
        developerUsage(limit: 2, offset: 0) {
          developer {
            name
          }

          repositoriesCount
        }
      }
    }
  """

  setup do
    language1 =
      LanguagesHelper.create_language(%{
        name: "Language 1",
        slug: "language-1",
        score: 1.0,
        total_repositories: 0
      })

    language2 =
      LanguagesHelper.create_language(%{
        name: "Language 2",
        slug: "language-2",
        score: 2.0,
        total_repositories: 1
      })

    language3 =
      LanguagesHelper.create_language(%{
        name: "Language 3",
        slug: "language-3",
        score: 3.0,
        total_repositories: 2
      })

    location = LocationsHelper.create_location(%{name: "Location 1"})

    developer =
      DevelopersHelper.create_developer(%{location_id: location.id, name: "Developer 1"})

    RepositoriesHelper.create_repository(%{
      name: "Repository 1",
      slug: "repository-1",
      developer_id: developer.id,
      language_id: language3.id
    })

    RepositoriesHelper.create_repository(%{
      name: "Repository 2",
      slug: "repository-2",
      developer_id: developer.id,
      language_id: language3.id
    })

    {:ok, %{languages: {language1, language2, language3}}}
  end

  test "returns basic data", %{conn: conn, languages: {_, language2, language3}} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", @basic_query)

    assert json_response(conn, 200) === %{
             "data" => %{
               "languages" => [
                 %{
                   "id" => to_string(language3.id),
                   "name" => language3.name,
                   "slug" => language3.slug,
                   "score" => language3.score,
                   "totalStars" => language3.total_stars,
                   "totalRepositories" => language3.total_repositories,
                   "stats" => %{
                     "rank" => 1,
                     "repositoriesCountRank" => 1,
                     "developersCount" => 1,
                     "repositoriesCount" => 2
                   }
                 },
                 %{
                   "id" => to_string(language2.id),
                   "name" => language2.name,
                   "slug" => language2.slug,
                   "score" => language2.score,
                   "totalStars" => language2.total_stars,
                   "totalRepositories" => language2.total_repositories,
                   "stats" => %{
                     "rank" => 2,
                     "repositoriesCountRank" => 2,
                     "developersCount" => 0,
                     "repositoriesCount" => 0
                   }
                 }
               ]
             }
           }
  end

  test "returns repositories of language", %{conn: conn} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", @with_repositories_query)

    assert json_response(conn, 200) === %{
             "data" => %{
               "languages" => [
                 %{
                   "name" => "Language 3",
                   "repositories" => [
                     %{"name" => "Repository 1"},
                     %{"name" => "Repository 2"}
                   ]
                 },
                 %{
                   "name" => "Language 2",
                   "repositories" => []
                 }
               ]
             }
           }
  end

  test "returns location usage of language", %{conn: conn} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", @with_location_usage_query)

    assert json_response(conn, 200) === %{
             "data" => %{
               "languages" => [
                 %{
                   "name" => "Language 3",
                   "locationUsage" => [
                     %{"location" => %{"name" => "Location 1"}, "repositoriesCount" => 2}
                   ]
                 },
                 %{
                   "name" => "Language 2",
                   "locationUsage" => []
                 }
               ]
             }
           }
  end

  test "returns developer usage of language", %{conn: conn} do
    conn =
      conn
      |> put_graphql_headers()
      |> post("/graphql", @with_developer_usage_query)

    assert json_response(conn, 200) === %{
             "data" => %{
               "languages" => [
                 %{
                   "name" => "Language 3",
                   "developerUsage" => [
                     %{"developer" => %{"name" => "Developer 1"}, "repositoriesCount" => 2}
                   ]
                 },
                 %{
                   "name" => "Language 2",
                   "developerUsage" => []
                 }
               ]
             }
           }
  end
end
