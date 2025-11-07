# FZF Configuration for Fish Shell
# Optimized for LazyVim + Tide + Tmux workflow

# FZF default options with Solarized Dark theme (matching Ghostty)
set -gx FZF_DEFAULT_OPTS "
  --height=40%
  --layout=reverse
  --border=rounded
  --info=inline
  --prompt='❯ '
  --pointer='▶'
  --marker='✓'
  --ansi
  --bind='ctrl-/:toggle-preview'
  --bind='ctrl-u:preview-half-page-up'
  --bind='ctrl-d:preview-half-page-down'
  --bind='ctrl-a:select-all'
  --bind='ctrl-y:execute-silent(echo {+} | pbcopy)'
  --color=bg+:#073642,bg:#002b36,spinner:#2aa198,hl:#268bd2
  --color=fg:#839496,header:#586e75,info:#b58900,pointer:#2aa198
  --color=marker:#859900,fg+:#93a1a1,prompt:#268bd2,hl+:#268bd2
  --color=border:#586e75
"

# Default command - use fd if available, fallback to find
if type -q fd
    set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git --exclude node_modules"
else
    set -gx FZF_DEFAULT_COMMAND "find . -type f -not -path '*/\.git/*' -not -path '*/node_modules/*'"
end

# File preview command - use bat if available
if type -q bat
    set -gx FZF_PREVIEW_FILE_CMD "bat --style=numbers,changes --color=always --line-range :500 {}"
else
    set -gx FZF_PREVIEW_FILE_CMD "cat {}"
end

# Directory preview command - use eza/exa if available
if type -q eza
    set -gx FZF_PREVIEW_DIR_CMD "eza --tree --level=2 --color=always --icons {}"
else if type -q exa
    set -gx FZF_PREVIEW_DIR_CMD "exa --tree --level=2 --color=always --icons {}"
else
    set -gx FZF_PREVIEW_DIR_CMD "ls -la {}"
end

# Ctrl+T options for file selection
set -gx FZF_CTRL_T_OPTS "
  --preview '$FZF_PREVIEW_FILE_CMD'
  --preview-window right:60%:wrap
"

# Alt+C options for directory navigation
set -gx FZF_ALT_C_OPTS "
  --preview '$FZF_PREVIEW_DIR_CMD'
  --preview-window right:50%
"

# Ctrl+R options for command history
set -gx FZF_CTRL_R_OPTS "
  --preview 'echo {}'
  --preview-window down:3:wrap
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --header 'Press CTRL-Y to copy command'
"
