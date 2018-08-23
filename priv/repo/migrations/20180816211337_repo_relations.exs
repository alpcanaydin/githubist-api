defmodule Githubist.Repo.Migrations.RepoRelations do
  use Ecto.Migration

  def change do
    alter table(:repositories) do
      add(:developer_id, references(:developers))
      add(:language_id, references(:languages))
    end
  end
end
