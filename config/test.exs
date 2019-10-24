use Mix.Config

config :eventful, Eventful.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "eventful_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  hostname: "localhost",
  priv: "test/support/"

config :eventful,
  ecto_repos: [Eventful.Test.Repo]

config :logger, level: :warn
