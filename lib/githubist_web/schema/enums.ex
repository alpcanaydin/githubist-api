defmodule GithubistWeb.Schema.Enums do
  @moduledoc """
  Enums that used in all across the schema
  """

  use Absinthe.Schema.Notation

  enum :developer_order_field do
    value(:name)
    value(:username)
    value(:score)
    value(:total_starred)
    value(:followers)
    value(:github_created_at)
  end

  enum :language_order_field do
    value(:name)
    value(:score)
    value(:total_stars)
    value(:total_repositories)
    value(:total_developers)
  end

  enum :location_order_field do
    value(:name)
    value(:score)
    value(:total_repositories)
    value(:total_developers)
  end

  enum :repository_order_field do
    value(:name)
    value(:stars)
    value(:forks)
    value(:github_created_at)
  end

  enum :order_direction do
    value(:asc)
    value(:desc)
  end

  enum :search_result_type do
    value(:developer)
    value(:location)
    value(:language)
    value(:repository)
  end
end
