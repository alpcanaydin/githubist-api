# Github.ist API

This is the API repo for https://github.ist. You may also want to take a look to [Web](https://github.com/alpcanaydin/githubist) and [Fetcher](https://github.com/alpcanaydin/githubist-fetcher)

## Installation

Before the installation, please provide the seed data via [Fetcher](https://github.com/alpcanaydin/githubist-fetcher). You can find the instructions in the fetcher repo.

### Docker

- Install dependencies with `./mix deps.get`
- Create and migrate your database with `./mix ecto.create && ./mix ecto.migrate`
- Seed the database with `./mix run priv/repo/seeds.exs`

#### Executing Custom Commands

To run commands other than mix tasks, you can use the `./run` script.

`./run iex -S mix`

### Traditional Setup

- Change directory to src with `cd src/`
- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.create && mix ecto.migrate`
- Seed the database with `mix run priv/repo/seeds.exs`

# Starting the API

You can start the API with `mix phx.server` command. You can visit [`http://0.0.0.0:4000`](http://0.0.0.0:4000) from your browser.

## Wıth Docker

You can start the API with `docker-compose up`. You can check it via `curl 'http://localhost:4000/graphql' -H 'content-type: application/json' --data-binary '{"operationName":null,"variables":{"username":"mdegis"},"query":"query ($username: String!) {\n  developer(username: $username) {\n    ...BasicDeveloper\n    bio\n    githubUrl\n    __typename\n  }\n}\n\nfragment BasicDeveloper on Developer {\n  id\n  name\n  username\n  avatarUrl\n  __typename\n}\n"}'`