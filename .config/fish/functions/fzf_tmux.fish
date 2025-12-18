# FZF Tmux Integration
# Theme: Solarized Osaka | Tmux popup support
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

# ─────────────────────────────────────────────────────────────
# fzf_tmux_sessions - Fuzzy find and switch tmux sessions
# ─────────────────────────────────────────────────────────────
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

# ─────────────────────────────────────────────────────────────
# fzf_tmux_windows - Fuzzy find and switch tmux windows
# ─────────────────────────────────────────────────────────────
function fzf_tmux_windows --description "Search tmux windows with fzf and switch"
    if not type -q tmux
        echo "tmux not found"
        return 1
    end

    if test -z "$TMUX"
        echo "Not inside tmux"
        return 1
    end

    set -l selected (tmux list-windows -a -F "#{session_name}:#{window_index} │ #{window_name} │ #{pane_current_command}" | \
        _fzf_run "80%,60%" \
            --border-label="  Tmux Windows " \
            --preview 'tmux capture-pane -ep -t (echo {} | cut -d" " -f1) 2>/dev/null || echo "No preview available"' \
            --preview-window "right:55%:border-rounded" \
            --preview-label=" 󰨇 Pane " \
            --header="  ⌨  enter switch │ esc cancel" | \
        awk '{print $1}')

    if test -n "$selected"
        tmux switch-client -t "$selected"
        commandline -f repaint
    end
end
