defmodule GithubistWeb.Resolvers.LanguageResolver do
  @moduledoc false

  alias Githubist.Developers.Developer
  alias Githubist.GraphQLArgumentParser
  alias Githubist.Languages
  alias Githubist.Languages.Language
  alias Githubist.Locations.Location

  def all(_parent, params, _resolution) do
    params =
      params
      |> GraphQLArgumentParser.parse_limit(max_limit: 100)
      |> GraphQLArgumentParser.parse_order_by()

    languages = Languages.all(params)

    {:ok, languages}
  end

  def get(_parent, %{slug: slug}, _resolution) do
    case Languages.get_language_by_slug(slug) do
      nil -> {:error, "Language with slug #{slug} could not be found."}
      language -> {:ok, language}
    end
  end

  def get_stats(%Language{} = language, _params, _resolution) do
    stats = %{
      rank: Languages.get_rank(language),
      repositories_count_rank: Languages.get_repositories_count_rank(language),
      developers_count_rank: Languages.get_developers_count_rank(language)
    }

    {:ok, stats}
  end

  def get_usage(%Location{} = location, params, _resolution) do
    params =
      params
      |> GraphQLArgumentParser.parse_limit(max_limit: 100)

    usage = Languages.get_location_usage(location, params)

    {:ok, usage}
  end

  def get_usage(%Developer{} = developer, params, _resolution) do
    params =
      params
      |> GraphQLArgumentParser.parse_limit(max_limit: 100)

    usage = Languages.get_developer_usage(developer, params)

    {:ok, usage}
  end

  def get_location_usage(%Language{} = language, params, _resolution) do
    params =
      params
      |> GraphQLArgumentParser.parse_limit(max_limit: 100)

    usage = Languages.get_location_stats(language, params)

    {:ok, usage}
  end

  def get_developer_usage(%Language{} = language, params, _resolution) do
    params =
      params
      |> GraphQLArgumentParser.parse_limit(max_limit: 100)

    usage = Languages.get_developer_stats(language, params)

    {:ok, usage}
  end
end
