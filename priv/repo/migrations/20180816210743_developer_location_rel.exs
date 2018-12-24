defmodule Githubist.Repo.Migrations.DeveloperLocationRel do
  use Ecto.Migration

  def change do
    alter table(:developers) do
      add(:location_id, references(:locations))
    end
  end
end
