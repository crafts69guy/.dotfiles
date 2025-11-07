# Find and kill processes by port number
# Useful for freeing up ports during development
function fzf_ports --description "Find processes listening on ports and kill them"
    # Check if lsof is available
    if not type -q lsof
        echo "lsof is not available"
        return 1
    end

    # Get all listening ports
    set -l selected (lsof -iTCP -sTCP:LISTEN -n -P | \
        sed 1d | \
        fzf \
            --multi \
            --ansi \
            --header 'Select ports to kill | TAB: multi-select' \
            --preview 'echo {2} | xargs ps -p -o pid,user,command' \
            --preview-window 'down:40%:wrap' \
            --bind 'ctrl-r:reload(lsof -iTCP -sTCP:LISTEN -n -P | sed 1d)' \
            --bind 'ctrl-/:toggle-preview')

    if test -n "$selected"
        # Extract PIDs (second column in lsof output)
        set -l pids (echo "$selected" | awk '{print $2}' | sort -u)

        if test (count $pids) -gt 0
            echo "Processes using selected ports:"
            for pid in $pids
                lsof -p $pid | head -n 2
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
