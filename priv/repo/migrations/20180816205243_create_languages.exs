defmodule Githubist.Repo.Migrations.CreateLanguages do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext")

    create table(:languages) do
      add(:name, :string)
      add(:slug, :citext)
      add(:score, :float)
      add(:total_stars, :integer)
      add(:total_repositories, :integer)

      timestamps()
    end

    create(unique_index(:languages, [:slug]))
  end
end
