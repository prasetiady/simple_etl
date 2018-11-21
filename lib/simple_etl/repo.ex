defmodule SimpleEtl.Repo do
  use Ecto.Repo,
    otp_app: :simple_etl,
    adapter: Ecto.Adapters.Postgres
end
