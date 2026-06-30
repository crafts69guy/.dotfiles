function hue-theme -d "Switch the Hue theme across shell, tmux, Ghostty, and Neovim"
    set -l mood $argv[1]

    set -l state_home $HOME/.local/state
    if set -q XDG_STATE_HOME
        set state_home $XDG_STATE_HOME
    end

    set -l state_dir "$state_home/hue-theme"
    set -l state_file "$state_dir/current"

    if test -z "$mood"
        if test -f $state_file
            set mood (string trim -- (cat $state_file))
        else
            set mood mua
        end
        echo $mood
        return 0
    end

    if not contains -- $mood mua huong cung
        echo "usage: hue-theme <mua|huong|cung>" >&2
        return 2
    end

    mkdir -p $state_dir
    printf "%s\n" $mood >$state_file
    printf "set -g @hue_flavour '%s'\n" $mood >"$state_dir/tmux.conf"

    set -g hue_flavour $mood
    __hue_theme_apply_tide $mood
    __hue_theme_apply_tmux $mood
    __hue_theme_apply_ghostty $mood
    __hue_theme_apply_nvim $mood

    echo "hue-theme: switched to $mood"
end

function __hue_theme_apply_tide --argument-names mood
    set -l hue_theme_candidates
    if set -q HUE_THEME_HOME
        set -a hue_theme_candidates $HUE_THEME_HOME
    end

    set -a hue_theme_candidates \
        $HOME/Developments/github.com/crafts69guy/hue-theme \
        $HOME/.local/share/hue-theme \
        $HOME/.config/hue-theme

    for hue_theme_home in $hue_theme_candidates
        set -l hue_tide_entry "$hue_theme_home/packages/fish-themes/tide/hue.fish"
        if test -f $hue_tide_entry
            source $hue_tide_entry
            command -q tide; and tide reload >/dev/null 2>&1
            return 0
        end
    end

    echo "hue-theme: Tide entrypoint not found; set HUE_THEME_HOME" >&2
    return 1
end

function __hue_theme_apply_tmux --argument-names mood
    command -q tmux; or return 0
    tmux set-option -gq @hue_flavour $mood 2>/dev/null; or return 0

    set -l hue_tmux_theme "$HOME/.config/tmux/plugins/hue-tmux/themes/hue-$mood.conf"
    if test -f $hue_tmux_theme
        tmux source-file $hue_tmux_theme
    end
end

function __hue_theme_apply_ghostty --argument-names mood
    set -l ghostty_theme_dir "$HOME/.config/ghostty/themes"
    set -l ghostty_theme_file "$ghostty_theme_dir/hue-$mood"
    test -f $ghostty_theme_file; or return 0

    ln -sf "hue-$mood" "$ghostty_theme_dir/hue-current"

    if command -q ghostty
        ghostty +reload-config >/dev/null 2>&1 &
    end
end

function __hue_theme_apply_nvim --argument-names mood
    set -l scheme "hue-$mood"

    if command -q nvr; and set -q NVIM_LISTEN_ADDRESS
        nvr --server $NVIM_LISTEN_ADDRESS --remote-send "<Esc>:colorscheme $scheme<CR>" >/dev/null 2>&1
    end
end
