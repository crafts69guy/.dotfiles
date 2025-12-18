# FZF Git Log Browser
# Theme: Solarized Osaka | Tmux popup support
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

function fzf_git_log --description "Search git commits with fzf"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Not in a git repository"
        return 1
    end

    set -l selected (git log --oneline --color=always --decorate | \
        _fzf_run "90%,80%" \
            --no-sort \
            --border-label=" 󰜘 Git Log " \
            --preview 'git show --color=always (echo {} | awk \'{print $1}\')' \
            --preview-window "right:60%:border-rounded:wrap" \
            --preview-label=" 󰈮 Commit " \
            --header="  ⌨  ctrl-y copy hash │ enter show │ esc cancel" \
            --bind 'ctrl-y:execute-silent(echo {} | awk \'{print $1}\' | pbcopy)')

    if test -n "$selected"
        set -l hash (echo $selected | awk '{print $1}')
        git show $hash
        commandline -f repaint
    end
end
