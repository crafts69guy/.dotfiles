# FZF Git Branch Navigation
# Theme: Solarized Osaka | Tmux popup support
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

function fzf_git_branches --description "Search git branches with fzf and checkout"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Not in a git repository"
        return 1
    end

    set -l selected (git branch --all --color=always | \
        grep -v HEAD | \
        sed 's/^[* ]*//' | \
        sed 's#^remotes/origin/##' | \
        awk '!seen[$0]++' | \
        _fzf_run "85%,70%" \
            --border-label="  Git Branches " \
            --preview 'git log --color=always --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {} | head -50' \
            --preview-window "right:55%:border-rounded" \
            --preview-label=" 󰜘 Commits " \
            --header="  ⌨  enter checkout │ esc cancel")

    if test -n "$selected"
        git checkout (echo "$selected" | sed 's#^remotes/origin/##')
        commandline -f repaint
    end
end
