# Fuzzy find and kill processes
# Based on fzf best practices for process management
function fzf_processes --description "Interactive process viewer and killer"
    # Get processes with ps, format with columns
    # Show: PID, %CPU, %MEM, USER, COMMAND
    set -l selected (ps -eo pid,%cpu,%mem,user,comm | \
        sed 1d | \
        fzf \
            --multi \
            --ansi \
            --header 'TAB: select multiple | ENTER: kill selected | ESC: cancel' \
            --preview 'ps -p {1} -o pid,ppid,user,%cpu,%mem,start,time,command | tail -n +2' \
            --preview-window 'right:50%:wrap' \
            --bind 'ctrl-r:reload(ps -eo pid,%cpu,%mem,user,comm | sed 1d)' \
            --bind 'ctrl-/:toggle-preview' \
            --header-lines=0)

    if test -n "$selected"
        # Extract PIDs from selected lines
        set -l pids (echo "$selected" | awk '{print $1}')

        if test (count $pids) -gt 0
            echo "Selected processes:"
            for pid in $pids
                ps -p $pid -o pid,user,comm | tail -n +2
            end

            # Confirm before killing
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
