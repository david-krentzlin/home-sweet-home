#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
	echo "Error: bootstrap/host/macos.sh must be run on macOS." >&2
	exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
	echo "Error: Homebrew is required on the macOS host." >&2
	exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONTEXT="work"
SKIP_APPLY=0

while [[ $# -gt 0 ]]; do
	case "$1" in
	--context)
		CONTEXT="$2"
		shift 2
		;;
	--skip-apply)
		SKIP_APPLY=1
		shift
		;;
	-h | --help)
		echo "Usage: bootstrap/host/macos.sh [--context work|private] [--skip-apply]"
		exit 0
		;;
	*)
		echo "Error: unknown argument '$1'." >&2
		exit 1
		;;
	esac
done

if [[ "$CONTEXT" != "work" && "$CONTEXT" != "private" ]]; then
	echo "Error: context must be one of: work, private." >&2
	exit 1
fi

if ! command -v chezmoi >/dev/null 2>&1; then
	brew install chezmoi
fi

if ! command -v limactl >/dev/null 2>&1; then
	brew install lima
fi

if ! command -v tmux >/dev/null 2>&1; then
	brew install tmux
fi

if [[ "$CONTEXT" == "work" ]] && ! brew list --formula openjdk@21 >/dev/null 2>&1; then
	brew install openjdk@21
fi

if ! command -v bat >/dev/null 2>&1 || ! command -v eza >/dev/null 2>&1 || ! command -v fd >/dev/null 2>&1 || ! command -v rg >/dev/null 2>&1 || ! command -v zoxide >/dev/null 2>&1 || ! command -v fzf >/dev/null 2>&1; then
	brew install bat eza fd ripgrep zoxide fzf
fi

if [[ "$SKIP_APPLY" -eq 0 ]]; then
	"$REPO_ROOT/bootstrap/apply-chezmoi.sh" --target host --context "$CONTEXT"
fi

echo "Host bootstrap complete."
echo "Next: run bootstrap/vm/macos-create-fedora.sh"
