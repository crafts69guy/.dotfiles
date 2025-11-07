# Fuzzy find directories and cd
function fzf_directories --description "Search directories with fzf and cd"
    set -l selected_dir

    if type -q fd
        set selected_dir (fd --type d --hidden --follow --exclude .git --exclude node_modules | fzf \
            --preview "$FZF_PREVIEW_DIR_CMD" \
            --preview-window right:50% \
            --header "Select directory to navigate")
    else
        set selected_dir (find . -type d -not -path '*/\.git/*' -not -path '*/node_modules/*' | fzf \
            --preview "$FZF_PREVIEW_DIR_CMD" \
            --preview-window right:50% \
            --header "Select directory to navigate")
    end

    if test -n "$selected_dir"
        cd "$selected_dir"
        commandline -f repaint
    end
end
