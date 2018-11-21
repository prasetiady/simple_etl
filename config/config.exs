use Mix.Config

config :simple_etl, :ecto_repos, [SimpleEtl.Repo]

config :simple_etl, SimpleEtl.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "postgres",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  timeout: 5000,
  pool_size: 20

config :logger, level: :info
