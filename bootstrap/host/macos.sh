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
BREWFILE_WORK="$SCRIPT_DIR/Brewfile.work"
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

if [[ "$CONTEXT" == "work" ]]; then
	if [[ ! -f "$BREWFILE_WORK" ]]; then
		echo "Error: Homebrew work bundle file not found: $BREWFILE_WORK" >&2
		exit 1
	fi

	brew bundle --file "$BREWFILE_WORK"

	if ! brew list --cask wezterm >/dev/null 2>&1 && ! brew list --cask wezterm@nightly >/dev/null 2>&1; then
		brew install --cask wezterm
	fi
fi

if [[ "$SKIP_APPLY" -eq 0 ]]; then
	"$REPO_ROOT/bootstrap/apply-chezmoi.sh" --target host --context "$CONTEXT"
fi

echo "Host bootstrap complete."
echo "Next: run bootstrap/vm/macos-create-fedora.sh"
