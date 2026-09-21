-- Thin adapter over the hue-nvim public API.
--
-- Maps the theme's semantic palette (grouped by family) to the short names this
-- config's custom highlights use, and re-exports hue-nvim's color math. The
-- theme is the single source of truth; nothing is duplicated here.

local hue = require("hue")

local M = {}

M.blend = hue.util.blend
M.darken = hue.util.darken
M.lighten = hue.util.lighten

-- Short, flat color names for the active mood (follows :colorscheme changes).
function M.get()
	local c = hue.colors()
	return {
		canvas = c.surface.canvas,
		raised = c.surface.raised,
		selected = c.surface.selected,
		text = c.text.primary,
		subtext = c.text.secondary,
		border = c.border.subtle,
		primary = c.accent.primary,
		secondary = c.accent.secondary,
		success = c.status.success,
		info = c.status.info,
		notice = c.status.notice,
		warning = c.status.warning,
		error = c.status.error,
	}
end

return M
