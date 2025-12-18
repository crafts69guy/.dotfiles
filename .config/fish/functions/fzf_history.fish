# Fuzzy find command history and execute
# Sort by frequency (most used first), unique commands only
# Optimized for tmux environment with pretty UI
function fzf_history --description "Search command history with fzf (sorted by frequency)"
    # Build frequency-sorted list with colored count prefix
    # Sort numerically first (by count), then add colors for display
    set -l history_list (history | awk '
        {count[$0]++}
        END {
            for(cmd in count) {
                printf "%06d %s\n", count[cmd], cmd
            }
        }
    ' | sort -rn | awk '{
        count = int($1)
        $1 = ""
        sub(/^ /, "", $0)
        printf "\033[36m%4d×\033[0m  %s\n", count, $0
    }')

    # Common fzf options with improved UI
    set -l fzf_opts \
        --ansi \
        --no-sort \
        --scheme=history \
        --border=rounded \
        --border-label=" 󰋚 Command History " \
        --border-label-pos=3 \
        --prompt="  " \
        --pointer="▶" \
        --marker="✓" \
        --preview 'echo {} | sed "s/^[[:space:]]*[0-9]*×[[:space:]]*//" | bat --style=plain --color=always --language=bash 2>/dev/null || echo {} | sed "s/^[[:space:]]*[0-9]*×[[:space:]]*//"' \
        --preview-window=down:4:wrap:border-rounded \
        --preview-label=" Preview " \
        --header="
  Ctrl-Y: copy │ Enter: execute │ Esc: cancel
" \
        --header-first \
        --bind 'ctrl-y:execute-silent(echo {} | sed "s/^[[:space:]]*[0-9]*×[[:space:]]*//" | pbcopy)+abort'

    # Use fzf-tmux popup if inside tmux, otherwise regular fzf
    set -l selected
    if test -n "$TMUX"
        set selected (printf '%s\n' $history_list | fzf-tmux -p 85%,70% $fzf_opts)
    else
        set selected (printf '%s\n' $history_list | fzf --height=70% $fzf_opts)
    end

    # Extract command (remove count prefix) and execute
    if test -n "$selected"
        set -l cmd (echo $selected | sed 's/^[[:space:]]*[0-9]*×[[:space:]]*//')
        commandline -r "$cmd"
        commandline -f repaint
    end
end
