# Task Findings And Cleanup Plan

Date: 2026-04-16
Repo: `home-sweet-home`

Status legend:

- `[ ]` pending
- `[~]` in progress
- `[x]` done

## Scope

This file captures concrete findings and an execution plan for:

- shell consistency (bash vs zsh vs sh)
- command naming consistency
- chezmoi data/template simplification
- linux vs macOS separation
- host/vm/work separation
- keybinding conflicts (helix, zellij, ghostty, wezterm)
- zellij CLI recipe simplification

## Prioritized Findings

### P1 - Keybinding collisions and contradictions

1. Terminal-level `Alt` collisions between Ghostty and Zellij

- Evidence:
  - `chezmoi/dot_config/ghostty/config:67`
  - `chezmoi/dot_config/zellij/config.kdl.tmpl:91`
- Problem: many `Alt` combinations are bound in both layers, so terminal binds can swallow keys before Zellij sees them.
- Solution: remove ghostty config an rely on wezterm

2. Contradictory Ghostty binding for `alt+n`

- Evidence:
  - `chezmoi/dot_config/ghostty/config:94`
  - `chezmoi/dot_config/ghostty/config:129`
- Problem: `alt+n` is assigned and later unbound.
- Solutin: remove ghostty config and rely on wezterm

3. Helix `Ctrl-s` override shadows a built-in Helix behavior

- Evidence:
  - `chezmoi/dot_config/helix/config.toml.tmpl:51`
- Problem: custom save mapping conflicts with an existing Helix keymap action.

### P1 - Zellij config duplication

4. `normal` and `locked` blocks repeat almost all bindings

- Evidence:
  - `chezmoi/dot_config/zellij/config.kdl.tmpl:24`
  - `chezmoi/dot_config/zellij/config.kdl.tmpl:120`
- Problem: high maintenance cost and drift risk.

### P2 - Command naming and boundary issues

5. `docker` command is shadowed to `podman`

- Evidence:
  - `chezmoi/dot_local/bin/executable_docker:1`
- Problem: unexpected behavior for workflows that assume canonical `docker` semantics.
- Solution: leave as is since we want to have the docker shim

6. Interactive shortcuts and workflow helpers are mixed

- Evidence:
  - `README.md:100`
  - `chezmoi/dot_local/bin/executable_,zlayout:1`
  - `chezmoi/dot_local/bin/executable_,ghotspots:1`
- Problem: command intent is not always obvious from naming.
- Solution: distinguish between interactive commands, which live in the namespace with the comma prefix, and non-interactive helpers,
  which should get the name of the program they are used by as prefix, i.e. zellij-, hx-, etc.

### P2 - Shell consistency issues

7. Mixed shell execution styles in bash scripts (`sh -c` wrappers)

- Evidence:
  - `chezmoi/dot_local/bin/executable_,gactivity:8`
  - `chezmoi/dot_local/bin/executable_,gbugs:4`
  - `chezmoi/dot_local/bin/executable_,ghotspots:4`
- Problem: reduced consistency and harder quoting/debugging.
- Solution: stick to using bash for those scripts

8. Typo in Homebrew zsh plugin path check

- Evidence:
  - `chezmoi/dot_config/zsh/rc.d/05_homebrew.tmpl:8`
- Problem: plugin load check uses misspelled path segment.
- Solution: fix, but also review when the homebrew related code is loaded.

### P2 - Chezmoi model complexity and coupling

9. Repeated boolean extraction and derived logic spread across templates

- Evidence:
  - `chezmoi/.chezmoi.toml.tmpl:1`
  - `chezmoi/.chezmoiignore.tmpl:1`
  - `chezmoi/dot_config/mise/config.toml.tmpl:1`
  - `chezmoi/dot_taskrc.tmpl:1`
- Problem: same context is recomputed in many places.

10. Host/vm behavior inferred indirectly (`not .develop`)

- Evidence:
  - `chezmoi/.chezmoiignore.tmpl:1`
  - `chezmoi/dot_gitconfig.tmpl:1`
  - `chezmoi/dot_config/starship.toml.tmpl:1`
