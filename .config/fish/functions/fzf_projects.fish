# Fuzzy find and cd to projects using ghq
function fzf_projects --description "Search projects with fzf and cd (using ghq)"
    set -l selected_project

    if type -q ghq
        set selected_project (ghq list | fzf \
            --preview 'eza --tree --level=2 --color=always --icons (ghq root)/{} 2>/dev/null || ls -la (ghq root)/{}' \
            --preview-window right:50% \
            --header "Select project to navigate")

        if test -n "$selected_project"
            cd (ghq root)/"$selected_project"
            commandline -f repaint
        end
    else
        # Fallback to Developments folder or current directory
        if test -d "$HOME/Developments"
            set selected_project (find "$HOME/Developments" -maxdepth 3 -type d -name .git | sed 's/\/\.git$//' | fzf \
                --preview "$FZF_PREVIEW_DIR_CMD" \
                --preview-window right:50% \
                --header "Select project to navigate")

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
