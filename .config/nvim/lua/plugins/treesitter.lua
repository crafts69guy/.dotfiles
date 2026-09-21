return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				"jsonc",
				"regex",
				"bash",
				"markdown",
				"markdown_inline",
				"vim",
				"vimdoc",
				"lua",
				"luadoc",
				"fish",
				"gitignore",
				"http",
			})
			if require("config.profile").is("web") then
				vim.list_extend(opts.ensure_installed, {
					"html",
					"javascript",
					"typescript",
					"tsx",
					"css",
					"scss",
					"styled",
				})
			end
			if require("config.profile").is("rust") then
				table.insert(opts.ensure_installed, "rust")
			end
			return opts
		end,
	},
}
