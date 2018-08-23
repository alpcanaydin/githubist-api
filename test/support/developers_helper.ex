defmodule Githubist.TestSupport.DevelopersHelper do
  @moduledoc """
  Test helper for developers related logic
  """

  alias Githubist.Developers
  alias Githubist.Developers.Developer

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

  @spec create_developer(map()) :: Developer.t()
  def create_developer(attrs \\ %{}) do
    merged_attrs =
      @developer_attrs
      |> Map.merge(attrs)

    {:ok, developer} = Developers.create_developer(merged_attrs)

    developer
  end

  @spec get_developer_attrs() :: map()
  def get_developer_attrs do
    @developer_attrs
  end
end
