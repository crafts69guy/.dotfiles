#!/usr/bin/env bash
set -euo pipefail

# Stow dotfiles
stow -Rv .

# Verify shared agent rules are linked for Claude/Codex global instructions.
test -f "$HOME/agent-rules/README.md"

# Guard: warn (non-fatal) if the Ghostty Hue theme has drifted from its
# generated source. A stale theme should not block setup.
if ! "$HOME/.dotfiles/.scripts/sync-hue-ghostty.sh" --check; then
  echo "warning: Ghostty Hue theme is stale or unreachable — run .scripts/sync-hue-ghostty.sh to update." >&2
fi

# Run Tide configuration
fish ~/.dotfiles/.config/fish/scripts/tide_setup.fish
