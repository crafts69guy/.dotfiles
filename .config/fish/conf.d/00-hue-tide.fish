# Apply generated Hue colors to Tide without writing theme values to fish_variables.
set -g hue_flavour mua

set -l hue_tide_entry (dirname (status filename))/../themes/hue/tide/hue.fish
if test -f $hue_tide_entry
    source $hue_tide_entry
else
    echo "hue-tide: missing theme entrypoint at $hue_tide_entry" >&2
end
