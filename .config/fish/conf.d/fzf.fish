# FZF Configuration for Fish Shell
# Based on official fzf documentation: https://github.com/junegunn/fzf
# Optimized for fd, ripgrep, bat integration

# Solarized Osaka color palette (from craftzdog/solarized-osaka.nvim)
# Base colors:
#   base03: #002b36 (bg)        base02: #073642 (bg_highlight)
#   base01: #586e75 (comment)   base00: #657b83
#   base0:  #839496 (fg)        base1:  #93a1a1 (fg_bright)
# Accent colors:
#   yellow: #b58900  orange: #cb4b16  red:     #dc322f
#   magenta:#d33682  violet: #6c71c4  blue:    #268bd2
#   cyan:   #2aa198  green:  #859900

set -gx FZF_DEFAULT_OPTS "
  --height=40%
  --layout=reverse
  --border=rounded
  --info=inline-right
  --prompt='  '
  --pointer=' '
  --marker=' '
  --separator='─'
  --scrollbar='│'
  --ansi
  --bind='ctrl-/:toggle-preview'
  --bind='ctrl-u:preview-half-page-up'
  --bind='ctrl-d:preview-half-page-down'
  --bind='ctrl-a:select-all'
  --bind='ctrl-y:execute-silent(echo {+} | pbcopy)'
  --color=bg+:#073642,bg:-1,spinner:#6c71c4,hl:#268bd2
  --color=fg:#839496,header:#586e75,info:#586e75,pointer:#859900
  --color=marker:#b58900,fg+:#93a1a1,prompt:#2aa198,hl+:#268bd2
  --color=border:#073642,label:#cb4b16,query:#93a1a1
  --color=gutter:-1,separator:#073642,scrollbar:#073642
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