- Problem: topology assumptions are implicit and brittle.

### P3 - Completed cleanup item

11. Removed underused bootstrap context artifact

- Change:
  - removed `chezmoi/dot_config/home-sweet-home/bootstrap-context.toml.tmpl`
- Outcome: no in-repo consumer depended on this file.

## Concrete Task List

## Phase 0 - Baseline

- [ ] T0.1 Create a keybinding matrix document for Helix/Zellij/WezTerm. Also remove ghostty config to simplify.

  - Deliverable: `docs/keybinding-matrix.md`
  - Acceptance: each active keybind appears exactly once with owner tool.

- [ ] T0.2 Render and inspect chezmoi output for representative contexts.
  - Contexts:
    - macOS host managing VM
    - Linux VM dev user
    - macOS host without VM management
  - Acceptance: expected files are included/excluded per context.

## Phase 1 - Context Model Refactor (includes your prompt idea)

- [ ] T1.1 Add explicit capability prompt: `manage_lima_vms_from_this_host`.
  - File: `chezmoi/.chezmoi.toml.tmpl`
  - Acceptance: prompt appears once on init/update and is persisted in `[data]`.

- [ ] T1.2 Stop inferring host via `not .develop` where possible.
  - Files:
    - `chezmoi/.chezmoiignore.tmpl`
    - `chezmoi/dot_gitconfig.tmpl`
    - `chezmoi/dot_config/starship.toml.tmpl`
    - `chezmoi/dot_config/zsh/rc.d/20_jfrog.tmpl`
  - Acceptance: template conditions use explicit capabilities and roles.

- [ ] T1.3 Keep dev-tool installation and VM-management as separate concerns.
  - File: `chezmoi/dot_config/mise/config.toml.tmpl`
  - Acceptance: `develop_machine` and `manage_lima_vms_from_this_host` can be toggled independently.

## Phase 2 - Keybinding Conflict Resolution

- [ ] T2.1 Decide owner for `Alt` pane/tab navigation in terminal sessions.
  - Option A: Zellij owns `Alt` navigation; Ghostty moves to `super` or leader combos.
  - Option B: Ghostty owns `Alt`; Zellij is remapped.
  - Acceptance: no duplicated hotkeys across layers for shared actions.

- [ ] T2.2 Remove contradictory Ghostty binds.
  - File: `chezmoi/dot_config/ghostty/config`
  - Acceptance: no key is both set and unbound in the same file.

- [ ] T2.3 Replace Helix `Ctrl-s` with a non-conflicting save mapping.
  - File: `chezmoi/dot_config/helix/config.toml.tmpl`
  - Acceptance: save action remains easy and `Ctrl-s` no longer shadows existing Helix behavior.

## Phase 3 - Shell Consistency Cleanup

- [ ] T3.1 Standardize script policy: bash for non-interactive automation and all other shell helpers. Zsh is only used for user interaction.
  - Scope: `bootstrap/`, `chezmoi/dot_local/bin/`, `.chezmoiscripts/`
  - Acceptance: no unnecessary `sh -c` wrappers remain.

- [ ] T3.2 Add shared shell env layer for common exports and PATH.
  - Suggested files:
    - `chezmoi/dot_bashrc`
    - `chezmoi/dot_config/shell/env` (or equivalent)
    - `chezmoi/dot_zshrc`
    - `chezmoi/dot_bash_profile`
  - Acceptance: mise and shared env behavior is consistent in bash and zsh.

- [ ] T3.3 Fix zsh Homebrew plugin path typo and robust eval quoting.
  - File: `chezmoi/dot_config/zsh/rc.d/05_homebrew.tmpl`
  - Acceptance: plugin checks work and shellcheck warnings are reduced.

## Phase 4 - Command Naming Taxonomy

- [ ] T4.1 Define command categories in README.
  - Example:
    - `,` prefix: interactive commands
    - `tool-*` prefix: workflow helpers (`zellij-*`, `hx-*`, `git-*`, `lima-*`)
  - File: `README.md`
  - Acceptance: documented naming rule and examples.

