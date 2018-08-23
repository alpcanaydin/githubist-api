defmodule Githubist.Repositories.Repository do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset
  alias Githubist.Developers.Developer
  alias Githubist.Languages.Language

  @type t :: %__MODULE__{}

  schema "repositories" do
    field(:name, :string)
    field(:slug, :string)
    field(:github_id, :integer)
    field(:github_url, :string)
    field(:stars, :integer)
    field(:forks, :integer)
    field(:github_created_at, :utc_datetime)

    belongs_to(:developer, Developer)
    belongs_to(:language, Language)

    timestamps()
  end

  @doc false
  @spec changeset(__MODULE__.t(), map()) :: Changeset.t()
  def changeset(repository, attrs) do
    repository
    |> cast(attrs, [
      :name,
      :slug,
      :github_id,
      :github_url,
      :stars,
      :forks,
      :github_created_at,
      :developer_id,
      :language_id
    ])
    |> validate_required([
      :name,
      :slug,
      :github_id,
      :github_url,
      :stars,
      :forks,
      :github_created_at,
      :developer_id,
      :language_id
    ])
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:developer_id)
    |> foreign_key_constraint(:language_id)
  end
end
