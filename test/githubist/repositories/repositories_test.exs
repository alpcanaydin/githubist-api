defmodule Githubist.RepositoriesTest do
  use Githubist.DataCase

  alias Ecto.{Changeset, NoResultsError}
  alias Githubist.Repositories
  alias Githubist.TestSupport.DevelopersHelper
  alias Githubist.TestSupport.LanguagesHelper
  alias Githubist.TestSupport.LocationsHelper

  @repository_attrs %{
    name: "repo",
    slug: "username/repo",
    github_id: 123,
    github_url: "https://github.com/username/repo",
    stars: 100,
    forks: 100,
    github_created_at: DateTime.utc_now()
  }

  def repository_fixture(attrs \\ %{}) do
    location = LocationsHelper.create_location()
    developer = DevelopersHelper.create_developer(%{location_id: location.id})
    language = LanguagesHelper.create_language()

    merged_attrs =
      @repository_attrs
      |> Map.put(:developer_id, developer.id)
      |> Map.put(:language_id, language.id)
      |> Map.merge(attrs)

    {:ok, repository} = Repositories.create_repository(merged_attrs)

    repository
  end

  describe "get_repository/1" do
    test "returns repository by id" do
      repository = repository_fixture()

      fetched_repository = Repositories.get_repository(repository.id)

      assert repository.id === fetched_repository.id
    end

    test "returns nil if repository does not exist" do
      assert nil === Repositories.get_repository(2)
    end
  end

  describe "get_repository!/1" do
    test "returns repository by id" do
      repository = repository_fixture()

      fetched_repository = Repositories.get_repository!(repository.id)

      assert repository.id === fetched_repository.id
    end

    test "raise an exception if repository does not exist" do
      assert_raise NoResultsError, fn ->
        Repositories.get_repository!(2)
      end
    end
  end

  describe "get_repository_by_slug/1" do
    test "returns repository by slug" do
      repository = repository_fixture()

      fetched_repository = Repositories.get_repository_by_slug(repository.slug)

      assert repository.id === fetched_repository.id
    end

    test "returns nil if repository does not exist" do
      assert nil === Repositories.get_repository_by_slug("none")
    end
  end

  describe "get_repository_by_slug!/1" do
    test "returns repository by slug" do
      repository = repository_fixture()

      fetched_repository = Repositories.get_repository_by_slug!(repository.slug)

      assert repository.id === fetched_repository.id
    end

    test "raise an exception if repository does not exist" do
      assert_raise NoResultsError, fn ->
        Repositories.get_repository_by_slug!("none")
      end
    end
  end

  describe "create_repository/1" do
    test "creates a repository successfully" do
      repository = repository_fixture()

      assert repository.name === @repository_attrs.name
      assert repository.slug === @repository_attrs.slug
      assert repository.github_id === @repository_attrs.github_id
      assert repository.github_url === @repository_attrs.github_url
      assert repository.stars === @repository_attrs.stars
      assert repository.forks === @repository_attrs.forks
      assert repository.github_created_at === @repository_attrs.github_created_at
    end

    test "returns error if validation fails" do
      location = LocationsHelper.create_location()
      developer = DevelopersHelper.create_developer(%{location_id: location.id})
      language = LanguagesHelper.create_language()

      invalid_attrs =
        @repository_attrs
        |> Map.merge(%{name: nil, developer_id: developer.id, language_id: language.id})

      assert {:error, %Changeset{errors: errors}} = Repositories.create_repository(invalid_attrs)

      assert {_, [validation: :required]} = errors[:name]
    end

    test "returns error if slug is already in use" do
      repository_fixture()

      new_repository_attrs =
        @repository_attrs
        |> Map.put(:name, "Test 2")
        |> Map.put(:developer_id, 1)
        |> Map.put(:language_id, 1)

      {:error, %Changeset{errors: errors}} = Repositories.create_repository(new_repository_attrs)

      assert errors === [slug: {"has already been taken", []}]
    end

    test "returns error if developer is invalid" do
      language = LanguagesHelper.create_language()

      invalid_attrs =
        @repository_attrs |> Map.put(:developer_id, 1234) |> Map.put(:language_id, language.id)

      assert {:error, %Changeset{errors: errors}} = Repositories.create_repository(invalid_attrs)

      assert errors === [developer_id: {"does not exist", []}]
    end

    test "returns error if language is invalid" do
      location = LocationsHelper.create_location()
      developer = DevelopersHelper.create_developer(%{location_id: location.id})

      invalid_attrs =
        @repository_attrs |> Map.put(:language_id, 1234) |> Map.put(:developer_id, developer.id)

      assert {:error, %Changeset{errors: errors}} = Repositories.create_repository(invalid_attrs)

      assert errors === [language_id: {"does not exist", []}]
    end
  end

  describe "all/1" do
    setup do
      location = LocationsHelper.create_location()
      developer = DevelopersHelper.create_developer(%{location_id: location.id})
      language = LanguagesHelper.create_language()

      for i <- 1..3 do
        attrs =
          @repository_attrs
          |> Map.put(:developer_id, developer.id)
          |> Map.put(:language_id, language.id)
          |> Map.update!(:slug, fn slug -> "#{slug}-#{i}" end)
          |> Map.update!(:stars, fn _ -> i end)

        Repositories.create_repository(attrs)
      end
    end

    test "returns repositories as given limit" do
      repositories = Repositories.all(%{limit: 2, offset: 0, order_by: {:desc, :id}})

      assert length(repositories) === 2
    end

    test "returns repositories as starts from given offset" do
      repositories = Repositories.all(%{limit: 2, offset: 2, order_by: {:desc, :id}})

      assert length(repositories) === 1
    end

    test "returns repositories as given order" do
      repositories = Repositories.all(%{limit: 3, offset: 0, order_by: {:desc, :stars}})

      assert Map.get(List.first(repositories), :stars) === 3
      assert Map.get(List.last(repositories), :stars) === 1
    end
  end

  describe "get_repositories_count/0" do
    setup do
      location = LocationsHelper.create_location()
      developer = DevelopersHelper.create_developer(%{location_id: location.id})
      language = LanguagesHelper.create_language()

      for i <- 1..3 do
        attrs =
          @repository_attrs
          |> Map.put(:developer_id, developer.id)
          |> Map.put(:language_id, language.id)
          |> Map.update!(:slug, fn slug -> "#{slug}-#{i}" end)

        Repositories.create_repository(attrs)
      end
    end

    test "returns repositories count" do
      count = Repositories.get_repositories_count()

      assert count === 3
    end
  end

  describe "get_rank/2" do
    setup do
      location = LocationsHelper.create_location()
      developer = DevelopersHelper.create_developer(%{location_id: location.id})
      language = LanguagesHelper.create_language()
      language2 = LanguagesHelper.create_language(%{name: "Haskell", slug: "haskell"})

      repository1 =
        @repository_attrs
        |> Map.put(:developer_id, developer.id)
        |> Map.put(:language_id, language.id)
        |> Map.update!(:slug, fn _ -> "slug1" end)
        |> Map.update!(:stars, fn _ -> 1000 end)

      repository2 =
        @repository_attrs
        |> Map.put(:developer_id, developer.id)
        |> Map.put(:language_id, language2.id)
        |> Map.update!(:slug, fn _ -> "slug2" end)
        |> Map.update!(:stars, fn _ -> 500 end)

      Repositories.create_repository(repository1)
      Repositories.create_repository(repository2)

      :ok
    end

    test "returns rank of repository in turkey" do
      repository = Repositories.get_repository_by_slug!("slug2")
      assert Repositories.get_rank(repository, :turkey) === 2
    end

    test "returns rank of repository for a language" do
      repository = Repositories.get_repository_by_slug!("slug2")
      assert Repositories.get_rank(repository, :in_language) === 1
    end
  end
end
