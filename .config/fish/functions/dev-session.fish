function dev-session --description "Create a new dev tmux session with preset layout"
    set SESSION "dev-"(date +%s)

    tmux new-session -d -s $SESSION -n "node" -c (pwd)
    tmux split-window -t "$SESSION:node" -c (pwd)
    tmux split-window -t "$SESSION:node" -c (pwd)
    tmux split-window -t "$SESSION:node" -c (pwd)
    tmux select-layout -t "$SESSION:node" tiled

    tmux new-window -t $SESSION -n "code" -c (pwd)
    tmux split-window -h -t "$SESSION:code" -c (pwd)
    tmux send-keys -t "$SESSION:code.1" "claude" Enter
    tmux send-keys -t "$SESSION:code.2" "opencode" Enter

    tmux new-window -t $SESSION -n "shell" -c (pwd)
    tmux select-window -t "$SESSION:node"

    if set -q TMUX
        tmux switch-client -t $SESSION
    else
        tmux attach-session -t $SESSION
    end
end
