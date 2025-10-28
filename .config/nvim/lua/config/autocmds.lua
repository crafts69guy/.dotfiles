-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	command = "set nopaste",
})

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "json", "jsonc", "markdown" },
	callback = function()
		vim.opt.conceallevel = 0
	end,
})

-- Make floating windows, telescope, and which-key transparent with themed borders
local function set_transparent_floats()
	vim.schedule(function()
		-- Get solarized-osaka colors
		local colors = require("solarized-osaka.colors").default
		local border_color = colors.cyan

		-- Floating windows
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "FloatBorder", { fg = border_color, bg = "NONE" })

		-- Telescope
		vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = border_color, bg = "NONE" })
		vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = border_color, bg = "NONE" })
		vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = border_color, bg = "NONE" })
		vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = border_color, bg = "NONE" })

		-- Which-key
		vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = border_color, bg = "NONE" })
		vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "WhichKeyTitle", { bg = "NONE" })

		-- Sidekick
		vim.api.nvim_set_hl(0, "SidekickNormal", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "SidekickBorder", { fg = border_color, bg = "NONE" })
		vim.api.nvim_set_hl(0, "SidekickFloat", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "SidekickTitle", { bg = "NONE" })

		-- Snacks Picker (used by Sidekick)
		vim.api.nvim_set_hl(0, "SnacksPickerBorder", { fg = border_color, bg = "NONE" })

		-- Diagnostic floating windows
		vim.api.nvim_set_hl(0, "DiagnosticFloatingBorder", { fg = border_color, bg = "NONE" })
		vim.api.nvim_set_hl(0, "DiagnosticFloatBorder", { fg = border_color, bg = "NONE" })
		vim.api.nvim_set_hl(0, "LspInfoBorder", { fg = border_color, bg = "NONE" })
	end)
end

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = set_transparent_floats,
})

-- Also apply on startup
set_transparent_floats()
