defmodule MixInstallWatcher.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MixInstallWatcher.Worker
    ]

    opts = [strategy: :one_for_one, name: MixInstallWatcher.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
