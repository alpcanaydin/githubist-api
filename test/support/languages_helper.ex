defmodule Githubist.TestSupport.LanguagesHelper do
  @moduledoc """
  Test helper for language related logic
  """

  alias Githubist.Languages
  alias Githubist.Languages.Language

  @language_attrs %{
    name: "Elixir",
    slug: "elixir",
    score: 100.0,
    total_stars: 100,
    total_repositories: 100,
    total_developers: 100
  }

  @spec create_language(map()) :: Language.t()
  def create_language(attrs \\ %{}) do
    {:ok, language} = Languages.create_language(Map.merge(@language_attrs, attrs))

    language
  end

  @spec get_language_attrs() :: map()
  def get_language_attrs do
    @language_attrs
  end
end
