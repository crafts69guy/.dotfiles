# FZF Directory Navigation
# Theme: Solarized Osaka | Tmux popup support
# Uses: fd, eza
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

function fzf_directories --description "Search directories with fzf and cd"
    set -l preview_cmd
    if type -q eza
        set preview_cmd "eza --tree --level=2 --color=always --icons {}"
    else if type -q exa
        set preview_cmd "exa --tree --level=2 --color=always --icons {}"
    else
        set preview_cmd "ls -la {}"
    end

    set -l search_cmd
    if type -q fd
        set search_cmd "fd --type d --strip-cwd-prefix --hidden --follow --exclude .git"
    else
        set search_cmd "find . -type d -not -path '*/\.git/*'"
    end

    set -l selected (eval $search_cmd | _fzf_run "85%,70%" \
        --border-label=" 󰉋 Directories " \
        --preview "$preview_cmd" \
        --preview-window "right:50%:border-rounded" \
        --preview-label=" 󰙅 Tree " \
        --header="  ⌨  ctrl-/ preview │ enter cd │ esc cancel")

    if test -n "$selected"
        cd "$selected"
        commandline -f repaint
    end
end
