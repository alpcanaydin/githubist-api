defmodule GithubistWeb.Schema.TurkeyTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  object :turkey do
    @desc "Count of total developers"
    field(:total_developers, non_null(:integer))

    @desc "Count of total languages"
    field(:total_languages, non_null(:integer))

    @desc "Count of total locations"
    field(:total_locations, non_null(:integer))

    @desc "Count of total repositories"
    field(:total_repositories, non_null(:integer))
  end
end
