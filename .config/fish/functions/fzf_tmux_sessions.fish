# FZF Tmux Session Switcher
# Theme: Solarized Osaka | Tmux popup support
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

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

    set -l selected (tmux list-sessions -F "#{session_name}: #{session_windows} windows" | \
        _fzf_run "80%,60%" \
            --border-label="  Tmux Sessions " \
            --preview 'tmux capture-pane -ep -t (echo {} | cut -d: -f1) 2>/dev/null || echo "No preview available"' \
            --preview-window "right:55%:border-rounded" \
            --preview-label=" 󰨇 Pane " \
            --header="  ⌨  enter switch │ esc cancel" | \
        cut -d: -f1)

    if test -n "$selected"
        if test -n "$TMUX"
            tmux switch-client -t "$selected"
        else
            tmux attach-session -t "$selected"
        end
        commandline -f repaint
    end
end
