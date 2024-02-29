defmodule MixInstallWatcher.Worker do
  @moduledoc false

  use GenServer

  @installation_check_interval_ms 1_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, {})
  end

  @impl true
  def init({}) do
    schedule_installation_check()
    {:ok, {}}
  end

  @impl true
  def handle_info(:installation_check, state) do
    if Mix.installed?() do
      paths = local_deps_paths()
      {:ok, pid} = FileSystem.start_link(dirs: paths)
      FileSystem.subscribe(pid)
    else
      schedule_installation_check()
    end

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, {_path, _events}}, state) do
    try do
      IEx.Helpers.recompile()
    catch
      _error -> :error
    end

    {:noreply, state}
  end

  defp schedule_installation_check() do
    Process.send_after(self(), :installation_check, @installation_check_interval_ms)
  end

  defp local_deps_paths() do
    # Note that this is a private API, but this package is just a dev
    # utility, so it is fine
    Mix.in_install_project(fn ->
      deps_paths = Mix.Project.deps_paths()

      for {dep, Mix.SCM.Path} <- Mix.Project.deps_scms() do
        Map.fetch!(deps_paths, dep)
      end
    end)
  end
end
