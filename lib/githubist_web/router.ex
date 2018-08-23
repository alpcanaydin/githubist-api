defmodule GithubistWeb.Router do
  use GithubistWeb, :router

  pipeline :graphql do
    plug(:accepts, ["json"])
  end

  scope "/" do
    pipe_through(:graphql)

    forward("/graphql", Absinthe.Plug, schema: GithubistWeb.Schema)

    if Mix.env() === :dev do
      forward("/graphiql", Absinthe.Plug.GraphiQL,
        schema: GithubistWeb.Schema,
        interface: :playground
      )
    end
  end
end
