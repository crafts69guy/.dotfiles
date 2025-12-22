function fzf_tmux_new_session --description "Create and switch to a new tmux session"
    if not type -q tmux
        echo "tmux not found"
        return 1
    end

    # Get existing sessions for reference
    set -l existing (tmux list-sessions -F "#{session_name}" 2>/dev/null | string join ", ")

    # Use fzf's --print-query to get input (minimal height)
    set -l session_name (printf "" | _fzf_run "40%,7" \
        --border-label="  New Session " \
        --header="$existing" \
        --prompt=" " \
        --print-query \
        --pointer="" \
        --no-info \
        --no-separator \
        --padding=0,1)

    if test -n "$session_name"
        # Check if session already exists
        if tmux has-session -t "$session_name" 2>/dev/null
            echo "Session '$session_name' already exists, switching..."
            if test -n "$TMUX"
                tmux switch-client -t "$session_name"
            else
                tmux attach-session -t "$session_name"
            end
        else
            # Create and switch to new session
            if test -n "$TMUX"
                tmux new-session -d -s "$session_name"
                tmux switch-client -t "$session_name"
            else
                tmux new-session -s "$session_name"
            end
        end
        commandline -f repaint
    end
end
