# FZF Ripgrep Two-Phase Search
# Theme: Solarized Osaka | Tmux popup support
# Usage: fzf_rg <pattern>
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

function fzf_rg --description "Search with ripgrep and filter with fzf"
    if not type -q rg
        echo "ripgrep (rg) is not installed. Install with: brew install ripgrep"
        return 1
    end

    if test (count $argv) -eq 0
        echo "Usage: fzf_rg <search_pattern>"
        return 1
    end

    set -l preview_cmd
    if type -q bat
        set preview_cmd "bat --color=always --style=numbers,changes --highlight-line {2} {1} 2>/dev/null || cat {1}"
    else
        set preview_cmd "cat {1}"
    end

    set -l selected (rg --color=always --line-number --no-heading --smart-case $argv | \
        _fzf_run "90%,80%" \
            --delimiter : \
            --border-label=" 󰈬 Search: $argv " \
            --preview "$preview_cmd" \
            --preview-window "right:55%:border-rounded:+{2}+3/3:~3" \
            --preview-label=" 󰈮 Preview " \
            --header="  ⌨  ctrl-/ preview │ ctrl-y copy │ enter open" \
            --bind 'ctrl-y:execute-silent(echo {1}:{2} | pbcopy)' \
            --color="hl:#b58900:underline,hl+:#b58900:underline:reverse")

    if test -n "$selected"
        set -l file (echo $selected | cut -d: -f1)
        set -l line (echo $selected | cut -d: -f2)
        if test -n "$line"
            $EDITOR "+$line" "$file"
        else
            $EDITOR "$file"
        end
        commandline -f repaint
    end
end
