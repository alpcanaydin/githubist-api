defmodule GithubistWeb.Schema.SearchTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  object :search_item do
    @desc "Human readable version of search result"
    field(:name, non_null(:string))

    @desc "Slug of search result"
    field(:slug, non_null(:string))

    @desc "Type of search result"
    field(:type, non_null(:search_result_type))
  end
end
