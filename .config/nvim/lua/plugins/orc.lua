-- Local Lua workflow and Rex worker panel; open with :Orc.
return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "v0.2.2",
		cmd = "Telescope",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},
	{
		dir = vim.fn.expand("~/Developments/github.com/crafts69guy/orc.nvim"),
		name = "orc.nvim",
		main = "orc",
		cmd = "Orc",
		opts = {},
	},
}
