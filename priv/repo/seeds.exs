# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Githubist.Repo.insert!(%Githubist.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Githubist.Developers
alias Githubist.ImportHelpers
alias Githubist.Locations
alias Githubist.Languages
alias Githubist.Repositories

# Import locations
locationsAndScores =
  "priv/data/locationScores.json"
  |> File.read!()
  |> Poison.decode!()

Enum.each(locationsAndScores, fn item ->
  {name, score} = item

  {:ok, _location} =
    Locations.create_location(%{
      name: ImportHelpers.capitalize(name),
      slug: ImportHelpers.create_location_slug(name),
      score: score
    })
end)

# Import languages
languagesAndScores =
  "priv/data/languageScores.json"
  |> File.read!()
  |> Poison.decode!()

Enum.each(languagesAndScores, fn item ->
  {name, data} = item

  {:ok, _language} =
    Languages.create_language(%{
      name: name,
      slug: ImportHelpers.create_language_slug(name),
      score: data["score"],
      total_stars: data["stars"],
      total_repositories: data["repos"]
    })
end)

# Import developers and repos
developersAndRepos =
  "priv/data/normalized.json"
  |> File.read!()
  |> Poison.decode!()

Enum.each(developersAndRepos, fn item ->
  location = Locations.get_location_by_slug!(ImportHelpers.create_location_slug(item["location"]))

  # Import developer
  developer_attrs = %{
    username: item["username"],
    email: item["email"],
    github_id: item["github_id"],
    name: item["name"],
    avatar_url: item["avatar_url"],
    bio: item["bio"],
    company: item["company"],
    github_location: item["github_location"],
    github_url: item["github_url"],
    followers: item["followers"],
    following: item["following"],
    public_repos: item["public_repos"],
    total_starred: item["total_starred"],
    score: item["score"],
    github_created_at: item["github_created_at"],
    location_id: location.id
  }

  {:ok, developer} = Developers.create_developer(developer_attrs)

  Enum.each(item["repos"], fn repository_item ->
    languageSlug = ImportHelpers.create_language_slug(repository_item["language"])
    language = Languages.get_language_by_slug(languageSlug)

    # Import repository
    repository_attrs = %{
      name: repository_item["name"],
      slug: repository_item["slug"],
      github_id: repository_item["github_id"],
      github_url: repository_item["github_url"],
      stars: repository_item["stars"],
      forks: repository_item["forks"],
      github_created_at: repository_item["github_created_at"],
      developer_id: developer.id,
      language_id: language.id
    }

    {:ok, _repository} = Repositories.create_repository(repository_attrs)
  end)
end)
