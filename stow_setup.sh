#!/usr/bin/env bash
set -euo pipefail

# Stow dotfiles
stow -Rv .

# Verify shared agent rules are linked for Claude/Codex global instructions.
test -f "$HOME/agent-rules/README.md"

# Run Tide configuration
fish ~/.dotfiles/.config/fish/scripts/tide_setup.fish
