defmodule GithubistWeb.Schema do
  @moduledoc """
  Github Stats GraphQL Schema
  """

  use Absinthe.Schema

  alias Absinthe.Middleware.Dataloader, as: DataloaderMiddleware
  alias Absinthe.Plugin

  alias Githubist.Loaders
  alias GithubistWeb.Resolvers.DeveloperResolver
  alias GithubistWeb.Resolvers.LanguageResolver
  alias GithubistWeb.Resolvers.LocationResolver
  alias GithubistWeb.Resolvers.RepositoryResolver
  alias GithubistWeb.Resolvers.SearchResolver
  alias GithubistWeb.Resolvers.TurkeyResolver

  import_types(GithubistWeb.Schema.Scalars)
  import_types(GithubistWeb.Schema.Enums)
  import_types(GithubistWeb.Schema.InputObjects)
  import_types(GithubistWeb.Schema.DeveloperTypes)
  import_types(GithubistWeb.Schema.RepositoryTypes)
  import_types(GithubistWeb.Schema.LanguageTypes)
  import_types(GithubistWeb.Schema.LocationTypes)
  import_types(GithubistWeb.Schema.SearchTypes)
  import_types(GithubistWeb.Schema.TurkeyTypes)

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(:db, Loaders.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [DataloaderMiddleware] ++ Plugin.defaults()
  end

  query do
    @desc "Get the all Turkey stats"
    field :turkey, :turkey do
      resolve(&TurkeyResolver.get/3)
    end

    field :search, list_of(:search_item) do
      @desc "Term to search"
      arg(:query, non_null(:string))

      resolve(&SearchResolver.search/3)
    end

    @desc "Get all locations"
    field :locations, list_of(:location) do
      @desc "Order type"
      arg(:order_by, non_null(:location_order))

      @desc "Limit of results"
      arg(:limit, :integer, default_value: 81)

      @desc "Offset for pagination"
      arg(:offset, :integer, default_value: 0)

      resolve(&LocationResolver.all/3)
    end

    @desc "Get a specific location by slug"
    field :location, :location do
      @desc "Slug of location"
      arg(:slug, non_null(:string))

      resolve(&LocationResolver.get/3)
    end

    @desc "Get all languages"
    field :languages, list_of(:language) do
      @desc "Order type"
      arg(:order_by, non_null(:language_order))

      @desc "Limit of results"
      arg(:limit, :integer, default_value: 25)

      @desc "Offset for pagination"
      arg(:offset, :integer, default_value: 0)

      resolve(&LanguageResolver.all/3)
    end

    @desc "Get a specific language by slug"
    field :language, :language do
      @desc "Slug of language"
      arg(:slug, non_null(:string))

      resolve(&LanguageResolver.get/3)
    end

    @desc "Get all developers"
    field :developers, list_of(:developer) do
      @desc "Order type"
      arg(:order_by, non_null(:developer_order))

      @desc "Limit of results"
      arg(:limit, :integer, default_value: 25)

      @desc "Offset for pagination"
      arg(:offset, :integer, default_value: 0)

      resolve(&DeveloperResolver.all/3)
    end

    @desc "Get a specific developer by their username"
    field :developer, :developer do
      @desc "Github username of developer"
      arg(:username, non_null(:string))

      resolve(&DeveloperResolver.get/3)
    end

    @desc "Get all repositories"
    field :repositories, list_of(:repository) do
      @desc "Order type"
      arg(:order_by, non_null(:repository_order))

      @desc "Limit of results"
      arg(:limit, :integer, default_value: 25)

      @desc "Offset for pagination"
      arg(:offset, :integer, default_value: 0)

      resolve(&RepositoryResolver.all/3)
    end

    @desc "Get a specific repository by slug"
    field :repository, :repository do
      @desc "Github path of repository. Ex: alpcanaydin/turkiye"
      arg(:slug, non_null(:string))

      resolve(&RepositoryResolver.get/3)
    end
  end
end
