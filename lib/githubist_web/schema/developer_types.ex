defmodule GithubistWeb.Schema.DeveloperTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias GithubistWeb.Resolvers.DeveloperResolver
  alias GithubistWeb.Resolvers.LanguageResolver
  alias GithubistWeb.Resolvers.RepositoryResolver

  @desc "Developer stats"
  object :developer_stats do
    @desc "Position of this developer in Github Turkey stats"
    field(:rank, non_null(:integer))

    @desc "Position of this developer at her/his location"
    field(:location_rank, non_null(:integer))

    @desc "Total repositories count of this developer"
    field(:repositories_count, non_null(:integer))
  end

  @desc "Developer usage"
  object :developer_usage do
    @desc "Developer"
    field(:developer, non_null(:developer))

    @desc "Repositories count"
    field(:repositories_count, non_null(:integer))
  end

  @desc "Developer"
  object :developer do
    @desc "Developer ID"
    field(:id, non_null(:id))

    @desc "Github username of developer"
    field(:username, non_null(:string))

    @desc "Github ID of developer"
    field(:github_id, non_null(:integer))

    @desc "Full name of developer"
    field(:name, :string)

    @desc "Avatar url of developer"
    field(:avatar_url, non_null(:string))

    @desc "Bio of developer"
    field(:bio, :string)

    @desc "Company of developer"
    field(:company, :string)

    @desc "Github location of developer. This field is the raw value of developer's location"
    field(:github_location, non_null(:string))

    @desc "Github URL of developer"
    field(:github_url, non_null(:string))

    @desc "Followers count of developer"
    field(:followers, non_null(:integer))

    @desc "Count of the people who followed by this developer"
    field(:following, non_null(:integer))

    @desc "Repository count of this developer. This count just includes only public repositories"
    field(:public_repos, non_null(:integer))

    @desc "Stars count for user's all repositories"
    field(:total_starred, non_null(:integer))

    @desc "Github stats score of this developer"
    field(:score, non_null(:float))

    @desc "Developer's Github registration date"
    field(:github_created_at, non_null(:time))

    @desc "Developer stats"
    field(:stats, non_null(:developer_stats), resolve: &DeveloperResolver.get_stats/3)

    @desc "Github stats location of this developer"
    field(:location, non_null(:location), resolve: dataloader(:db))

    @desc "Repositories of developer"
    field(:repositories, list_of(:repository)) do
      @desc "Order type"
      arg(:order_by, non_null(:repository_order))

      @desc "Limit of results"
      arg(:limit, :integer, default_value: 25)

      @desc "Offset for pagination"
      arg(:offset, :integer, default_value: 0)

      resolve(&RepositoryResolver.all/3)
    end

    @desc "Language usage of this developer"
    field(:language_usage, list_of(:language_usage)) do
      @desc "Limit of results"
      arg(:limit, :integer, default_value: 25)

      @desc "Offset for pagination"
      arg(:offset, :integer, default_value: 0)

      resolve(&LanguageResolver.get_usage/3)
    end
  end
end
