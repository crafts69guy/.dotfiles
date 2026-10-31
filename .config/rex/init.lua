-- Rex configuration. Reload with `rex config reload`; validate with `rex config check`.
-- Docs: https://www.superlogical.com/rex/docs/customize/config

-- Hue theme: registers hue_mua / hue_huong / hue_cung. hue.lua and hue-watch.lua
-- are generated in crafts69guy/hue-theme; update them with .scripts/sync-hue-rex.sh.
-- The launchd agent from .scripts/hue-rex-agent.sh themes terminals opened later.
require("hue")

rex.bind("ctrl+cmd+1", "hue_mua")
rex.bind("ctrl+cmd+2", "hue_huong")
rex.bind("ctrl+cmd+3", "hue_cung")
