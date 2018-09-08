defmodule GithubistWeb.Schema.LanguageTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  alias GithubistWeb.Resolvers.LanguageResolver
  alias GithubistWeb.Resolvers.RepositoryResolver

  @desc "Language stats"
  object :language_stats do
    @desc "Position of this language in Github Turkey stats"
    field(:rank, non_null(:integer))

    @desc "Position of this language in Github Turkey stats according to repositories count"
    field(:repositories_count_rank, non_null(:integer))
  end

  @desc "Language usage"
  object :language_usage do
    @desc "Language"
    field(:language, non_null(:language))

    @desc "Repositories count"
    field(:repositories_count, non_null(:integer))
  end

  @desc "Language"
  object :language do
    @desc "Language ID"
    field(:id, non_null(:id))

    @desc "Language name"
    field(:name, non_null(:string))

    @desc "Language slug to use in URLs"
    field(:slug, non_null(:string))

    @desc "Github stats score of this language"
    field(:score, non_null(:float))

    @desc "Total stars of the language that populated by repositories"
    field(:total_stars, non_null(:integer))

    @desc "Total repos of the language"
    field(:total_repositories, non_null(:integer))

    @desc "Total developers for the language"
    field(:total_developers, non_null(:integer))

    @desc "Language stats"
    field(:stats, non_null(:language_stats), resolve: &LanguageResolver.get_stats/3)

    @desc "Repositories that use this language"
    field(:repositories, list_of(:repository)) do
      @desc "Order type"
      arg(:order_by, non_null(:repository_order))

      @desc "Limit of results"
      arg(:limit, :integer, default_value: 25)

      @desc "Offset for pagination"
      arg(:offset, :integer, default_value: 0)

      resolve(&RepositoryResolver.all/3)
    end

    @desc "Location usage of this language"
    field(:location_usage, list_of(:location_usage)) do
      @desc "Limit of results"
      arg(:limit, :integer, default_value: 25)

      @desc "Offset for pagination"
      arg(:offset, :integer, default_value: 0)

      resolve(&LanguageResolver.get_location_usage/3)
    end

    @desc "Developer usage of this language"
    field(:developer_usage, list_of(:developer_usage)) do
      @desc "Limit of results"
      arg(:limit, :integer, default_value: 25)

      @desc "Offset for pagination"
      arg(:offset, :integer, default_value: 0)

      resolve(&LanguageResolver.get_developer_usage/3)
    end
  end
end
