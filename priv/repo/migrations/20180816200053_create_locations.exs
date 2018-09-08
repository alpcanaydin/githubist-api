defmodule Githubist.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext")

    create table(:locations) do
      add(:name, :string)
      add(:slug, :citext)
      add(:score, :float)
      add(:total_repositories, :integer)
      add(:total_developers, :integer)

      timestamps()
    end

    create(unique_index(:locations, [:slug]))
  end
end
