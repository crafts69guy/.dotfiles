# FZF Git Modified Files
# Theme: Solarized Osaka | Tmux popup support
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

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
