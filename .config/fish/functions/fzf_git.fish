# FZF Git Integration
# Theme: Solarized Osaka | Tmux popup support
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

# ─────────────────────────────────────────────────────────────
# fzf_git_branches - Fuzzy find and checkout git branches
# ─────────────────────────────────────────────────────────────
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

# ─────────────────────────────────────────────────────────────
# fzf_git_files - Fuzzy find git modified files and open
# ─────────────────────────────────────────────────────────────
function fzf_git_files --description "Search git modified files with fzf"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Not in a git repository"
        return 1
    end

    set -l selected (git status --short | \
        _fzf_run "85%,70%" \
            --multi \
            --border-label="  Git Changes " \
            --preview 'git diff --color=always (echo {} | awk \'{print $2}\') 2>/dev/null | head -100 || echo "New file"' \
            --preview-window "right:55%:border-rounded:wrap" \
            --preview-label=" 󰊢 Diff " \
            --header="  ⌨  tab multi-select │ enter open │ esc cancel" | \
        awk '{print $2}')

    if test -n "$selected"
        $EDITOR $selected
        commandline -f repaint
    end
end

# ─────────────────────────────────────────────────────────────
# fzf_git_log - Fuzzy find git commits
# ─────────────────────────────────────────────────────────────
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
