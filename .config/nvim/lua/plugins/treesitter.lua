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
				"tmux",
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
			elseif require("config.profile").is("rust") then
				table.insert(opts.ensure_installed, "rust")
			end
			opts.parser_install_dir = require("config.profile").paths().treesitter
			return opts
		end,
	},
}
