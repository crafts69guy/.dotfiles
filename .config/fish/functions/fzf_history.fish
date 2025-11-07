# Fuzzy find command history and execute
function fzf_history --description "Search command history with fzf"
    set -l selected_cmd (history | fzf \
        --tac \
        --no-sort \
        --preview 'echo {}' \
        --preview-window down:3:wrap \
        --header "Select command from history (Ctrl-Y to copy)" \
        --bind 'ctrl-y:execute-silent(echo {} | pbcopy)+abort')

    if test -n "$selected_cmd"
        commandline -r "$selected_cmd"
        commandline -f repaint
    end
end
