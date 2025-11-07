# Fuzzy find and switch tmux sessions
function fzf_tmux_sessions --description "Search tmux sessions with fzf and switch"
    # Check if tmux is running
    if not type -q tmux
        echo "tmux not found"
        return 1
    end

    # Get list of sessions
    set -l sessions (tmux list-sessions -F "#{session_name}" 2>/dev/null)

    if test -z "$sessions"
        echo "No tmux sessions found"
        return 1
    end

    set -l selected_session (tmux list-sessions -F "#{session_name}: #{session_windows} windows (#{session_created})" | \
        fzf \
            --preview 'tmux capture-pane -ep -t (echo {} | cut -d: -f1)' \
            --preview-window right:60% \
            --header "Select tmux session to switch" | \
        cut -d: -f1)

    if test -n "$selected_session"
        if test -n "$TMUX"
            # If inside tmux, switch to the selected session
            tmux switch-client -t "$selected_session"
        else
            # If outside tmux, attach to the selected session
            tmux attach-session -t "$selected_session"
        end
        commandline -f repaint
    end
end
