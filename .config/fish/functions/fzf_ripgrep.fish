# Interactive ripgrep search with fzf
# Based on: https://github.com/junegunn/fzf/blob/master/ADVANCED.md
function fzf_ripgrep --description "Interactive ripgrep search with live reload"
    # Check if ripgrep is available
    if not type -q rg
        echo "ripgrep (rg) is not installed. Install with: brew install ripgrep"
        return 1
    end

    # Use bat for preview if available
    if type -q bat
        set preview_cmd "bat --color=always --style=numbers,changes --highlight-line {2} {1}"
    else
        set preview_cmd "cat {1}"
    end

    # Initial query from arguments or empty
    set initial_query "$argv"

    # RG_PREFIX: ripgrep command with common options
    set RG_PREFIX "rg --column --line-number --no-heading --color=always --smart-case"

    # Interactive search with reload on query change
    set selected (
        FZF_DEFAULT_COMMAND="$RG_PREFIX '$initial_query'" fzf \
            --ansi \
            --disabled \
            --query "$initial_query" \
            --bind "start:reload:$RG_PREFIX {q}" \
            --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
            --delimiter : \
            --preview "$preview_cmd" \
            --preview-window "right:60%:wrap:+{2}+3/3:~3" \
            --bind 'ctrl-/:toggle-preview' \
            --bind 'ctrl-y:execute-silent(echo {1}:{2} | pbcopy)' \
            --header 'CTRL-/: toggle preview | CTRL-Y: copy location' \
            --color "hl:-1:underline,hl+:-1:underline:reverse"
    )

    # Open selected file in editor at the line number
    if test -n "$selected"
        set file (echo $selected | cut -d: -f1)
        set line (echo $selected | cut -d: -f2)

        if test -n "$line"
            # Open in editor at specific line
            $EDITOR "+$line" "$file"
        else
            $EDITOR "$file"
        end
        commandline -f repaint
    end
end
