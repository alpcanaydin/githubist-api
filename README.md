# Github.ist API

This is the API repo for https://github.ist. You may also want to take a look to [Web](https://github.com/alpcanaydin/githubist) and [Fetcher](https://github.com/alpcanaydin/githubist-fetcher)

## Installation

Before the installation, please provide the seed data via [Fetcher](https://github.com/alpcanaydin/githubist-fetcher). You can find the instructions in the fetcher repo.

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.create && mix ecto.migrate`
- Seed the database with `mix run priv/repo/seeds.exs`

# Starting the API

You can start the API with `mix phx.server` command. You can visit [`http://0.0.0.0:4000`](http://0.0.0.0:4000) from your browser.
