# Simple ripgrep + fzf search (two-phase filtering)
# Based on: https://github.com/junegunn/fzf/blob/master/ADVANCED.md
function fzf_rg_simple --description "Search with ripgrep and filter with fzf"
    # Check if ripgrep is available
    if not type -q rg
        echo "ripgrep (rg) is not installed. Install with: brew install ripgrep"
        return 1
    end

    # Require search query
    if test (count $argv) -eq 0
        echo "Usage: fzf_rg_simple <search_pattern>"
        return 1
    end

    # Use bat for preview if available
    if type -q bat
        set preview_cmd "bat --color=always --style=numbers,changes --highlight-line {2} {1}"
    else
        set preview_cmd "cat {1}"
    end

    # Two-phase filtering: rg first, then fzf
    set selected (
        rg --color=always --line-number --no-heading --smart-case $argv | \
        fzf --ansi \
            --color "hl:-1:underline,hl+:-1:underline:reverse" \
            --delimiter : \
            --preview "$preview_cmd" \
            --preview-window "right:60%:border-left:+{2}+3/3:~3" \
            --bind 'ctrl-/:toggle-preview' \
            --bind 'ctrl-y:execute-silent(echo {1}:{2} | pbcopy)' \
            --header 'CTRL-/: toggle preview | CTRL-Y: copy location'
    )

    # Open selected file in editor at the line number
    if test -n "$selected"
        set file (echo $selected | cut -d: -f1)
        set line (echo $selected | cut -d: -f2)

        if test -n "$line"
            $EDITOR "+$line" "$file"
        else
            $EDITOR "$file"
        end
        commandline -f repaint
    end
end
