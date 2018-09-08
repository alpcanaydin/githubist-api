defmodule Githubist.Languages.Language do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset
  alias Githubist.Repositories.Repository

  @type t :: %__MODULE__{}

  schema "languages" do
    field(:name, :string)
    field(:slug, :string)
    field(:score, :float)
    field(:total_stars, :integer)
    field(:total_repositories, :integer)
    field(:total_developers, :integer)

    has_many(:repositories, Repository)

    timestamps()
  end

  @doc false
  @spec changeset(__MODULE__.t(), map()) :: Changeset.t()
  def changeset(language, attrs) do
    language
    |> cast(attrs, [:name, :slug, :score, :total_stars, :total_repositories, :total_developers])
    |> validate_required([
      :name,
      :slug,
      :score,
      :total_stars,
      :total_repositories,
      :total_developers
    ])
    |> unique_constraint(:slug)
  end
end
