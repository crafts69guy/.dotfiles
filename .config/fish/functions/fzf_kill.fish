# FZF Quick Process Killer
# Theme: Solarized Osaka | Tmux popup support
# Usage: fzf_kill [-9]
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

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
