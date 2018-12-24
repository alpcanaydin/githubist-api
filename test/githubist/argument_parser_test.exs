defmodule Githubist.GraphQLArgumentParserTests do
  @moduledoc false

  use Githubist.DataCase

  alias Githubist.GraphQLArgumentParser

  describe "parse_limit/2" do
    test "updates limit if it bigger then max" do
      params = %{limit: 200}

      assert %{limit: 100} = GraphQLArgumentParser.parse_limit(params, max_limit: 100)
    end

    test "doesn't do anything if limit is lower than max" do
      params = %{limit: 20}

      assert %{limit: 20} = GraphQLArgumentParser.parse_limit(params, max_limit: 100)
    end
  end

  describe "parse_order_by/1" do
    test "converts map to tuple" do
      params = %{order_by: %{direction: :desc, field: :id}}

      assert %{order_by: {:desc, :id}} = GraphQLArgumentParser.parse_order_by(params)
    end

    test "doesn't do anything if order_by does not exist" do
      params = %{limit: 10}

      assert %{limit: 10} = GraphQLArgumentParser.parse_order_by(params)
    end
  end
end
