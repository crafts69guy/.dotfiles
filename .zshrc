# zsh interactive config kept minimal; primary shell is fish.

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# bun completions
[ -s "/Users/caongoccuong/.bun/_bun" ] && source "/Users/caongoccuong/.bun/_bun"
