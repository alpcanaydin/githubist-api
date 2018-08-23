defmodule Githubist.Developers.Developer do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset
  alias Githubist.Locations.Location
  alias Githubist.Repositories.Repository

  @type t :: %__MODULE__{}

  schema "developers" do
    field(:username, :string)
    field(:email, :string)
    field(:github_id, :integer)
    field(:name, :string)
    field(:avatar_url, :string)
    field(:bio, :string)
    field(:company, :string)
    field(:github_location, :string)
    field(:github_url, :string)
    field(:followers, :integer)
    field(:following, :integer)
    field(:public_repos, :integer)
    field(:total_starred, :integer)
    field(:score, :float)
    field(:github_created_at, :utc_datetime)

    belongs_to(:location, Location)
    has_many(:repositories, Repository)

    timestamps()
  end

  @doc false
  @spec changeset(__MODULE__.t(), map()) :: Changeset.t()
  def changeset(developer, attrs) do
    developer
    |> cast(attrs, [
      :username,
      :email,
      :github_id,
      :name,
      :avatar_url,
      :bio,
      :company,
      :github_url,
      :github_location,
      :followers,
      :following,
      :public_repos,
      :total_starred,
      :score,
      :github_created_at,
      :location_id
    ])
    |> validate_required([
      :username,
      :github_id,
      :avatar_url,
      :github_url,
      :github_location,
      :followers,
      :following,
      :public_repos,
      :total_starred,
      :score,
      :github_created_at,
      :location_id
    ])
    |> unique_constraint(:username)
    |> foreign_key_constraint(:location_id)
  end
end
