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

# Guard: warn (non-fatal) if the bat Hue themes have drifted, then make sure
# they are compiled into bat's theme cache (bat only reads built caches).
if command -v bat >/dev/null 2>&1; then
  if ! "$HOME/.dotfiles/.scripts/sync-hue-bat.sh" --check; then
    echo "warning: bat Hue themes are stale or unreachable — run .scripts/sync-hue-bat.sh to update." >&2
  fi
  if ! bat --list-themes 2>/dev/null | grep -q '^hue-mua$'; then
    bat cache --build >/dev/null
  fi
fi

# Guard: warn (non-fatal) if the herdr Hue theme plugin isn't installed. Unlike
# Ghostty/tmux, herdr has no scriptable theme API — the "hue-theme" plugin
# (packages/herdr-plugin in the hue-theme repo) owns applying it, so it needs
# `herdr plugin install crafts69guy/hue-theme/packages/herdr-plugin` once.
if command -v herdr >/dev/null 2>&1 && ! herdr plugin list --json 2>/dev/null | grep -q '"plugin_id":"hue-theme"'; then
  echo "warning: herdr Hue theme plugin not installed — run: herdr plugin install crafts69guy/hue-theme/packages/herdr-plugin" >&2
fi

# Run Tide configuration
fish ~/.dotfiles/.config/fish/scripts/tide_setup.fish
