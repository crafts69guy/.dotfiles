-- Local Lua workflow and Rex worker panel; open with :Orc.
-- `:Orc projects` uses Snacks picker, already provided by LazyVim.
return {
	{
		dir = vim.fn.expand("~/Developments/github.com/crafts69guy/orc.nvim"),
		name = "orc.nvim",
		main = "orc",
		cmd = "Orc",
		dependencies = { "folke/snacks.nvim" },
		opts = {},
	},
}
