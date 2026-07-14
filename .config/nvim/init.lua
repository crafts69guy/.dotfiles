if vim.loader then
	vim.loader.enable()
end

_G.dd = function(...)
	require("util.debug").dump(...)
end
vim.print = _G.dd

local profile = require("config.profile")
profile.setup_command()
require("config.lazy")

if profile.needs_selection() and #vim.api.nvim_list_uis() > 0 then
	vim.schedule(function()
		profile.select(function()
			profile.restart()
		end)
	end)
end
