# Fuzzy find directories and cd
# Uses fd as recommended by fzf documentation
function fzf_directories --description "Search directories with fzf and cd"
    set -l selected_dir

    # Use fd for directory search (faster and respects .gitignore)
    if type -q fd
        if type -q eza
            set selected_dir (fd --type d --strip-cwd-prefix --hidden --follow --exclude .git | fzf \
                --preview 'eza --tree --level=2 --color=always --icons {}' \
                --preview-window 'right:50%' \
                --bind 'ctrl-/:toggle-preview' \
                --header "Select directory to navigate")
        else if type -q exa
            set selected_dir (fd --type d --strip-cwd-prefix --hidden --follow --exclude .git | fzf \
                --preview 'exa --tree --level=2 --color=always --icons {}' \
                --preview-window 'right:50%' \
                --header "Select directory to navigate")
        else
            set selected_dir (fd --type d --strip-cwd-prefix --hidden --follow --exclude .git | fzf \
                --preview 'ls -la {}' \
                --preview-window 'right:50%' \
                --header "Select directory to navigate")
        end
    else
        set selected_dir (find . -type d -not -path '*/\.git/*' | fzf \
            --preview 'ls -la {}' \
            --preview-window 'right:50%' \
            --header "Select directory to navigate")
    end

    if test -n "$selected_dir"
        cd "$selected_dir"
        commandline -f repaint
    end
end
