defmodule GithubistWeb.Schema.InputObjects do
  @moduledoc false

  use Absinthe.Schema.Notation

  @desc "The field and direction to order developers"
  input_object :developer_order do
    @desc "The order field"
    field(:field, non_null(:developer_order_field))

    @desc "The order direction"
    field(:direction, non_null(:order_direction))
  end

  @desc "The field and direction to order languages"
  input_object :language_order do
    @desc "The order field"
    field(:field, non_null(:language_order_field))

    @desc "The order direction"
    field(:direction, non_null(:order_direction))
  end

  @desc "The field and direction to order locations"
  input_object :location_order do
    @desc "The order field"
    field(:field, non_null(:location_order_field))

    @desc "The order direction"
    field(:direction, non_null(:order_direction))
  end

  @desc "The field and direction to order repositories"
  input_object :repository_order do
    @desc "The order field"
    field(:field, non_null(:repository_order_field))

    @desc "The order direction"
    field(:direction, non_null(:order_direction))
  end
end
