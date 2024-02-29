# MixInstallWatcher

A utility package for `Mix.install/2` that watches and recompiles all local path dependencies.

## Installation

Add `:mix_install_watcher` to your dependency list in `Mix.install/2`:

```elixir
Mix.install([
  {:some_lib, path: "/path/to/some_lib"}
  ...,
  {:mix_install_watcher, "~> 0.1.0"}
])
```

Whenever the source of `:some_lib` changes, it will get recompiled automatically.

## Usage in Livebook

The motivation for this package is [Livebook](https://github.com/livebook-dev/livebook), though it works just as well in IEx.

Keep in mind that recompiling dependency modules is **not** going to mark any notebook cells as stale. This means that the given notebook state may no longer be reproducable. This package is meant as a utility when prototyping alongside a Mix project.
