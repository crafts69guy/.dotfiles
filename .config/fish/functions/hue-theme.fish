function hue-theme -d "Switch the Hue theme across shell, tmux, Ghostty, Neovim, herdr, and bat"
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
    __hue_theme_apply_herdr $mood
    __hue_theme_apply_bat $mood
    __hue_theme_apply_lazygit $mood

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

function __hue_theme_apply_herdr --argument-names mood
    command -q herdr; or return 0

    # herdr has no scriptable theme API (no CLI/socket command to switch
    # colors) — the "hue-theme" herdr plugin (packages/herdr-plugin in the
    # hue-theme repo) owns the config.toml splice + reload-config; it reads
    # the same $state_file this function just wrote, so this just triggers it.
    herdr plugin action invoke apply-mood --plugin hue-theme >/dev/null 2>&1
end

function __hue_theme_apply_bat --argument-names mood
    command -q bat; or return 0

    # bat reads its theme per invocation, so an exported universal variable is
    # enough — every fish shell picks it up instantly, no reload needed. The
    # hue-<mood> themes must be in `bat cache --build` already (see
    # .scripts/sync-hue-bat.sh); fall back silently if this one is not.
    if bat --list-themes 2>/dev/null | string match -q "hue-$mood"
        set -Ux BAT_THEME "hue-$mood"
    else
        echo "hue-theme: bat theme hue-$mood not cached; run sync-hue-bat.sh" >&2
    end
end

function __hue_theme_apply_lazygit --argument-names mood
    set -l theme_dir "$HOME/.config/lazygit/themes"
    test -f "$theme_dir/hue-$mood.yml"; or return 0

    # lazygit reads config at launch; the hue-current.yml symlink is merged in
    # via LG_CONFIG_FILE (exported by conf.d/00-hue-tide.fish), so re-pointing
    # it themes every subsequent launch. Running instances keep the old mood.
    ln -sf "hue-$mood.yml" "$theme_dir/hue-current.yml"
    set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$theme_dir/hue-current.yml"
end
