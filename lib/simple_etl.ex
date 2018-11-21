defmodule SimpleEtl do
  use Application

  import Supervisor.Spec

  def start(_type, _args) do
    children = [
      worker(SimpleEtl.Repo, []),
      worker(SimpleEtl.Manager, [])
    ]

    opts = [strategy: :one_for_one, name: SimpleEtl.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
