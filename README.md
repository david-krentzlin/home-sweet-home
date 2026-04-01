# home-sweet-home

Private bootstrap repo for your macOS host and your Fedora Lima dev VM.

## What To Use

Use these scripts only:

- `bootstrap/host/macos.sh` to set up the macOS host
- `bootstrap/vm/macos-create-fedora.sh` to create the Fedora dev VM
- `bootstrap/vm/apply-user.sh` to apply `dev` or `agent` config from the host into the VM
- `bootstrap/apply-chezmoi.sh` to apply config on the host or inside the VM

## First-Time Setup

1. Clone this repo on your Mac.
2. Run the host bootstrap.

```bash
./bootstrap/host/macos.sh --context work
```

3. Create the Fedora VM.

```bash
./bootstrap/vm/macos-create-fedora.sh --context work
```

4. From the host, apply the `dev` user config into the VM.

```bash
./bootstrap/vm/apply-user.sh --target dev --context work
```

If `/workspaces/home-sweet-home` is missing in the VM, the helper clones it automatically.

5. From the host, apply the `agent` user config into the VM.

```bash
./bootstrap/vm/apply-user.sh --target agent --context work
```

6. Open the VM as `dev` or `agent` when you need a shell.

```bash
,dev
,agent
```

Use `,dev` and `,agent` instead of raw `limactl shell` commands.

Repos under `/workspaces` are intended to be shared between `dev` and `agent`.

## What You Get

- macOS host tools installed with Homebrew
- a Fedora Lima VM named `dev`
- host entry commands: `,dev` and `,agent`
- `chezmoi`-managed config for `host`, `dev`, and `agent`
- `mise` config applied when available

## Global Vs Repo Tools

Global `dev` tools are kept intentionally small:

- Go
- Bun
- Node
- Scala support for `work` via Java, `coursier`, `scalafmt`, and `metals`
- shared data and shell tooling like `gopls`, `shfmt`, `yq`, YAML, Bash, Docker, and Compose language servers

Language runtimes that usually vary by project should be installed per repository instead of globally.

- Ruby: install per repo
- Elixir and Erlang: install per repo

## Daily Use

- Open the dev shell with `,dev`
- Open the agent shell with `,agent`
- Keep shared repos under `/workspaces`
- Pull repo changes and re-run `bootstrap/vm/apply-user.sh` for `dev` or `agent`

The helper only clones `/workspaces/home-sweet-home` when it is missing. If the repo already exists in the VM, update it there before re-applying.

## Re-Apply Config

On macOS host:

```bash
./bootstrap/apply-chezmoi.sh --target host --context work
```

From the host for VM `dev` user:

```bash
./bootstrap/vm/apply-user.sh --target dev --context work
```

From the host for VM `agent` user:

```bash
./bootstrap/vm/apply-user.sh --target agent --context work
```

## Prompted Values

The `chezmoi` apply script will prompt for:

- git author name
- git author email
- GitHub username
- work username when `--context work` is used
