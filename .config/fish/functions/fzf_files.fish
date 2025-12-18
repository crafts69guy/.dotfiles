# FZF File & Directory Navigation
# Theme: Solarized Osaka | Tmux popup support
# Uses: fd, bat, eza
# Helpers: _fzf_run (from conf.d/fzf_helpers.fish)

# ─────────────────────────────────────────────────────────────
# fzf_files - Fuzzy find files and open in editor
# ─────────────────────────────────────────────────────────────
function fzf_files --description "Search files with fzf and open in editor"
    set -l preview_cmd
    if type -q bat
        set preview_cmd "bat --color=always --style=numbers,changes --line-range :500 {}"
    else
        set preview_cmd "cat {}"
    end

    set -l search_cmd
    if type -q fd
        set search_cmd "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git"
    else
        set search_cmd "find . -type f -not -path '*/\.git/*'"
    end

    set -l selected (eval $search_cmd | _fzf_run "85%,70%" \
        --border-label=" 󰈔 Files " \
        --preview "$preview_cmd" \
        --preview-window "right:55%:border-rounded" \
        --preview-label=" 󰈮 Preview " \
        --header="  ⌨  ctrl-/ preview │ enter open │ esc cancel")

    if test -n "$selected"
        $EDITOR "$selected"
        commandline -f repaint
    end
end

# ─────────────────────────────────────────────────────────────
# fzf_directories - Fuzzy find directories and cd
# ─────────────────────────────────────────────────────────────
function fzf_directories --description "Search directories with fzf and cd"
    set -l preview_cmd
    if type -q eza
        set preview_cmd "eza --tree --level=2 --color=always --icons {}"
    else if type -q exa
        set preview_cmd "exa --tree --level=2 --color=always --icons {}"
    else
        set preview_cmd "ls -la {}"
    end

    set -l search_cmd
    if type -q fd
        set search_cmd "fd --type d --strip-cwd-prefix --hidden --follow --exclude .git"
    else
        set search_cmd "find . -type d -not -path '*/\.git/*'"
    end

    set -l selected (eval $search_cmd | _fzf_run "85%,70%" \
        --border-label=" 󰉋 Directories " \
        --preview "$preview_cmd" \
        --preview-window "right:50%:border-rounded" \
        --preview-label=" 󰙅 Tree " \
        --header="  ⌨  ctrl-/ preview │ enter cd │ esc cancel")

    if test -n "$selected"
        cd "$selected"
        commandline -f repaint
    end
end