- [ ] T4.2 Rename selected helpers to match category scheme.
  - Files: `chezmoi/dot_local/bin/executable_,*`
  - Acceptance: names reflect purpose and caller tool.

- [ ] T4.3 Keep backwards-compatible wrappers during migration.
  - Acceptance: legacy command names still work with deprecation message.

- [ ] T4.4 Remove or explicitly gate command shadowing for `docker`.
  - File: `chezmoi/dot_local/bin/executable_docker`
  - Acceptance: behavior is explicit and documented.

## Phase 5 - Zellij Simplification With CLI Recipes

- [ ] T5.1 Introduce one shared floating-run helper for popup tools. These tools will be renamed before.
  - Targets:
    - `chezmoi/dot_local/bin/executable_,hx-lazygit`
    - `chezmoi/dot_local/bin/executable_,hx-scooter`
    - `chezmoi/dot_local/bin/executable_,hx-yazi`
    - `chezmoi/dot_local/bin/executable_,md-preview`
  - Acceptance: shared geometry and run semantics are centralized.

- [ ] T5.2 Reduce duplicated Zellij keybind blocks.
  - File: `chezmoi/dot_config/zellij/config.kdl.tmpl`
  - Acceptance: only mode-specific deltas differ between `normal` and `locked`.

- [ ] T5.3 Prefer direct command actions over `zsh -lc` wrappers where safe.
  - Files:
    - `chezmoi/dot_config/zellij/config.kdl.tmpl`
    - `chezmoi/dot_config/zellij/layouts/dev.kdl`
    - `chezmoi/dot_config/zellij/layouts/dev-agentic.kdl`
  - Acceptance: fewer shell wrappers, same behavior.

## Phase 6 - Chezmoi Templating Simplification

- [ ] T6.1 Consolidate context booleans in one place. Also find better shorter names. If two variables belong to same context, use similar prefix, i.e. helix_, zellij_.
  - File: `chezmoi/.chezmoi.toml.tmpl`
  - Acceptance: downstream templates consume normalized fields only.

- [ ] T6.2 Remove repeated `hasKey` boilerplate where defaults can be normalized.
  - Files:
    - `chezmoi/.chezmoiignore.tmpl`
    - `chezmoi/dot_config/mise/config.toml.tmpl`
    - `chezmoi/dot_taskrc.tmpl`
    - `chezmoi/.chezmoiscripts/run_after_taskwarrior-linux.sh.tmpl`
  - Acceptance: repeated guard patterns are reduced.

- [x] T6.3 Remove bootstrap context artifact.
  - Change: removed `chezmoi/dot_config/home-sweet-home/bootstrap-context.toml.tmpl`.

## Validation Checklist

- [ ] V1 `chezmoi` render matrix passes for selected contexts.
- [ ] V2 Keybinding matrix has no duplicate ownership for same combo and action.
- [ ] V3 Daily commands in `README.md` are runnable after renames/wrappers.
- [ ] V4 Helix tool integrations (`C-e`, `C-r`, `C-g`, `C-p`) still work.
- [ ] V5 Zellij layouts (`default`, `dev`, `dev-agentic`) still open expected panes.
- [ ] V6 Shell scripts pass `shellcheck` for changed files.

## Suggested Execution Order

1. Phase 1 (context model and explicit VM-management prompt)
2. Phase 2 (keybinding conflict fixes)
3. Phase 3 (shell consistency)
4. Phase 4 (command taxonomy and migration wrappers)
5. Phase 5 (zellij CLI recipe consolidation)
6. Phase 6 (chezmoi template simplification)
7. Validation checklist and README finalization

## Backlog Notes

- Reconsider whether `bootstrap/host/Brewfile.work` is still needed as a separate file.
- Candidate change: move the brew package list into `chezmoi/.chezmoiscripts/run_once_after_host-brew-bundle.sh.tmpl` and keep execution gated to macOS host only.
