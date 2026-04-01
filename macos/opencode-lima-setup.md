# Minimal AI Pairing Setup

This document tracks the current preferred macOS setup direction.

## Current Architecture

The repository is moving to:

- Lima for the Fedora VM lifecycle
- `cloud-init` for first-boot VM provisioning
- `chezmoi` for user configuration
- `mise` for runtimes and tools

Selectors:

- `target`: `host`, `dev`, `agent`
- `context`: `work`, `private`

Current implementation scope is `context=work` only.

## Preferred Flow

On the macOS host:

```bash
git clone git@github.com:david-krentzlin/agentex.git
cd agentex
./bootstrap/host/macos.sh
./bootstrap/vm/macos-create-fedora.sh
```

For a private host-only render, use:

```bash
./bootstrap/host/macos.sh --context private
```

VM creation is still `context=work` only.

Apply host configuration:

```bash
./bootstrap/apply-chezmoi.sh --target host --context work
```

Enter the VM as the dev user:

```bash
limactl shell --workdir /home/dev dev sudo -iu dev
```

Then inside the VM, from the repository checkout:

```bash
./bootstrap/apply-chezmoi.sh --target dev --context work
```

To switch into the agent user from the host once the VM is ready:

```bash
,agent
```

Or manually:

```bash
limactl shell --workdir /home/dev dev sudo -iu agent
```

Then apply the agent target:

```bash
./bootstrap/apply-chezmoi.sh --target agent --context work
```

## Current Scope

The first slice is intentionally minimal.

Included:

- host bootstrap for Lima and `chezmoi`
- Fedora VM creation from a repo-managed Lima template
- cloud-init-backed provisioning for `dev`, `agent`, and `/workspaces`
- scoped `chezmoi` config for git, shell setup, OpenCode, and target/context markers
- managed `mise`, `zsh`, `starship`, `tmux`, and shell helper baseline

Deferred:

- Neovim integration
- LSP bundles
- private-context setup
- `opencode.json` model templating by `context`

## Legacy Note

The older `macos/bootstrap-host.sh` and `macos/bootstrap-vm.sh` flow is now legacy reference material. Do not treat it as the target architecture.
