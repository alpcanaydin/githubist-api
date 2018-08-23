defmodule Githubist.GraphQLArgumentParser do
  @moduledoc """
  Some helpers to parse limit and order by
  """

  @spec parse_limit(map()) :: map()
  def parse_limit(params, opts \\ []) do
    Map.update!(params, :limit, fn limit ->
      update_limit(limit, Keyword.get(opts, :max_limit, 100))
    end)
  end

  @spec parse_order_by(map()) :: map()
  def parse_order_by(%{order_by: _} = params) do
    Map.update!(params, :order_by, fn order_by ->
      {order_by.direction, order_by.field}
    end)
  end

  def parse_order_by(params) do
    params
  end

  defp update_limit(limit, max_limit) when is_integer(max_limit) do
    max(min(limit, max_limit), 0)
  end

  defp update_limit(limit, nil) do
    limit
  end
end
