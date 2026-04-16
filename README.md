# Home Sweet Home

Dotfiles for my host plus an isolated Fedora VM for development.

## Prerequisites

These tools must be present on the host system.
If you run inside a limavm created with this repository, you don't need to install it yourself.
The boostrap process will do that.

- chezmoi
- mise

## Apply the code

```bash
chezmoi init --apply david-krentzlin/home-sweet-home
```

Answer the questions that you'll be asked.

## Create a VM

The following will create a lima based fedora vm, which I use for development.
You have to have said yes, when you were asked if this host manages a lima vm during chezmoi bootsrap

```bash
,vm-create
```

```bash
,vm-shell
```

### Setup ssh in the vm

```bash
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
ssh-keygen -q -t ed25519 -N '' -C "dev@dev" -f "$HOME/.ssh/id_ed25519"
```

### Apply dotfiles in the vm

```
chezmoi init --apply david-krentzlin/home-sweet-home
mise install
,chezmoi-apply
```

## Access VM Servers From The Host

The VM uses `vzNAT`, so there are two supported access patterns from the host.

If the server binds to `127.0.0.1` or `localhost` inside the VM, Lima forwards guest localhost ports to host localhost.

If the server binds to `0.0.0.0`, open it via the VM IP instead.

Examples:

```bash
# Rails inside the VM
bin/rails server -b 127.0.0.1 -p 3000

# Open on the host
http://localhost:3000
```

```bash
# Another app inside the VM
./server --host 127.0.0.1 --port 8080

# Open on the host
http://localhost:8080
```

```bash
# App bound to all interfaces inside the VM
./server --host 0.0.0.0 --port 9000

# Get the VM IP from the host and also connect
,vm-ip
,vm-open 9000
```

Notes:

- Prefer binding app servers to `127.0.0.1` in the VM
- Use the same port number on the host for localhost-forwarded services
- Use the VM IP for services bound to `0.0.0.0`
- Existing VMs need a one-time `vzNAT` network update and restart to pick this up
- Host helpers: `,vm-ip` prints the VM IP and `,vm-open [PORT]` opens `http://<vm-ip>[:PORT]`

## OpenCode Browser Auth In The VM

OpenCode browser auth currently redirects back to `localhost` on the machine that started `opencode`.

When `opencode` runs in the VM, the final browser redirect therefore fails on the host. The working flow is:

1. Run `/connect` inside `opencode` in the VM.
2. Complete the browser login on the host.
3. When the browser lands on the failing `http://localhost:...` callback URL, copy that full URL.
4. Back in the VM, call it manually:

```bash
curl '<paste-the-final-localhost-url-here>'
```

That delivers the auth callback to the OpenCode process running inside the VM.

## Sync JFrog Credentials To The VM

JFrog credentials stay sourced from 1Password on the host and are copied explicitly into the VM when needed.

The host shell provides `,jfrog_oidc_env` when `Do you manage Lima VMs from this host` is `yes`; it exports `JFROG_OIDC_USER` and `JFROG_OIDC_TOKEN`.

Sync credentials for a VM user with:

```bash
,jfrog_oidc_env
,vm-sync-jfrog --host your.jfrog.example.com
```

The default realm is `Artifactory Realm`. If `sbt` itself needs authenticated bootstrap access and your setup uses a different realm, pass `--realm` explicitly.

If you are not sure which realm JFrog is using, inspect the `WWW-Authenticate` response header from a protected repository URL and copy the realm value.

If Ruby gems use a different host than Scala/sbt, pass `--ruby-host` too.

The sync writes VM-local files only:

- `~/.config/home-sweet-home/jfrog-oidc.env`
- `~/.ivy2/.credentials`
- `~/.config/coursier/credentials.properties`

On VM work shells, `SBT_CREDENTIALS` and `COURSIER_CREDENTIALS` are exported automatically when those files exist.

## Setup Scala In The VM

When Scala toolchain support is selected in `chezmoi`, after syncing JFrog credentials into the VM, run:

```bash
,setup-scala
```

This installs or updates the Scala toolchain expected by the VM setup:

- trust and install the current `mise` tool config
- add a `helm-ls` symlink when `helm_ls` is installed via `mise`
- install `sbt` and `metals` via `cs`

`COURSIER_CREDENTIALS` and `SBT_CREDENTIALS` are picked up from the JFrog files synced into the VM.

## Terminal IDE

`chezmoi` now manages the Helix, Zellij, Lazygit, Yazi, and Scooter config from this repo directly.

On development machines, `mise install` always pulls the generic editor-side tools managed here, including `lazygit`, `zellij`, `yazi`, `scooter`, `delta`, `prettier`, and `emmet-ls`.

Language-specific toolchains are installed from the `chezmoi` language prompts (`Go`, `Ruby`, `Scala`, `Rust`) only when selected.
To install or update a source-built Helix from the official repository on Linux or macOS, run `,helix-install` after Rust is available.
Theme assets for Yazi and Scooter are managed directly in this repo.
