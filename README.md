# agentex

`agentex` bootstraps a repeatable development environment around a small set of standard tools:

- Lima for the Fedora VM on macOS
- `cloud-init` for first-boot VM provisioning
- `chezmoi` for user configuration
- `mise` for runtimes and developer tools

The architecture is defined in `DEV_ENV_PLAN.md`.

## Configuration Model

This repository is moving to two explicit selectors:

- `target`: `host`, `dev`, `agent`
- `context`: `work`, `private`

Current implementation scope is `context=work` only.

Meaning:

- `host` is the host machine
- `dev` is the Fedora VM development user
- `agent` is the Fedora VM agent user

## Current Direction

The old custom `stow` and split bootstrap flow is now legacy reference material.

The preferred direction is:

1. run `bootstrap/host/macos.sh`
2. create the Fedora VM with `bootstrap/vm/macos-create-fedora.sh`
3. apply config with `bootstrap/apply-chezmoi.sh`
4. add config and tooling incrementally

Current context support:

- host bootstrap supports `work` and `private`
- VM creation remains `context=work` only for now

## Minimal First Slice

The first slice aims to prove the architecture, not full parity.

Included now:

- minimal macOS host bootstrap for `chezmoi` and Lima
- minimal Lima template for a Fedora work VM
- cloud-init-backed VM provisioning for:
  - `dev`
  - `agent`
  - shared `/workspaces`
  - minimal base packages
  - `chezmoi`
  - `mise`
- minimal `chezmoi` source state for:
  - git identity
  - host `,dev` and `,agent` entry commands
  - target/context marker config
  - scoped OpenCode config for `agent`
- first fundamental packages:
  - `mise` config, trusted and installed during `chezmoi` apply when `mise` is present
  - minimal `zsh` config via `chezmoi`
  - minimal `starship` prompt config via `chezmoi`, installed through `mise`
  - minimal `tmux` config via `chezmoi`, installed via the host and Fedora package managers
  - core shell helper tools for `z`, `zl`, file search, and listing aliases
  - dev runtime and LSP install path via context-aware `mise` config, with `metals` installed through `coursier` as the one architecture-specific exception

Note: the host `,dev` entry uses `sudo -iu dev` inside the VM so the `dev` login sees the shared `devvm` group membership established during first boot.

Deferred until later:

- Neovim integration
- extra CLI tools
- LSP stacks
- full private context support
- `opencode.json` model templating by `context`

## Repository Layout

The key directories for the new path are:

```text
.
├── bootstrap/
│   ├── apply-chezmoi.sh
│   ├── host/
│   │   └── macos.sh
│   └── vm/
│       └── macos-create-fedora.sh
├── chezmoi/
├── cloud-init/
├── lima/
└── mise/
```

The older `packages/`, `profiles/`, and related helpers remain in the tree as migration reference and should not be expanded further.

## Next Steps

1. Prove `target=host`, `target=dev`, and `target=agent` for `context=work`
2. Port only one config package at a time
3. Add `context=private` after the work setup is stable
