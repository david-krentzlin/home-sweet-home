# Chezmoi Render Matrix

Use this matrix to quickly verify template rendering for common host contexts.

## Context values

| Context | develop | manage_lima_vms_from_this_host | has_gui | needs_opencode | taskwarrior |
| --- | --- | --- | --- | --- | --- |
| macOS host managing Lima VMs | false | true | true | false | false |
| Linux VM dev machine | true | false | false | true | true |
| macOS host not managing Lima VMs | false | false | true | false | false |

## Expected managed vs ignored

| Path | macOS host managing Lima VMs | Linux VM dev machine | macOS host not managing Lima VMs |
| --- | --- | --- | --- |
| `.local/bin/,vm-shell` | managed | ignored | ignored |
| `.local/bin/,vm-create` | managed | ignored | ignored |
| `.local/bin/,vm-sync-jfrog` | managed | ignored | ignored |
| `.config/wezterm/wezterm.lua` | managed | ignored | managed |
| `.config/opencode/**` | ignored | managed | ignored |
| `.taskrc` | ignored | managed | ignored |

## Manual test procedure

Repeat for each context above.

1. Set context values in chezmoi config:
   - Run `chezmoi edit-config`
   - Update the relevant values under your data block (`develop`, `manage_lima_vms_from_this_host`, `has_gui`, `needs_opencode`, `taskwarrior`)
2. Render with verbose dry-run:
   - Run `chezmoi apply --init --dry-run --verbose`
   - Confirm output lines for each path are consistent with the matrix (would manage vs not present)
3. Check managed set directly:
   - Run `chezmoi managed | rg '^\\.local/bin/,vm-(shell|create|sync-jfrog)$|^\\.config/wezterm/wezterm\\.lua$|^\\.config/opencode/|^\\.taskrc$'`
   - Compare matches to expected managed entries for the active context
