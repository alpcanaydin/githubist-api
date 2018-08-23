defmodule Githubist.Locations.Location do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset
  alias Githubist.Developers.Developer

  @type t :: %__MODULE__{}

  schema "locations" do
    field(:name, :string)
    field(:slug, :string)
    field(:score, :float)

    has_many(:developers, Developer)

    timestamps()
  end

  @doc false
  @spec changeset(__MODULE__.t(), map()) :: Changeset.t()
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :slug, :score])
    |> validate_required([:name, :slug, :score])
    |> unique_constraint(:slug)
  end
end
