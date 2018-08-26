defmodule GithubistWeb.Schema.RepositoryTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias GithubistWeb.Resolvers.RepositoryResolver

  @desc "Repository stats"
  object :repository_stats do
    @desc "Position of this repository in Github Turkey stats"
    field(:rank, non_null(:integer))

    @desc "Position of this repository in the developed language"
    field(:language_rank, non_null(:integer))
  end

  @desc "Repository"
  object :repository do
    @desc "Repository ID"
    field(:id, non_null(:id))

    @desc "Repository name"
    field(:name, non_null(:string))

    @desc "Repository slug"
    field(:slug, non_null(:string))

    @desc "Description for the repo"
    field(:description, :string)

    @desc "Github ID of repository"
    field(:github_id, non_null(:integer))

    @desc "Gtihub URL of repository"
    field(:github_url, non_null(:string))

    @desc "Total stars of this repository"
    field(:stars, non_null(:integer))

    @desc "Total forks of this repository"
    field(:forks, non_null(:integer))

    @desc "Repository creation date on Github"
    field(:github_created_at, non_null(:time))

    @desc "Repository stats"
    field(:stats, non_null(:repository_stats), resolve: &RepositoryResolver.get_stats/3)

    @desc "Owner of this repository"
    field(:developer, non_null(:developer), resolve: dataloader(:db))

    @desc "Main language of this repository"
    field(:language, non_null(:language), resolve: dataloader(:db))
  end
end
