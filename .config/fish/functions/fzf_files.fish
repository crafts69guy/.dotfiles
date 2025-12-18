# FZF File Navigation
# Theme: Solarized Osaka | Tmux popup support
# Uses: fd, bat
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

function fzf_files --description "Search files with fzf and open in editor"
    set -l preview_cmd
    if type -q bat
        set preview_cmd "bat --color=always --style=numbers,changes --line-range :500 {}"
    else
        set preview_cmd "cat {}"
    end

    set -l search_cmd
    if type -q fd
        set search_cmd "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git"
    else
        set search_cmd "find . -type f -not -path '*/\.git/*'"
    end

    set -l selected (eval $search_cmd | _fzf_run "85%,70%" \
        --border-label=" 󰈔 Files " \
        --preview "$preview_cmd" \
        --preview-window "right:55%:border-rounded" \
        --preview-label=" 󰈮 Preview " \
        --header="  ⌨  ctrl-/ preview │ enter open │ esc cancel")

    if test -n "$selected"
        $EDITOR "$selected"
        commandline -f repaint
    end
end
