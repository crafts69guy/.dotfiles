# FZF Process Viewer
# Theme: Solarized Osaka | Tmux popup support
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

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
