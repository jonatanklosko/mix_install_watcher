defmodule MixInstallWatcher.MixProject do
  use Mix.Project

  @version "0.1.0"
  @description "Automatic dependency recompilation for Mix.install/2"

  def project do
    [
      app: :mix_install_watcher,
      version: @version,
      description: @description,
      name: "MixInstallWatcher",
      elixir: "~> 1.16.2 or ~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [],
      mod: {MixInstallWatcher.Application, []}
    ]
  end

  defp deps do
    [
      {:file_system, "~> 1.0"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: "https://github.com/jonatanklosko/mix_install_watcher",
      source_ref: "v#{@version}",
      extras: ["README.md"]
    ]
  end

  def package do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/jonatanklosko/mix_install_watcher"
      }
    ]
  end
end
