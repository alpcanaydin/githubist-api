defmodule Githubist.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext")

    create table(:locations) do
      add(:name, :string)
      add(:slug, :citext)
      add(:score, :float)

      timestamps()
    end

    create(unique_index(:locations, [:slug]))
  end
end
