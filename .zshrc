# zsh interactive config kept minimal; primary shell is fish.

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
