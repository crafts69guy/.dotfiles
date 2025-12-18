# FZF Process Management
# Theme: Solarized Osaka | Tmux popup support
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

# ─────────────────────────────────────────────────────────────
# fzf_processes - Interactive process viewer with confirmation
# ─────────────────────────────────────────────────────────────
function fzf_processes --description "Interactive process viewer and killer"
    set -l selected (ps -eo pid,%cpu,%mem,user,comm | sed 1d | \
        _fzf_run "85%,70%" \
            --multi \
            --border-label=" 󰓛 Processes " \
            --preview 'ps -p {1} -o pid,ppid,user,%cpu,%mem,stat,start,command 2>/dev/null | tail -n +2' \
            --preview-window "right:50%:border-rounded:wrap" \
            --preview-label=" 󰈮 Details " \
            --header="  ⌨  tab multi-select │ ctrl-r refresh │ enter kill" \
            --bind 'ctrl-r:reload(ps -eo pid,%cpu,%mem,user,comm | sed 1d)')

    if test -n "$selected"
        set -l pids (echo "$selected" | awk '{print $1}')

        if test (count $pids) -gt 0
            echo "Selected processes:"
            for pid in $pids
                ps -p $pid -o pid,user,comm 2>/dev/null | tail -n +2
            end

            read -l -P "Kill these processes? [y/N] " confirm
            switch $confirm
                case Y y
                    for pid in $pids
                        echo "Killing process $pid..."
                        kill $pid
                    end
                    echo "Done!"
                case '*'
                    echo "Cancelled"
            end
        end
        commandline -f repaint
    end
end

# ─────────────────────────────────────────────────────────────
# fzf_kill - Quick process killer (no confirmation)
# Usage: fzf_kill [-9]
# ─────────────────────────────────────────────────────────────
function fzf_kill --description "Quick kill process with fzf (force kill with -9)"
    set -l force_kill 0
    if test (count $argv) -gt 0; and test "$argv[1]" = "-9"
        set force_kill 1
    end

    set -l selected (ps aux | sed 1d | \
        _fzf_run "90%,70%" \
            --multi \
            --border-label=" 󰚌 Kill Process " \
            --preview 'echo {2} | xargs ps -p -o pid,ppid,user,%cpu,%mem,stat,start,command 2>/dev/null | tail -n +2' \
            --preview-window "down:40%:border-rounded:wrap" \
            --preview-label=" 󰈮 Details " \
            --header="  ⌨  tab multi-select │ ctrl-r refresh │ enter kill" \
            --bind 'ctrl-r:reload(ps aux | sed 1d)')

    if test -n "$selected"
        set -l pids (echo "$selected" | awk '{print $2}')

        if test (count $pids) -gt 0
            for pid in $pids
                if test $force_kill -eq 1
                    echo "Force killing process $pid (SIGKILL)..."
                    kill -9 $pid
                else
                    echo "Killing process $pid (SIGTERM)..."
                    kill $pid
                end
            end
        end
        commandline -f repaint
    end
end

# ─────────────────────────────────────────────────────────────
# fzf_ports - Find and kill processes by port
# ─────────────────────────────────────────────────────────────
function fzf_ports --description "Find processes listening on ports and kill them"
    if not type -q lsof
        echo "lsof is not available"
        return 1
    end

    set -l selected (lsof -iTCP -sTCP:LISTEN -n -P | sed 1d | \
        _fzf_run "90%,70%" \
            --multi \
            --border-label=" 󰒍 Ports " \
            --preview 'echo {2} | xargs ps -p -o pid,user,%cpu,%mem,command 2>/dev/null | tail -n +2' \
            --preview-window "down:40%:border-rounded:wrap" \
            --preview-label=" 󰈮 Process " \
            --header="  ⌨  tab multi-select │ ctrl-r refresh │ enter kill" \
            --bind 'ctrl-r:reload(lsof -iTCP -sTCP:LISTEN -n -P | sed 1d)')

    if test -n "$selected"
        set -l pids (echo "$selected" | awk '{print $2}' | sort -u)

        if test (count $pids) -gt 0
            echo "Processes using selected ports:"
            for pid in $pids
                lsof -p $pid 2>/dev/null | head -n 2
            end

            read -l -P "Kill these processes? [y/N] " confirm
            switch $confirm
                case Y y
                    for pid in $pids
                        echo "Killing process $pid..."
                        kill $pid
                    end
                    echo "Done!"
                case '*'
                    echo "Cancelled"
            end
        end
        commandline -f repaint
    end
end
