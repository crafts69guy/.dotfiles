# FZF Project Navigation
# Theme: Solarized Osaka | Tmux popup support
# Uses: ghq, eza
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

function fzf_projects --description "Search projects with fzf and cd (using ghq)"
    set -l preview_cmd
    if type -q eza
        set preview_cmd "eza --tree --level=2 --color=always --icons {}"
    else
        set preview_cmd "ls -la {}"
    end

    set -l selected_project

    if type -q ghq
        set -l ghq_root (ghq root)
        set -l ghq_preview "eza --tree --level=2 --color=always --icons $ghq_root/{} 2>/dev/null || ls -la $ghq_root/{}"

        set selected_project (ghq list | _fzf_run "85%,70%" \
            --border-label="  Projects " \
            --preview "$ghq_preview" \
            --preview-window "right:50%:border-rounded" \
            --preview-label=" 󰙅 Tree " \
            --header="  ⌨  enter cd │ esc cancel")

        if test -n "$selected_project"
            cd "$ghq_root/$selected_project"
            commandline -f repaint
        end
    else
        # Fallback to Developments folder
        if test -d "$HOME/Developments"
            set selected_project (find "$HOME/Developments" -maxdepth 3 -type d -name .git | sed 's/\/\.git$//' | \
                _fzf_run "85%,70%" \
                    --border-label="  Projects " \
                    --preview "$preview_cmd" \
                    --preview-window "right:50%:border-rounded" \
                    --preview-label=" 󰙅 Tree " \
                    --header="  ⌨  enter cd │ esc cancel")

            if test -n "$selected_project"
                cd "$selected_project"
                commandline -f repaint
            end
        else
            echo "ghq not found and ~/Developments does not exist"
            return 1
        end
    end
end
