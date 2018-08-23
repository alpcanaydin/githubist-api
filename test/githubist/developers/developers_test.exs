defmodule Githubist.DevelopersTest do
  use Githubist.DataCase

  alias Ecto.{Changeset, NoResultsError}
  alias Githubist.Developers
  alias Githubist.TestSupport.DevelopersHelper
  alias Githubist.TestSupport.LanguagesHelper
  alias Githubist.TestSupport.LocationsHelper
  alias Githubist.TestSupport.RepositoriesHelper

  @developer_attrs %{
    username: "alpcanaydin",
    github_id: 123,
    name: "Alpcan Aydin",
    avatar_url: "https://example.com/avatar.jpg",
    bio: "Developer at Atolye15",
    company: "Atolye15",
    github_location: "Izmir, Turkey",
    github_url: "https://github.com/alpcanaydin",
    followers: 100,
    following: 100,
    public_repos: 50,
    total_starred: 500,
    score: 600.0,
    github_created_at: DateTime.utc_now()
  }

  def developer_fixture(attrs \\ %{}) do
    location = LocationsHelper.create_location()

    merged_attrs =
      @developer_attrs
      |> Map.put(:location_id, location.id)
      |> Map.merge(attrs)

    {:ok, developer} = Developers.create_developer(merged_attrs)

    developer
  end

  describe "get_developer/1" do
    test "returns developer by id" do
      developer = developer_fixture()

      fetched_developer = Developers.get_developer(developer.id)

      assert developer.id === fetched_developer.id
    end

    test "returns nil if developer does not exist" do
      assert nil === Developers.get_developer(2)
    end
  end

  describe "get_developer!/1" do
    test "returns developer by id" do
      developer = developer_fixture()

      fetched_developer = Developers.get_developer!(developer.id)

      assert developer.id === fetched_developer.id
    end

    test "raise an exception if developer does not exist" do
      assert_raise NoResultsError, fn ->
        Developers.get_developer!(2)
      end
    end
  end

  describe "get_developer_by_username/1" do
    test "returns developer by username" do
      developer = developer_fixture()

      fetched_developer = Developers.get_developer_by_username(developer.username)

      assert developer.id === fetched_developer.id
    end

    test "returns nil if developer does not exist" do
      assert nil === Developers.get_developer_by_username("none")
    end
  end

  describe "get_developer_by_username!/1" do
    test "returns developer by username" do
      developer = developer_fixture()

      fetched_developer = Developers.get_developer_by_username!(developer.username)

      assert developer.id === fetched_developer.id
    end

    test "raise an exception if developer does not exist" do
      assert_raise NoResultsError, fn ->
        Developers.get_developer_by_username!("none")
      end
    end
  end

  describe "create_developer/1" do
    test "creates a developer successfully" do
      developer = developer_fixture()

      assert developer.username === @developer_attrs.username
      assert developer.github_id === @developer_attrs.github_id
      assert developer.name === @developer_attrs.name
      assert developer.avatar_url === @developer_attrs.avatar_url
      assert developer.bio === @developer_attrs.bio
      assert developer.company === @developer_attrs.company
      assert developer.github_location === @developer_attrs.github_location
      assert developer.github_url === @developer_attrs.github_url
      assert developer.followers === @developer_attrs.followers
      assert developer.following === @developer_attrs.following
      assert developer.public_repos === @developer_attrs.public_repos
      assert developer.total_starred === @developer_attrs.total_starred
      assert developer.score === @developer_attrs.score
      assert developer.github_created_at === @developer_attrs.github_created_at
      assert developer.location_id !== nil
    end

    test "returns error if validation fails" do
      invalid_attrs = @developer_attrs |> Map.merge(%{location_id: nil, followers: nil})

      assert {:error, %Changeset{errors: errors}} = Developers.create_developer(invalid_attrs)

      assert {_, [validation: :required]} = errors[:location_id]
      assert {_, [validation: :required]} = errors[:followers]
    end

    test "returns error if username is already in use" do
      developer_fixture()

      new_developer_attrs =
        @developer_attrs
        |> Map.put(:name, "Alp Can Aydin")
        |> Map.put(:location_id, 1)

      {:error, %Changeset{errors: errors}} = Developers.create_developer(new_developer_attrs)

      assert errors === [username: {"has already been taken", []}]
    end

    test "returns error if location is invalid" do
      invalid_attrs = @developer_attrs |> Map.put(:location_id, 1234)

      assert {:error, %Changeset{errors: errors}} = Developers.create_developer(invalid_attrs)

      assert errors === [location_id: {"does not exist", []}]
    end
  end

  describe "all/1" do
    setup do
      location = LocationsHelper.create_location()

      for i <- 1..3 do
        attrs =
          @developer_attrs
          |> Map.update!(:username, fn username -> "#{username}-#{i}" end)
          |> Map.update!(:score, fn _ -> i end)
          |> Map.put(:location_id, location.id)

        Developers.create_developer(attrs)
      end
    end

    test "returns developers as given limit" do
      developers = Developers.all(%{limit: 2, offset: 0, order_by: {:desc, :id}})

      assert length(developers) === 2
    end

    test "returns developers as starts from given offset" do
      developers = Developers.all(%{limit: 2, offset: 2, order_by: {:desc, :id}})

      assert length(developers) === 1
    end

    test "returns developers as given order" do
      developers = Developers.all(%{limit: 3, offset: 0, order_by: {:desc, :score}})

      assert Map.get(List.first(developers), :score) === 3.0
      assert Map.get(List.last(developers), :score) === 1.0
    end
  end

  describe "get_developers_count/0" do
    setup do
      location = LocationsHelper.create_location()

      for i <- 1..3 do
        attrs =
          @developer_attrs
          |> Map.update!(:username, fn username -> "#{username}-#{i}" end)
          |> Map.update!(:score, fn _ -> i end)
          |> Map.put(:location_id, location.id)

        Developers.create_developer(attrs)
      end
    end

    test "returns developers count" do
      count = Developers.get_developers_count()

      assert count === 3
    end
  end

  describe "get_rank/2" do
    setup do
      location1 = LocationsHelper.create_location()

      location2 =
        LocationsHelper.create_location(%{name: "Ankara", slug: "ankara", score: 1000.0})

      developer1 =
        @developer_attrs
        |> Map.update!(:username, fn _ -> "test1" end)
        |> Map.update!(:score, fn _ -> 1000.0 end)
        |> Map.put(:location_id, location1.id)

      developer2 =
        @developer_attrs
        |> Map.update!(:username, fn _ -> "test2" end)
        |> Map.update!(:score, fn _ -> 500.0 end)
        |> Map.put(:location_id, location2.id)

      Developers.create_developer(developer1)
      Developers.create_developer(developer2)

      :ok
    end

    test "returns rank of developer in turkey" do
      developer = Developers.get_developer_by_username!("test2")
      assert Developers.get_rank(developer, :turkey) === 2
    end

    test "returns rank of developer in his/her location" do
      developer = Developers.get_developer_by_username!("test2")
      assert Developers.get_rank(developer, :in_location) === 1
    end
  end

  describe "get_repositories/2" do
    setup do
      location = LocationsHelper.create_location()

      developer =
        DevelopersHelper.create_developer(%{location_id: location.id, username: "username"})

      language = LanguagesHelper.create_language()

      for i <- 1..3 do
        attrs =
          RepositoriesHelper.get_repository_attrs()
          |> Map.put(:developer_id, developer.id)
          |> Map.put(:language_id, language.id)
          |> Map.update!(:slug, fn slug -> "#{slug}-#{i}" end)
          |> Map.update!(:stars, fn _ -> i end)

        RepositoriesHelper.create_repository(attrs)
      end

      # Add another repo
      developer2 =
        DevelopersHelper.create_developer(%{
          username: "test2",
          github_id: 126,
          location_id: location.id
        })

      attrs =
        RepositoriesHelper.get_repository_attrs()
        |> Map.put(:developer_id, developer2.id)
        |> Map.put(:language_id, language.id)
        |> Map.update!(:slug, fn _ -> "another-slug" end)

      RepositoriesHelper.create_repository(attrs)

      :ok
    end

    test "returns developer's repositories" do
      developer = Developers.get_developer_by_username!("username")

      repositories =
        Developers.get_repositories(developer, %{limit: 4, offset: 0, order_by: {:desc, :id}})

      assert length(repositories) === 3

      assert Map.get(List.first(repositories), :developer_id) === developer.id
      assert Map.get(List.last(repositories), :developer_id) === developer.id
    end
  end

  describe "get_repositories_count/1" do
    setup do
      location = LocationsHelper.create_location()

      developer =
        DevelopersHelper.create_developer(%{location_id: location.id, username: "username"})

      language = LanguagesHelper.create_language()

      for i <- 1..3 do
        attrs =
          RepositoriesHelper.get_repository_attrs()
          |> Map.put(:developer_id, developer.id)
          |> Map.put(:language_id, language.id)
          |> Map.update!(:slug, fn slug -> "#{slug}-#{i}" end)
          |> Map.update!(:stars, fn _ -> i end)

        RepositoriesHelper.create_repository(attrs)
      end

      # Add another repo
      developer2 =
        DevelopersHelper.create_developer(%{
          username: "test2",
          github_id: 1236,
          location_id: location.id
        })

      attrs =
        RepositoriesHelper.get_repository_attrs()
        |> Map.put(:developer_id, developer2.id)
        |> Map.put(:language_id, language.id)
        |> Map.update!(:slug, fn _ -> "another-slug" end)

      RepositoriesHelper.create_repository(attrs)

      :ok
    end

    test "returns repositories count of developer" do
      developer = Developers.get_developer_by_username!("username")

      assert Developers.get_repositories_count(developer) === 3
    end
  end
end
