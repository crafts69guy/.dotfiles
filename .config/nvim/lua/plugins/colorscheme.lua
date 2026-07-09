return {
	-- Hue Theme — Huế-inspired moods (hue-mua / hue-huong / hue-cung).
	-- Active mood is set via the LazyVim `colorscheme` opt in config/lazy.lua.
	{
		"crafts69guy/hue-nvim",
		dir = (function()
			local home = vim.env.HUE_THEME_HOME or vim.fn.expand("~/Developments/github.com/crafts69guy/hue-theme")
			local plugin = home .. "/packages/nvim-plugin"
			return vim.loop.fs_stat(plugin) and plugin or nil
		end)(),
		lazy = false,
		priority = 1000,
		opts = { transparent = true },
		config = function(_, opts)
			require("hue").setup(opts)
		end,
	},
}
