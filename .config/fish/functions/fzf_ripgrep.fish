# FZF Ripgrep Integration (Live Reload)
# Theme: Solarized Osaka | Tmux popup support
# Based on: https://junegunn.github.io/fzf/tips/ripgrep-integration/
# Helpers: _fzf_opts (from conf.d/fzf_helpers.fish)

function fzf_ripgrep --description "Interactive ripgrep search with live reload"
    if not type -q rg
        echo "ripgrep (rg) is not installed. Install with: brew install ripgrep"
        return 1
    end

    set -l initial_query "$argv"
    set -l RG_PREFIX "rg --column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git'"

    set -l preview_cmd
    if type -q bat
        set preview_cmd "bat --style=numbers,changes --color=always --highlight-line {2} {1} 2>/dev/null || cat {1}"
    else
        set preview_cmd "cat {1}"
    end

    set -l selected
    if test -n "$TMUX"
        set selected (FZF_DEFAULT_COMMAND="$RG_PREFIX '$initial_query'" fzf-tmux -p 90%,80% \
            (_fzf_opts) \
            --disabled \
            --query "$initial_query" \
            --bind "start:reload:$RG_PREFIX {q} || true" \
            --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
            --delimiter : \
            --border-label="  Ripgrep Search " \
            --preview "$preview_cmd" \
            --preview-window "right:55%:border-rounded:+{2}+3/3:~3" \
            --preview-label=" 󰈮 Preview " \
            --header="  ⌨  live search │ ctrl-y copy │ enter open" \
            --bind 'ctrl-y:execute-silent(echo {1}:{2} | pbcopy)' \
            --color="hl:#b58900:underline,hl+:#b58900:underline:reverse")
    else
        set selected (FZF_DEFAULT_COMMAND="$RG_PREFIX '$initial_query'" fzf --height=80% \
            (_fzf_opts) \
            --disabled \
            --query "$initial_query" \
            --bind "start:reload:$RG_PREFIX {q} || true" \
            --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
            --delimiter : \
            --border-label="  Ripgrep Search " \
            --preview "$preview_cmd" \
            --preview-window "right:55%:border-rounded:+{2}+3/3:~3" \
            --preview-label=" 󰈮 Preview " \
            --header="  ⌨  live search │ ctrl-y copy │ enter open" \
            --bind 'ctrl-y:execute-silent(echo {1}:{2} | pbcopy)' \
            --color="hl:#b58900:underline,hl+:#b58900:underline:reverse")
    end

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
