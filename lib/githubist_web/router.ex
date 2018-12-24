defmodule GithubistWeb.Router do
  use GithubistWeb, :router

  pipeline :graphql do
    plug(CORSPlug, origin: ["http://localhost:3000", "https://github.ist"])
    plug(:accepts, ["json"])
  end

  scope "/" do
    pipe_through(:graphql)

    forward("/graphql", Absinthe.Plug, schema: GithubistWeb.Schema)

    forward("/graphiql", Absinthe.Plug.GraphiQL,
      schema: GithubistWeb.Schema,
      interface: :playground
    )
  end
end
