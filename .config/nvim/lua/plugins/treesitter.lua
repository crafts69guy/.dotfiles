return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				-- "astro",
				"jsonc",
				"regex",
				"bash",
				"markdown",
				"markdown_inline",
				"html",
				"javascript",
				"typescript",
				"vim",
				"vimdoc",
				"lua",
				"tsx",
				"luadoc",
				-- "yaml",
				-- "xml",
				-- "cmake",
				-- "cpp",
				"fish",
				"gitignore",
				"tmux",
				-- "graphql",
				"http",
				-- "java",
				-- "php",
				-- "rust",
				"css",
				"scss",
				"styled",
				-- "sql",
				-- "svelte",
			})
			return opts
		end,
	},
}
