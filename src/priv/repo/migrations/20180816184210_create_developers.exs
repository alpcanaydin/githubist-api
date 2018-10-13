defmodule Githubist.Repo.Migrations.CreateDevelopers do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext")

    create table(:developers) do
      add(:username, :citext)
      add(:email, :citext)
      add(:github_id, :integer)
      add(:name, :string)
      add(:avatar_url, :string)
      add(:bio, :text)
      add(:company, :string)
      add(:github_location, :string)
      add(:github_url, :string)
      add(:public_repos, :integer)
      add(:followers, :integer)
      add(:following, :integer)
      add(:total_starred, :integer)
      add(:score, :float)
      add(:github_created_at, :utc_datetime)

      timestamps()
    end

    create(unique_index(:developers, [:username]))
    create(index(:developers, [:email]))
  end
end
