defmodule Githubist.Repo.Migrations.CreateRepositories do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext")

    create table(:repositories) do
      add(:name, :string)
      add(:slug, :citext)
      add(:description, :text)
      add(:github_id, :integer)
      add(:github_url, :string)
      add(:stars, :integer)
      add(:forks, :integer)
      add(:github_created_at, :utc_datetime)

      timestamps()
    end

    create(unique_index(:repositories, [:slug]))
  end
end
