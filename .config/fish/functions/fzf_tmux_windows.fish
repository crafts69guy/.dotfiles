# FZF Tmux Window Switcher
# Theme: Solarized Osaka | Tmux popup support
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)
# Keys: enter=switch | ctrl-x=kill | ctrl-o=kill others

function fzf_tmux_windows --description "Search tmux windows with fzf and switch"
    if not type -q tmux
        echo "tmux not found"
        return 1
    end

    if test -z "$TMUX"
        echo "Not inside tmux"
        return 1
    end

    set -l current_window (tmux display-message -p '#{session_name}:#{window_index}')

    set -l result (tmux list-windows -a -F "#{session_name}:#{window_index} │ #{window_name} │ #{pane_current_command}" | \
        _fzf_run "80%,60%" \
            --multi \
            --border-label="  Tmux Windows " \
            --preview 'tmux capture-pane -ep -t (echo {} | cut -d" " -f1) 2>/dev/null || echo "No preview available"' \
            --preview-window "right:55%:border-rounded" \
            --preview-label=" 󰨇 Pane " \
            --header="  ⌨  enter switch │ ctrl-x kill │ ctrl-o kill others │ esc cancel" \
            --expect=ctrl-x,ctrl-o)

    set -l key $result[1]
    set -l selected (printf '%s\n' $result[2..] | awk '{print $1}')

    if test -z "$selected"
        return
    end

    switch $key
        case ctrl-o
            # Kill all other windows
            set -l other_windows (tmux list-windows -a -F "#{session_name}:#{window_index}" | grep -v "^$current_window\$")
            if test -z "$other_windows"
                echo "No other windows to kill"
                return 0
            end
            set -l count (count $other_windows)
            echo "Killing $count other window(s)..."
            for window in $other_windows
                echo "  Killed: $window"
                tmux kill-window -t "$window"
            end

        case ctrl-x
            # Kill selected windows
            for window in $selected
                if test "$window" = "$current_window"
                    echo "Skipping current window: $window"
                    continue
                end
                echo "Killing window: $window"
                tmux kill-window -t "$window"
            end

        case '*'
            # Default: switch to window
            tmux switch-client -t "$selected[1]"
    end

    commandline -f repaint
end
