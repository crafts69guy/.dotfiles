# FZF Tmux Session Switcher
# Theme: Solarized Osaka | Tmux popup support
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)
# Keys: enter=switch | ctrl-x=kill | ctrl-o=kill others

function fzf_tmux_sessions --description "Search tmux sessions with fzf and switch"
    if not type -q tmux
        echo "tmux not found"
        return 1
    end

    set -l sessions (tmux list-sessions -F "#{session_name}" 2>/dev/null)
    if test -z "$sessions"
        echo "No tmux sessions found"
        return 1
    end

    set -l current_session ""
    if test -n "$TMUX"
        set current_session (tmux display-message -p '#{session_name}')
    end

    set -l result (tmux list-sessions -F "#{session_name}: #{session_windows} windows │ #{session_attached} attached" | \
        _fzf_run "80%,60%" \
            --multi \
            --border-label="  Tmux Sessions " \
            --preview 'tmux capture-pane -ep -t (echo {} | cut -d: -f1) 2>/dev/null || echo "No preview available"' \
            --preview-window "right:55%:border-rounded" \
            --preview-label=" 󰨇 Pane " \
            --header="  ⌨  enter switch │ ctrl-x kill │ ctrl-o kill others │ esc cancel" \
            --expect=ctrl-x,ctrl-o)

    set -l key $result[1]
    set -l selected (printf '%s\n' $result[2..] | cut -d: -f1 | string trim)

    if test -z "$selected"
        return
    end

    switch $key
        case ctrl-o
            # Kill all other sessions
            set -l other_sessions (tmux list-sessions -F "#{session_name}" | grep -v "^$current_session\$")
            if test -z "$other_sessions"
                echo "No other sessions to kill"
                return 0
            end
            set -l count (count $other_sessions)
            echo "Killing $count other session(s)..."
            for session in $other_sessions
                echo "  Killed: $session"
                tmux kill-session -t "$session"
            end

        case ctrl-x
            # Kill selected sessions
            for session in $selected
                if test "$session" = "$current_session"
                    echo "Skipping current session: $session"
                    continue
                end
                echo "Killing session: $session"
                tmux kill-session -t "$session"
            end

        case '*'
            # Default: switch to session
            if test -n "$TMUX"
                tmux switch-client -t "$selected[1]"
            else
                tmux attach-session -t "$selected[1]"
            end
    end

    commandline -f repaint
end
