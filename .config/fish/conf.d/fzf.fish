# FZF Configuration for Fish Shell
# Based on official fzf documentation: https://github.com/junegunn/fzf
# Optimized for fd, ripgrep, bat integration

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

# FZF_DEFAULT_COMMAND: Primary file search command (using fd)
# Reference: https://github.com/junegunn/fzf#environment-variables
if type -q fd
    set -gx FZF_DEFAULT_COMMAND "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git"
else
    set -gx FZF_DEFAULT_COMMAND "find . -type f -not -path '*/\.git/*'"
end

# FZF_CTRL_T_COMMAND: File picker command (Ctrl+T in terminal)
if type -q fd
    set -gx FZF_CTRL_T_COMMAND "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git"
end

# FZF_ALT_C_COMMAND: Directory picker command (Alt+C in terminal)
if type -q fd
    set -gx FZF_ALT_C_COMMAND "fd --type d --strip-cwd-prefix --hidden --follow --exclude .git"
end

# FZF_CTRL_T_OPTS: Options for file picker with bat preview
if type -q bat
    set -gx FZF_CTRL_T_OPTS "
      --preview 'bat --style=numbers,changes --color=always --line-range :500 {}'
      --preview-window right:60%:wrap
      --bind 'ctrl-/:toggle-preview'
    "
else
    set -gx FZF_CTRL_T_OPTS "
      --preview 'cat {}'
      --preview-window right:60%:wrap
    "
end

# FZF_ALT_C_OPTS: Options for directory picker
if type -q eza
    set -gx FZF_ALT_C_OPTS "
      --preview 'eza --tree --level=2 --color=always --icons {}'
      --preview-window right:50%
    "
else if type -q exa
    set -gx FZF_ALT_C_OPTS "
      --preview 'exa --tree --level=2 --color=always --icons {}'
      --preview-window right:50%
    "
else
    set -gx FZF_ALT_C_OPTS "
      --preview 'ls -la {}'
      --preview-window right:50%
    "
end

# FZF_CTRL_R_OPTS: Options for command history
set -gx FZF_CTRL_R_OPTS "
  --preview 'echo {}'
  --preview-window down:3:wrap
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --header 'Press CTRL-Y to copy command'
"
