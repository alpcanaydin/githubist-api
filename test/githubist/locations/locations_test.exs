defmodule Githubist.LocationsTest do
  use Githubist.DataCase

  alias Ecto.{Changeset, NoResultsError}
  alias Githubist.Locations
  alias Githubist.TestSupport.DevelopersHelper
  alias Githubist.TestSupport.LanguagesHelper
  alias Githubist.TestSupport.LocationsHelper
  alias Githubist.TestSupport.RepositoriesHelper

  @location_attrs %{
    name: "Izmir",
    slug: "izmir",
    score: 100.0
  }

  def location_fixture(attrs \\ %{}) do
    merged_attrs =
      @location_attrs
      |> Map.merge(attrs)

    {:ok, location} = Locations.create_location(merged_attrs)

    location
  end

  describe "get_location/1" do
    test "returns location by id" do
      location = location_fixture()

      fetched_location = Locations.get_location(location.id)

      assert location.id === fetched_location.id
    end

    test "returns nil if location does not exist" do
      assert nil === Locations.get_location(2)
    end
  end

  describe "get_location!/1" do
    test "returns location by id" do
      location = location_fixture()

      fetched_location = Locations.get_location!(location.id)

      assert location.id === fetched_location.id
    end

    test "raise an exception if location does not exist" do
      assert_raise NoResultsError, fn ->
        Locations.get_location!(2)
      end
    end
  end

  describe "get_location_by_slug/1" do
    test "returns location by slug" do
      location = location_fixture()

      fetched_location = Locations.get_location_by_slug(location.slug)

      assert location.id === fetched_location.id
    end

    test "returns nil if location does not exist" do
      assert nil === Locations.get_location_by_slug("none")
    end
  end

  describe "get_location_by_slug!/1" do
    test "returns location by slug" do
      location = location_fixture()

      fetched_location = Locations.get_location_by_slug!(location.slug)

      assert location.id === fetched_location.id
    end

    test "raise an exception if location does not exist" do
      assert_raise NoResultsError, fn ->
        Locations.get_location_by_slug!("none")
      end
    end
  end

  describe "create_location/1" do
    test "creates a location successfully" do
      location = location_fixture()

      assert location.name === @location_attrs.name
      assert location.slug === @location_attrs.slug
      assert location.score === @location_attrs.score
    end

    test "returns error if validation fails" do
      invalid_attrs = @location_attrs |> Map.merge(%{name: nil})

      assert {:error, %Changeset{errors: errors}} = Locations.create_location(invalid_attrs)

      assert {_, [validation: :required]} = errors[:name]
    end

    test "returns error if slug is already in use" do
      location_fixture()

      new_location_attrs =
        @location_attrs
        |> Map.put(:name, "PHP")

      {:error, %Changeset{errors: errors}} = Locations.create_location(new_location_attrs)

      assert errors === [slug: {"has already been taken", []}]
    end
  end

  describe "all/1" do
    setup do
      for i <- 1..3 do
        attrs =
          @location_attrs
          |> Map.update!(:slug, fn slug -> "#{slug}-#{i}" end)
          |> Map.update!(:score, fn _ -> i end)

        Locations.create_location(attrs)
      end
    end

    test "returns locations as given limit" do
      locations = Locations.all(%{limit: 2, offset: 0, order_by: {:desc, :id}})

      assert length(locations) === 2
    end

    test "returns locations as starts from given offset" do
      locations = Locations.all(%{limit: 2, offset: 2, order_by: {:desc, :id}})

      assert length(locations) === 1
    end

    test "returns locations as given order" do
      locations = Locations.all(%{limit: 3, offset: 0, order_by: {:desc, :score}})

      assert Map.get(List.first(locations), :score) === 3.0
      assert Map.get(List.last(locations), :score) === 1.0
    end
  end

  describe "get_locations_count/0" do
    setup do
      for i <- 1..3 do
        attrs =
          @location_attrs
          |> Map.update!(:slug, fn slug -> "#{slug}-#{i}" end)
          |> Map.update!(:score, fn _ -> i end)

        Locations.create_location(attrs)
      end
    end

    test "returns locations count" do
      count = Locations.get_locations_count()

      assert count === 3
    end
  end

  describe "get_rank/2" do
    setup do
      location1 =
        @location_attrs
        |> Map.update!(:slug, fn _ -> "slug1" end)
        |> Map.update!(:score, fn _ -> 1000.0 end)

      location2 =
        @location_attrs
        |> Map.update!(:slug, fn _ -> "slug2" end)
        |> Map.update!(:score, fn _ -> 500.0 end)

      Locations.create_location(location1)
      Locations.create_location(location2)

      :ok
    end

    test "returns rank of location" do
      location = Locations.get_location_by_slug!("slug2")
      assert Locations.get_rank(location) === 2
    end
  end

  describe "get_developers/2" do
    setup do
      location = LocationsHelper.create_location(%{slug: "location"})
      location2 = LocationsHelper.create_location(%{slug: "location2"})

      for i <- 1..3 do
        DevelopersHelper.create_developer(%{location_id: location.id, username: "username#{i}"})
      end

      for i <- 4..6 do
        DevelopersHelper.create_developer(%{
          location_id: location2.id,
          username: "username#{i}"
        })
      end

      :ok
    end

    test "returns the developers in the given location" do
      location = Locations.get_location_by_slug!("location")

      developers =
        Locations.get_developers(location, %{limit: 10, offset: 0, order_by: {:desc, :id}})

      assert length(developers) === 3
      assert Map.get(List.first(developers), :username) === "username3"
      assert Map.get(List.last(developers), :username) === "username1"
    end
  end

  describe "get_repositories/2" do
    setup do
      location = LocationsHelper.create_location(%{slug: "location"})
      location2 = LocationsHelper.create_location(%{slug: "location2"})

      developer =
        DevelopersHelper.create_developer(%{location_id: location.id, username: "username1"})

      developer2 =
        DevelopersHelper.create_developer(%{location_id: location2.id, username: "username2"})

      language = LanguagesHelper.create_language()

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

    test "returns the repositories in the given location" do
      location = Locations.get_location_by_slug!("location")

      repositories =
        Locations.get_repositories(location, %{limit: 10, offset: 0, order_by: {:desc, :id}})

      assert length(repositories) === 3
      assert Map.get(List.first(repositories), :slug) === "slug3"
      assert Map.get(List.last(repositories), :slug) === "slug1"
    end
  end

  describe "get_developers_count/1" do
    setup do
      location = LocationsHelper.create_location(%{slug: "location"})
      location2 = LocationsHelper.create_location(%{slug: "location2"})

      for i <- 1..3 do
        DevelopersHelper.create_developer(%{location_id: location.id, username: "username#{i}"})
      end

      for i <- 4..6 do
        DevelopersHelper.create_developer(%{
          location_id: location2.id,
          username: "username#{i}"
        })
      end

      :ok
    end

    test "returns the count of developers in the given location" do
      location = Locations.get_location_by_slug!("location")

      developers_count = Locations.get_developers_count(location)

      assert developers_count === 3
    end
  end

  describe "get_repositories_count/1" do
    setup do
      location = LocationsHelper.create_location(%{slug: "location"})
      location2 = LocationsHelper.create_location(%{slug: "location2"})

      developer =
        DevelopersHelper.create_developer(%{location_id: location.id, username: "username1"})

      developer2 =
        DevelopersHelper.create_developer(%{location_id: location2.id, username: "username2"})

      language = LanguagesHelper.create_language()

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

    test "returns the count of repositories in the given location" do
      location = Locations.get_location_by_slug!("location")

      repositories_count = Locations.get_repositories_count(location)

      assert repositories_count === 3
    end
  end
end
