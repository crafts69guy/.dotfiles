# FZF Configuration for Fish Shell
# Based on official fzf documentation: https://github.com/junegunn/fzf
# Optimized for fd, ripgrep, bat integration
#
# Colors are derived from herdr's [theme.custom] (kept in sync with the
# active Hue mood by the hue-theme herdr plugin), so fzf follows hue-theme
# without a hardcoded palette. hue-theme.fish calls __hue_fzf_refresh on mood
# switch; the universal variable then updates every running shell.

function __hue_fzf_colors -d "Derive fzf --color from herdr's [theme.custom] (active Hue mood)"
    set -l config $HOME/.config/herdr/config.toml
    if set -q HERDR_CONFIG_PATH
        set config $HERDR_CONFIG_PATH
    end
    test -r "$config"; or return 1

    set -l accent ""
    set -l text ""
    set -l subtext ""
    set -l surface ""
    set -l overlay ""
    set -l green ""
    set -l teal ""
    for line in (awk '
        /^\[theme\.custom\]/ { s = 1; next }
        /^\[/ { s = 0 }
        s && match($0, /"#[0-9a-fA-F]{6}"/) { print $1 "=" substr($0, RSTART + 1, RLENGTH - 2) }
    ' "$config")
        set -l kv (string split -m1 = -- $line)
        switch $kv[1]
            case accent
                set accent $kv[2]
            case text
                set text $kv[2]
            case subtext0
                set subtext $kv[2]
            case surface1
                set surface $kv[2]
            case overlay0
                set overlay $kv[2]
            case green
                set green $kv[2]
            case teal
                set teal $kv[2]
        end
    end
    test -n "$accent" -a -n "$text"; or return 1

    echo "--color=bg:-1,gutter:-1,fg:$text,fg+:$text,bg+:$surface,hl:$accent,hl+:$accent,prompt:$accent,pointer:$accent,marker:$green,spinner:$teal,info:$subtext,header:$subtext,border:$overlay,separator:$overlay,scrollbar:$overlay,label:$accent,query:$text"
end

function __hue_fzf_refresh -d "Rebuild FZF_DEFAULT_OPTS for the active Hue mood"
    set -l colors (__hue_fzf_colors)
    set -l opts "
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
  $colors
"
    # A leftover global (e.g. from the pre-hue config) would shadow the
    # universal variable in this shell.
    set -eg FZF_DEFAULT_OPTS 2>/dev/null
    if test "$FZF_DEFAULT_OPTS" != "$opts"
        set -Ux FZF_DEFAULT_OPTS "$opts"
    end
end

__hue_fzf_refresh

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
