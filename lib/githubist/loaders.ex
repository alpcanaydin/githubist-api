defmodule Githubist.Loaders do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Dataloader.Ecto, as: DataloaderEcto

  def data do
    DataloaderEcto.new(Githubist.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
