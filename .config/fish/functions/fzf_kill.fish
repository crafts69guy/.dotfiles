# Quick process killer with fzf (no confirmation)
# Alternative to fzf_processes for faster workflow
function fzf_kill --description "Quick kill process with fzf (force kill with -9)"
    set -l force_kill 0

    # Parse arguments
    if test (count $argv) -gt 0; and test "$argv[1]" = "-9"
        set force_kill 1
    end

    # Get process list with more details
    set -l selected (ps aux | \
        sed 1d | \
        fzf \
            --multi \
            --ansi \
            --header 'TAB: multi-select | ENTER: kill (SIGTERM) | Add -9 for SIGKILL' \
            --preview 'echo {2} | xargs ps -p -o pid,ppid,user,%cpu,%mem,vsz,rss,tt,stat,start,time,command' \
            --preview-window 'down:50%:wrap' \
            --bind 'ctrl-r:reload(ps aux | sed 1d)' \
            --bind 'ctrl-/:toggle-preview')

    if test -n "$selected"
        # Extract PIDs (second column in ps aux)
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
