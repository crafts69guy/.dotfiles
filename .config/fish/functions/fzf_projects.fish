# FZF Project Navigation
# Theme: Solarized Osaka | Tmux popup support
# Uses: ghq, eza
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

function fzf_projects --description "Search projects with fzf and cd (using ghq)"
    set -l projects
    if type -q ghq
        set projects (ghq list --full-path); or begin
            echo 'fzf_projects: ghq list --full-path failed' >&2
            return 1
        end
    else if test -d "$HOME/Developments"
        set projects (find "$HOME/Developments" -maxdepth 3 -type d -name .git); or return 1
        set projects (string replace -r '/\.git$' '' -- $projects)
    else
        echo 'fzf_projects: ghq not found and ~/Developments does not exist' >&2
        return 1
    end

    set -l selected_project (string join \n -- $projects | _fzf_run "85%,70%" \
        --border-label="  Projects " \
        --with-shell '/bin/sh -c' \
        --preview '/bin/sh -c \'eza --tree --level=2 --color=always --icons -- "$1" 2>/dev/null || ls -la -- "$1"\' sh {}' \
        --preview-window "right:50%:border-rounded" \
        --preview-label=" 󰙅 Tree " \
        --header="  ⌨  enter cd │ esc cancel")
    switch $status
        case 1 130
            return 0
        case 0
            test -n "$selected_project"; or return 0
        case '*'
            echo 'fzf_projects: project picker failed' >&2
            return 1
    end

    cd -- "$selected_project"; or return 1
    if status is-interactive
        commandline -f repaint
    end
end
