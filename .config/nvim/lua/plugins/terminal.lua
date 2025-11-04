-- Disable LazyVim's default terminal in favor of Snacks terminal
return {
	-- Disable the default LazyVim terminal
	{
		"akinsho/toggleterm.nvim",
		enabled = false,
	},

	-- Ensure nvim-lua/plenary.nvim is available for Snacks
	{
		"nvim-lua/plenary.nvim",
		lazy = false,
	},
}
