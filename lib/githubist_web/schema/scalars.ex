defmodule GithubistWeb.Schema.Scalars do
  @moduledoc false

  use Absinthe.Schema.Notation

  @desc """
  This scalar type represents date and time as ISO 8601 format
  """
  scalar :time do
    parse(&Timex.parse(&1.value, "{ISO:Extended:Z}"))
    serialize(&Timex.format!(&1, "{ISO:Extended:Z}"))
  end
end
