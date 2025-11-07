# Fuzzy find git modified files and open in editor
function fzf_git_files --description "Search git modified files with fzf"
    # Check if we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Not in a git repository"
        return 1
    end

    set -l selected_file (git status --short | \
        fzf --ansi \
            --multi \
            --preview 'git diff --color=always (echo {} | awk \'{print $2}\') | head -100' \
            --preview-window right:60%:wrap \
            --header "Select files (TAB to multi-select, ENTER to open)" | \
        awk '{print $2}')

    if test -n "$selected_file"
        $EDITOR $selected_file
        commandline -f repaint
    end
end
