defmodule MixInstallWatcher.Worker do
  @moduledoc false

  use GenServer

  @installation_check_interval_ms 1_000

  # We debounce the recompilation by a tiny margin to merge multiple
  # file events. For example, Git operations may effectively modify
  # multiple files and we don't want to recompile on every event
  @recompile_debounce_ms 5

  # Within each watched project, we ignore top-level directories
  # based on the exclude pattern. This matches directories such as
  # .elixir_ls and _build
  @exclude_pattern ~r/^[._]/

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, {})
  end

  @impl true
  def init({}) do
    schedule_installation_check()
    {:ok, %{recompile_timer_ref: nil}}
  end

  @impl true
  def handle_info(:installation_check, state) do
    if Mix.installed?() do
      {:ok, pid} = FileSystem.start_link(dirs: watch_paths())
      FileSystem.subscribe(pid)
    else
      schedule_installation_check()
    end

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, {_path, _events}}, state) do
    if ref = state.recompile_timer_ref do
      Process.cancel_timer(ref)
    end

    recompile_timer_ref = Process.send_after(self(), :recompile, @recompile_debounce_ms)

    {:noreply, %{state | recompile_timer_ref: recompile_timer_ref}}
  end

  def handle_info(:recompile, state) do
    try do
      IEx.Helpers.recompile()
    catch
      _error -> :error
    end

    {:noreply, %{state | recompile_timer_ref: nil}}
  end

  defp schedule_installation_check() do
    Process.send_after(self(), :installation_check, @installation_check_interval_ms)
  end

  defp watch_paths() do
    for path <- local_deps_paths(),
        dirname <- File.ls!(path),
        not exclude?(dirname),
        do: Path.join(path, dirname)
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

  defp exclude?(dirname) do
    Regex.match?(@exclude_pattern, dirname)
  end
end
