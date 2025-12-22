# FZF Helper Functions for Solarized Osaka theme
# Loaded at shell startup, available to all fzf_* functions

# ─────────────────────────────────────────────────────────────
# _fzf_opts - Returns common fzf options as a list
# Usage: set -l opts (_fzf_opts)
# ─────────────────────────────────────────────────────────────
function _fzf_opts --description "Get common fzf options with Solarized Osaka theme"
    # Solarized Osaka color palette:
    #   base03: #002b36 (bg)        base02: #073642 (bg_highlight)
    #   base01: #586e75 (comment)   base0:  #839496 (fg)
    #   base1:  #93a1a1 (fg_bright)
    #   cyan:   #2aa198  green:  #859900  yellow: #b58900
    #   blue:   #268bd2  violet: #6c71c4  orange: #cb4b16

    printf '%s\n' \
        --ansi \
        --border=rounded \
        --border-label-pos=3 \
        --padding=1,2 \
        "--prompt=  " \
        "--pointer= " \
        "--marker=󰄴 " \
        --info=inline-right \
        "--separator=─" \
        "--scrollbar=│" \
        --header-first \
        --bind=ctrl-/:toggle-preview \
        --bind=tab:toggle+down \
        --bind=shift-tab:toggle+up \
        --color=fg:#839496,fg+:#2aa198:bold,bg:-1,bg+:#073642,selected-bg:#073642,selected-fg:#859900 \
        --color=hl:#268bd2,hl+:#268bd2,info:#586e75,border:#073642 \
        --color=prompt:#2aa198,pointer:#859900,marker:#859900:bold,spinner:#6c71c4 \
        --color=header:#586e75,gutter:-1,query:#93a1a1,label:#cb4b16
end

# ─────────────────────────────────────────────────────────────
# _fzf_run - Run fzf or fzf-tmux based on environment
# Usage: ... | _fzf_run [popup_size] [extra_opts...]
# Example: fd | _fzf_run "85%,70%" --preview "bat {}"
# ─────────────────────────────────────────────────────────────
function _fzf_run --description "Run fzf or fzf-tmux with Solarized Osaka theme"
    set -l popup_size "85%,70%"
    if test (count $argv) -gt 0
        set popup_size $argv[1]
        set -e argv[1]
    end

    if test -n "$TMUX"
        fzf-tmux -p $popup_size (_fzf_opts) $argv
    else
        fzf --height=70% (_fzf_opts) $argv
    end
end
