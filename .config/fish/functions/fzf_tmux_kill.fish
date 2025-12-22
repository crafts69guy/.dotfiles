# FZF Tmux Session/Pane Killer
# Theme: Solarized Osaka | Tmux popup support
# Usage: fzf_tmux_kill [--panes]
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

function fzf_tmux_kill --description "Kill tmux sessions or panes with fzf"
    if not type -q tmux
        echo "tmux not found"
        return 1
    end

    set -l mode "sessions"
    if test (count $argv) -gt 0; and test "$argv[1]" = "--panes"
        set mode "panes"
    end

    if test "$mode" = "panes"
        _fzf_tmux_kill_panes
    else
        _fzf_tmux_kill_sessions
    end
end

function _fzf_tmux_kill_sessions --description "Kill tmux sessions"
    set -l sessions (tmux list-sessions -F "#{session_name}" 2>/dev/null)
    if test -z "$sessions"
        echo "No tmux sessions found"
        return 1
    end

    set -l current_session ""
    if test -n "$TMUX"
        set current_session (tmux display-message -p '#{session_name}')
    end

    set -l selected (tmux list-sessions -F "#{session_name}: #{session_windows} windows │ #{session_attached} attached" | \
        _fzf_run "80%,60%" \
            --multi \
            --border-label=" 󰆴 Kill Sessions " \
            --preview 'tmux capture-pane -ep -t (echo {} | cut -d: -f1) 2>/dev/null || echo "No preview available"' \
            --preview-window "right:55%:border-rounded" \
            --preview-label=" 󰨇 Pane " \
            --header="  ⌨  tab multi-select │ enter kill │ esc cancel" | \
        cut -d: -f1)

    if test -n "$selected"
        for session in $selected
            set session (string trim $session)
            if test "$session" = "$current_session"
                echo "Skipping current session: $session"
                continue
            end
            echo "Killing session: $session"
            tmux kill-session -t "$session"
        end
        commandline -f repaint
    end
end

function _fzf_tmux_kill_panes --description "Kill tmux panes"
    if test -z "$TMUX"
        echo "Not inside tmux"
        return 1
    end

    set -l panes (tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}" 2>/dev/null)
    if test -z "$panes"
        echo "No tmux panes found"
        return 1
    end

    set -l current_pane (tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}')

    set -l selected (tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index} │ #{pane_current_command} │ #{pane_width}x#{pane_height}" | \
        _fzf_run "80%,60%" \
            --multi \
            --border-label=" 󰆴 Kill Panes " \
            --preview 'tmux capture-pane -ep -t (echo {} | awk "{print \$1}") 2>/dev/null || echo "No preview available"' \
            --preview-window "right:55%:border-rounded" \
            --preview-label=" 󰨇 Pane " \
            --header="  ⌨  tab multi-select │ enter kill │ esc cancel" | \
        awk '{print $1}')

    if test -n "$selected"
        for pane in $selected
            set pane (string trim $pane)
            if test "$pane" = "$current_pane"
                echo "Skipping current pane: $pane"
                continue
            end
            echo "Killing pane: $pane"
            tmux kill-pane -t "$pane"
        end
        commandline -f repaint
    end
end
