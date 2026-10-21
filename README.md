# Neovim Config

<img width="1455" height="900" alt="Screenshot 2025-08-30 at 9 47 23 PM" src="https://github.com/user-attachments/assets/ba6e08e7-7d41-46fa-ba7d-8cd50bc587c2" />

Configured with [LazyVim](https://www.lazyvim.org/).

## Go projects

`lua/config/go_projects.lua` detects Datadog checkouts by the root Go module,
including symlinks and renamed Git worktrees. Each checkout gets its own LSP
client. Other repositories keep the normal `gopls` configuration.

`dd-source` uses `dd-gopls` with
`GOPLS_DISABLE_MODULE_LOADS=1`, following the
[Datadog FAQ](https://datadoghq.atlassian.net/wiki/spaces/FF/pages/5591271175/Patched+gopls+dd-gopls+usage+and+FAQ).
Install it with `dogbrew install dd-gopls`. Its profile prefers
`${DOGBREW_PREFIX:-/opt/dogbrew}/bin/dd-gopls`, then searches `PATH`.

- **datadog-agent:** uses standard `gopls` with normal `go.work` loading and reads
  build flags from the checkout's committed gopls plugin settings. Older branches
  use `dda inv print-default-build-tags`.
- **dd-source:** skips Bazel output directories and loads open packages on demand.
- Both profiles run diagnostics on save and disable optional Staticcheck analyses.

Open a new Neovim session to apply these settings. Restart Neovim after switching
branches that change build tags. No repository files or shell environment settings
are changed. Initial dependency loading can still take time. In dd-source,
references and renames only cover loaded packages, so they are not exhaustive
across the repository.

Run the profile checks with:

```sh
nvim --headless -u NONE -i NONE -l tests/go_projects.lua
```
