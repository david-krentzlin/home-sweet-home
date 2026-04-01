# home-sweet-home

Setup my environments for both work and private context.
Manage dotfiles and unified tools.


## First-Time Setup

### Work

1. Clone this repo on your mac.
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

Run the two helper commands in that order.

6. Open the VM as `dev` or `agent` when you need a shell.

```bash
,dev
,agent
```

Use `,dev` and `,agent` instead of raw `limactl shell` commands.

Repos under `/workspaces` are intended to be shared between `dev` and `agent`.

## What you get

* Managed dotfiles for your host machine
* A virtual machine that is used to isolate all development from the host system 
* Managed dotfiles for the dev user in the dev vm
* [Optional] an agent setup for a development agent using opencode in the dev vm

## Daily Use

- Open the dev shell with `,dev`
- Open the agent shell with `,agent`
- Keep shared repos under `/workspaces` on the vm
- Pull repo changes in the VM repo checkout under `/workspaces/home-sweet-home`
- Re-run `bootstrap/vm/apply-user.sh` for `dev` or `agent`
- Apply `dev` first, then `agent`, if you are updating both
