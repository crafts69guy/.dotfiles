# FZF Command History
# Theme: Solarized Osaka | Tmux popup support
# Sort by frequency, unique commands only
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

function fzf_history --description "Search command history with fzf (sorted by frequency)"
    # Build frequency-sorted unique command list
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

    set -l selected (printf '%s\n' $history_list | _fzf_run "85%,70%" \
        --no-sort \
        --scheme=history \
        --border-label=" 󰋚 Command History " \
        --preview 'echo {} | sed "s/^[[:space:]]*[0-9]*×[[:space:]]*//" | bat --style=numbers,grid --color=always --language=bash --line-range=:100 2>/dev/null || echo {} | sed "s/^[[:space:]]*[0-9]*×[[:space:]]*//"' \
        --preview-window "down:6:wrap:border-rounded" \
        --preview-label=" 󰈮 Preview " \
        --header="  ⌨  ctrl-y copy │ enter execute │ esc cancel" \
        --bind 'ctrl-y:execute-silent(echo {} | sed "s/^[[:space:]]*[0-9]*×[[:space:]]*//" | pbcopy)+abort')

    if test -n "$selected"
        set -l cmd (echo $selected | sed 's/^[[:space:]]*[0-9]*×[[:space:]]*//')
        commandline -r "$cmd"
        commandline -f repaint
    end
end
