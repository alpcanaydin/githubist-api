defmodule Githubist.LanguagesTest do
  use Githubist.DataCase

  alias Ecto.{Changeset, NoResultsError}
  alias Githubist.Languages
  alias Githubist.TestSupport.DevelopersHelper
  alias Githubist.TestSupport.LanguagesHelper
  alias Githubist.TestSupport.LocationsHelper
  alias Githubist.TestSupport.RepositoriesHelper

  @language_attrs %{
    name: "Elixir",
    slug: "elixir",
    score: 100.0,
    total_stars: 100,
    total_repositories: 100,
    total_developers: 100
  }

  def language_fixture(attrs \\ %{}) do
    merged_attrs =
      @language_attrs
      |> Map.merge(attrs)

    {:ok, language} = Languages.create_language(merged_attrs)

    language
  end

  describe "get_language/1" do
    test "returns language by id" do
      language = language_fixture()

      fetched_language = Languages.get_language(language.id)

      assert language.id === fetched_language.id
    end

    test "returns nil if language does not exist" do
      assert nil === Languages.get_language(2)
    end
  end

  describe "get_language!/1" do
    test "returns language by id" do
      language = language_fixture()

      fetched_language = Languages.get_language!(language.id)

      assert language.id === fetched_language.id
    end

    test "raise an exception if language does not exist" do
      assert_raise NoResultsError, fn ->
        Languages.get_language!(2)
      end
    end
  end

  describe "get_language_by_slug/1" do
    test "returns language by slug" do
      language = language_fixture()

      fetched_language = Languages.get_language_by_slug(language.slug)

      assert language.id === fetched_language.id
    end

    test "returns nil if language does not exist" do
      assert nil === Languages.get_language_by_slug("none")
    end
  end

  describe "get_language_by_slug!/1" do
    test "returns language by slug" do
      language = language_fixture()

      fetched_language = Languages.get_language_by_slug!(language.slug)

      assert language.id === fetched_language.id
    end

    test "raise an exception if language does not exist" do
      assert_raise NoResultsError, fn ->
        Languages.get_language_by_slug!("none")
      end
    end
  end

  describe "create_language/1" do
    test "creates a language successfully" do
      language = language_fixture()

      assert language.name === @language_attrs.name
      assert language.slug === @language_attrs.slug
      assert language.score === @language_attrs.score
      assert language.total_stars === @language_attrs.total_stars
      assert language.total_repositories === @language_attrs.total_repositories
      assert language.total_developers === @language_attrs.total_developers
    end

    test "returns error if validation fails" do
      invalid_attrs = @language_attrs |> Map.merge(%{name: nil})

      assert {:error, %Changeset{errors: errors}} = Languages.create_language(invalid_attrs)

      assert {_, [validation: :required]} = errors[:name]
    end

    test "returns error if slug is already in use" do
      language_fixture()

      new_language_attrs =
        @language_attrs
        |> Map.put(:name, "PHP")

      {:error, %Changeset{errors: errors}} = Languages.create_language(new_language_attrs)

      assert errors === [slug: {"has already been taken", []}]
    end
  end

  describe "all/1" do
    setup do
      for i <- 1..3 do
        attrs =
          @language_attrs
          |> Map.update!(:slug, fn slug -> "#{slug}-#{i}" end)
          |> Map.update!(:score, fn _ -> i end)

        Languages.create_language(attrs)
      end
    end

    test "returns languages as given limit" do
      languages = Languages.all(%{limit: 2, offset: 0, order_by: {:desc, :id}})

      assert length(languages) === 2
    end

    test "returns languages as starts from given offset" do
      languages = Languages.all(%{limit: 2, offset: 2, order_by: {:desc, :id}})

      assert length(languages) === 1
    end

    test "returns languages as given order" do
      languages = Languages.all(%{limit: 3, offset: 0, order_by: {:desc, :score}})

      assert Map.get(List.first(languages), :score) === 3.0
      assert Map.get(List.last(languages), :score) === 1.0
    end
  end

  describe "get_languages_count/0" do
    setup do
      for i <- 1..3 do
        attrs =
          @language_attrs
          |> Map.update!(:slug, fn slug -> "#{slug}-#{i}" end)
          |> Map.update!(:score, fn _ -> i end)

        Languages.create_language(attrs)
      end
    end

    test "returns languages count" do
      count = Languages.get_languages_count()

      assert count === 3
    end
  end

  describe "get_rank/2" do
    setup do
      language1 =
        @language_attrs
        |> Map.update!(:slug, fn _ -> "slug1" end)
        |> Map.update!(:score, fn _ -> 1000.0 end)

      language2 =
        @language_attrs
        |> Map.update!(:slug, fn _ -> "slug2" end)
        |> Map.update!(:score, fn _ -> 500.0 end)

      Languages.create_language(language1)
      Languages.create_language(language2)

      :ok
    end

    test "returns rank of language in turkey" do
      language = Languages.get_language_by_slug!("slug2")
      assert Languages.get_rank(language) === 2
    end
  end

  describe "get_repositories/2" do
    test "returns the repositories for the given language" do
      language1 = LanguagesHelper.create_language(%{slug: "language1"})
      language2 = LanguagesHelper.create_language(%{slug: "language2"})

      location = LocationsHelper.create_location()
      developer = DevelopersHelper.create_developer(%{location_id: location.id})

      for i <- 1..3 do
        RepositoriesHelper.create_repository(%{
          developer_id: developer.id,
          language_id: language1.id,
          slug: "slug#{i}"
        })
      end

      for i <- 4..6 do
        RepositoriesHelper.create_repository(%{
          developer_id: developer.id,
          language_id: language2.id,
          slug: "slug#{i}"
        })
      end

      repositories =
        Languages.get_repositories(language1, %{limit: 10, offset: 0, order_by: {:desc, :id}})

      assert length(repositories) === 3
      assert Map.get(List.first(repositories), :slug) === "slug3"
      assert Map.get(List.last(repositories), :slug) === "slug1"
    end
  end

  describe "get_repositories_count/1" do
    test "returns the count of repositories for the given language" do
      language1 = LanguagesHelper.create_language(%{slug: "language1"})
      language2 = LanguagesHelper.create_language(%{slug: "language2"})

      location = LocationsHelper.create_location()
      developer = DevelopersHelper.create_developer(%{location_id: location.id})

      for i <- 1..3 do
        RepositoriesHelper.create_repository(%{
          developer_id: developer.id,
          language_id: language1.id,
          slug: "slug#{i}"
        })
      end

      for i <- 4..6 do
        RepositoriesHelper.create_repository(%{
          developer_id: developer.id,
          language_id: language2.id,
          slug: "slug#{i}"
        })
      end

      repositories_count = Languages.get_repositories_count(language1)

      assert repositories_count === 3
    end
  end

  describe "get_repositories_count_rank/1" do
    test "returns rank of the given language according to repository counts" do
      language1 = LanguagesHelper.create_language(%{slug: "language1"})
      language2 = LanguagesHelper.create_language(%{slug: "language2"})

      location = LocationsHelper.create_location()
      developer = DevelopersHelper.create_developer(%{location_id: location.id})

      for i <- 1..3 do
        RepositoriesHelper.create_repository(%{
          developer_id: developer.id,
          language_id: language1.id,
          slug: "slug#{i}"
        })
      end

      for i <- 4..7 do
        RepositoriesHelper.create_repository(%{
          developer_id: developer.id,
          language_id: language2.id,
          slug: "slug#{i}"
        })
      end

      assert Languages.get_repositories_count_rank(language2) === 1
    end
  end

  describe "get_developers_count_rank/1" do
    test "returns rank of the given language according to repository counts" do
      language1 = LanguagesHelper.create_language(%{slug: "language1"})
      language2 = LanguagesHelper.create_language(%{slug: "language2"})

      location = LocationsHelper.create_location()

      for i <- 1..3 do
        DevelopersHelper.create_developer(%{
          location_id: location.id,
          language_id: language1.id,
          username: "username#{i}",
          github_id: i
        })
      end

      for i <- 4..7 do
        DevelopersHelper.create_developer(%{
          location_id: location.id,
          language_id: language2.id,
          username: "username#{i}",
          github_id: i
        })
      end

      assert Languages.get_developers_count_rank(language2) === 1
    end
  end

  describe "get_developers_count/1" do
    setup do
      language = LanguagesHelper.create_language(%{slug: "language1"})

      location = LocationsHelper.create_location()
      developer = DevelopersHelper.create_developer(%{location_id: location.id})

      developer2 =
        DevelopersHelper.create_developer(%{location_id: location.id, username: "username2"})

      for i <- 1..3 do
        RepositoriesHelper.create_repository(%{
          developer_id: developer.id,
          language_id: language.id,
          slug: "slug#{i}"
        })
      end

      for i <- 4..6 do
        RepositoriesHelper.create_repository(%{
          developer_id: developer2.id,
          language_id: language.id,
          slug: "slug#{i}"
        })
      end

      :ok
    end

    test "returns the count of repositories for the given language" do
      language = Languages.get_language_by_slug!("language1")

      repositories_count = Languages.get_developers_count(language)

      assert repositories_count === 2
    end
  end

  describe "get_location_usage/2" do
    test "returns location usage" do
      language1 = LanguagesHelper.create_language(%{slug: "language1"})
      language2 = LanguagesHelper.create_language(%{slug: "language2"})

      location = LocationsHelper.create_location(%{slug: "location"})
      developer = DevelopersHelper.create_developer(%{location_id: location.id})

      for i <- 1..3 do
        RepositoriesHelper.create_repository(%{
          developer_id: developer.id,
          language_id: language1.id,
          slug: "slug#{i}"
        })
      end

      for i <- 4..7 do
        RepositoriesHelper.create_repository(%{
          developer_id: developer.id,
          language_id: language2.id,
          slug: "slug#{i}"
        })
      end

      params = %{limit: 10, offset: 0}
      usage = Languages.get_location_usage(location, params)

      assert %{language: language2, repositories_count: 4} === Enum.at(usage, 0)
      assert %{language: language1, repositories_count: 3} === Enum.at(usage, 1)
    end
  end

  describe "get_developer_usage/2" do
    test "returns developer usage" do
      language1 = LanguagesHelper.create_language(%{slug: "language1"})
      language2 = LanguagesHelper.create_language(%{slug: "language2"})

      location = LocationsHelper.create_location(%{slug: "location"})
      developer = DevelopersHelper.create_developer(%{location_id: location.id})

      for i <- 1..3 do
        RepositoriesHelper.create_repository(%{
          developer_id: developer.id,
          language_id: language1.id,
          slug: "slug#{i}"
        })
      end

      for i <- 4..7 do
        RepositoriesHelper.create_repository(%{
          developer_id: developer.id,
          language_id: language2.id,
          slug: "slug#{i}"
        })
      end

      params = %{limit: 10, offset: 0}
      usage = Languages.get_developer_usage(developer, params)

      assert %{language: language2, repositories_count: 4} === Enum.at(usage, 0)
      assert %{language: language1, repositories_count: 3} === Enum.at(usage, 1)
    end
  end

  describe "get_location_stats/2" do
    test "returns location stats" do
      language = LanguagesHelper.create_language()

      location1 = LocationsHelper.create_location(%{slug: "location1"})
      location2 = LocationsHelper.create_location(%{slug: "location2"})

      developer1 =
        DevelopersHelper.create_developer(%{location_id: location1.id, username: "developer1"})

      developer2 =
        DevelopersHelper.create_developer(%{location_id: location2.id, username: "developer2"})

      for i <- 1..3 do
        RepositoriesHelper.create_repository(%{
          developer_id: developer1.id,
          language_id: language.id,
          slug: "slug#{i}"
        })
      end

      for i <- 4..7 do
        RepositoriesHelper.create_repository(%{
          developer_id: developer2.id,
          language_id: language.id,
          slug: "slug#{i}"
        })
      end

      params = %{limit: 10, offset: 0}
      usage = Languages.get_location_stats(language, params)

      assert %{location: location2, repositories_count: 4} === Enum.at(usage, 0)
      assert %{location: location1, repositories_count: 3} === Enum.at(usage, 1)
    end
  end

  describe "get_develoepr_stats/2" do
    test "returns developer stats" do
      language = LanguagesHelper.create_language()

      location1 = LocationsHelper.create_location(%{slug: "location1"})
      location2 = LocationsHelper.create_location(%{slug: "location2"})

      developer1 =
        DevelopersHelper.create_developer(%{location_id: location1.id, username: "developer1"})

      developer2 =
        DevelopersHelper.create_developer(%{location_id: location2.id, username: "developer2"})

      for i <- 1..3 do
        RepositoriesHelper.create_repository(%{
          developer_id: developer1.id,
          language_id: language.id,
          slug: "slug#{i}"
        })
      end

      for i <- 4..7 do
        RepositoriesHelper.create_repository(%{
          developer_id: developer2.id,
          language_id: language.id,
          slug: "slug#{i}"
        })
      end

      params = %{limit: 10, offset: 0}
      usage = Languages.get_developer_stats(language, params)

      assert %{developer: developer2, repositories_count: 4} === Enum.at(usage, 0)
      assert %{developer: developer1, repositories_count: 3} === Enum.at(usage, 1)
    end
  end
end
