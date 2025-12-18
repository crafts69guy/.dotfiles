# FZF Tmux Window Switcher
# Theme: Solarized Osaka | Tmux popup support
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

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
