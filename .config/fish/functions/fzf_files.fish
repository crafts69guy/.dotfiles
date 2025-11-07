# Fuzzy find files and open in editor
# Uses fd and bat as recommended by fzf documentation
function fzf_files --description "Search files with fzf and open in editor"
    set -l selected_file

    # Use fd for file search (faster and respects .gitignore)
    if type -q fd
        if type -q bat
            set selected_file (fd --type f --strip-cwd-prefix --hidden --follow --exclude .git | fzf \
                --preview 'bat --color=always --style=numbers,changes --line-range :500 {}' \
                --preview-window 'right:60%:wrap' \
                --bind 'ctrl-/:toggle-preview' \
                --header "Select file to open in $EDITOR")
        else
            set selected_file (fd --type f --strip-cwd-prefix --hidden --follow --exclude .git | fzf \
                --preview 'cat {}' \
                --preview-window 'right:60%:wrap' \
                --header "Select file to open in $EDITOR")
        end
    else
        set selected_file (find . -type f -not -path '*/\.git/*' | fzf \
            --preview 'cat {}' \
            --preview-window 'right:60%:wrap' \
            --header "Select file to open in $EDITOR")
    end

    if test -n "$selected_file"
        $EDITOR "$selected_file"
        commandline -f repaint
    end
end
