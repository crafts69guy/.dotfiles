# Fuzzy find files and open in editor
function fzf_files --description "Search files with fzf and open in editor"
    set -l selected_file

    if type -q fd
        set selected_file (fd --type f --hidden --follow --exclude .git --exclude node_modules | fzf \
            --preview "$FZF_PREVIEW_FILE_CMD" \
            --preview-window right:60%:wrap \
            --header "Select file to open in $EDITOR")
    else
        set selected_file (find . -type f -not -path '*/\.git/*' -not -path '*/node_modules/*' | fzf \
            --preview "$FZF_PREVIEW_FILE_CMD" \
            --preview-window right:60%:wrap \
            --header "Select file to open in $EDITOR")
    end

    if test -n "$selected_file"
        $EDITOR "$selected_file"
        commandline -f repaint
    end
end
