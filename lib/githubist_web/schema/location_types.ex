defmodule GithubistWeb.Schema.LocationTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  alias GithubistWeb.Resolvers.DeveloperResolver
  alias GithubistWeb.Resolvers.LanguageResolver
  alias GithubistWeb.Resolvers.LocationResolver
  alias GithubistWeb.Resolvers.RepositoryResolver

  @desc "Location stats"
  object :location_stats do
    @desc "Position of this location in Github Turkey stats"
    field(:rank, non_null(:integer))

    @desc "Total developers count in this location"
    field(:developers_count, non_null(:integer))

    @desc "Total repositories count in this location"
    field(:repositories_count, non_null(:integer))
  end

  @desc "Location usage"
  object :location_usage do
    @desc "Location"
    field(:location, non_null(:location))

    @desc "Repositories count"
    field(:repositories_count, non_null(:integer))
  end

  @desc "A city from Turkey"
  object :location do
    @desc "Location ID"
    field(:id, non_null(:id))

    @desc "Location name"
    field(:name, non_null(:string))

    @desc "Location slug to use in URLs"
    field(:slug, non_null(:string))

    @desc "Location stats"
    field(:stats, non_null(:location_stats), resolve: &LocationResolver.get_stats/3)

    @desc "Developers in this location"
    field(:developers, list_of(:developer)) do
      @desc "Order type"
      arg(:order_by, non_null(:developer_order))

      @desc "Limit of results"
      arg(:limit, :integer, default_value: 25)

      @desc "Offset for pagination"
      arg(:offset, :integer, default_value: 0)

      resolve(&DeveloperResolver.all/3)
    end

    @desc "Repositories in this location"
    field(:repositories, list_of(:repository)) do
      @desc "Order type"
      arg(:order_by, non_null(:repository_order))

      @desc "Limit of results"
      arg(:limit, :integer, default_value: 25)

      @desc "Offset for pagination"
      arg(:offset, :integer, default_value: 0)

      resolve(&RepositoryResolver.all/3)
    end

    @desc "Language usage of this location"
    field(:language_usage, list_of(:language_usage)) do
      @desc "Limit of results"
      arg(:limit, :integer, default_value: 25)

      @desc "Offset for pagination"
      arg(:offset, :integer, default_value: 0)

      resolve(&LanguageResolver.get_usage/3)
    end
  end
end
