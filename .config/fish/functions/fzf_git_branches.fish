# Fuzzy find and checkout git branches
function fzf_git_branches --description "Search git branches with fzf and checkout"
    # Check if we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Not in a git repository"
        return 1
    end

    set -l selected_branch (git branch --all --color=always | \
        grep -v HEAD | \
        sed 's/^[* ]*//' | \
        sed 's#^remotes/origin/##' | \
        awk '!seen[$0]++' | \
        fzf --ansi \
            --preview 'git log --color=always --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" (echo {} | sed "s#remotes/origin/##") | head -50' \
            --preview-window right:60% \
            --header "Select branch to checkout")

    if test -n "$selected_branch"
        git checkout (echo "$selected_branch" | sed 's#^remotes/origin/##')
        commandline -f repaint
    end
end
