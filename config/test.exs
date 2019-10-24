use Mix.Config

config :eventful, Eventful.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "eventful_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  username: System.get_env("POSTGRES_USERNAME") || "postgres",
  priv: "test/support/"

config :eventful,
  ecto_repos: [Eventful.Test.Repo]

config :logger, level: :warn
