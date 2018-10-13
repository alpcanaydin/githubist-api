# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :githubist,
  ecto_repos: [Githubist.Repo]

# Configures the endpoint
config :githubist, GithubistWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "0x1WP1wBkdoyhw9PdEb4mLLfQOjpiJoBu4TSXDYP1hhkBVikdRIndZla0vp4zdH0",
  render_errors: [view: GithubistWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Githubist.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
