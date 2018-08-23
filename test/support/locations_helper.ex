defmodule Githubist.TestSupport.LocationsHelper do
  @moduledoc """
  Test helper for location related logic
  """

  alias Githubist.Locations
  alias Githubist.Locations.Location

  @location_attrs %{
    name: "İzmir",
    slug: "izmir",
    score: 100.12
  }

  @spec create_location(map()) :: Location.t()
  def create_location(attrs \\ %{}) do
    {:ok, location} = Locations.create_location(Map.merge(@location_attrs, attrs))

    location
  end

  @spec get_location_attrs() :: map()
  def get_location_attrs do
    @location_attrs
  end
end
