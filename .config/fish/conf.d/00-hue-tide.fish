# Apply generated Hue colors to Tide without writing theme values to fish_variables.
set -g hue_flavour mua

set -l hue_theme_candidates
if set -q HUE_THEME_HOME
    set -a hue_theme_candidates $HUE_THEME_HOME
end

set -a hue_theme_candidates \
    $HOME/Developments/github.com/crafts69guy/hue-theme \
    $HOME/.local/share/hue-theme \
    $HOME/.config/hue-theme

set -l hue_tide_loaded false
for hue_theme_home in $hue_theme_candidates
    set -l hue_tide_entry "$hue_theme_home/packages/fish-themes/tide/hue.fish"
    if test -f $hue_tide_entry
        source $hue_tide_entry
        set hue_tide_loaded true
        break
    end
end

if test $hue_tide_loaded != true
    echo "hue-tide: missing theme entrypoint; set HUE_THEME_HOME to your hue-theme checkout" >&2
end
