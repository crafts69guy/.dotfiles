# FZF Port Process Finder
# Theme: Solarized Osaka | Tmux popup support
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

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
