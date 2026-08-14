return {
	{
		"folke/which-key.nvim",
		opts = {
			spec = {
				{ "<leader>o", group = "Open", icon = { icon = "󰏌 ", color = "azure" } },
				{ "<leader>y", group = "Yank", icon = { icon = "󰅍 ", color = "yellow" } },
				{ "<leader>r", icon = { icon = "󰸱 ", color = "purple" } },
				{ "<leader>t", group = "Tabs", icon = { icon = "󰓩 ", color = "cyan" } },
			},
		},
	},

	{
		"folke/flash.nvim",
		enabled = false,
	},

	{
		"brenoprata10/nvim-highlight-colors",
		event = "BufReadPre",
		opts = {
			render = "background",
			enable_hex = true,
			enable_short_hex = true,
			enable_rgb = true,
			enable_hsl = true,
			enable_hsl_without_function = true,
			enable_ansi = true,
			enable_var_usage = true,
			enable_tailwind = true,
		},
	},

	{
		"dinhhuy258/git.nvim",
		event = "BufReadPre",
		opts = {
			keymaps = {
				-- Open blame window
				blame = "<Leader>gb",
				-- Open file/folder in git repository
				browse = "<Leader>go",
			},
		},
	},

	{
		"kazhala/close-buffers.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<leader>th",
				function()
					require("close_buffers").delete({ type = "hidden" })
				end,
				desc = "Close Hidden Buffers",
			},
			{
				"<leader>tu",
				function()
					require("close_buffers").delete({ type = "nameless" })
				end,
				desc = "Close Nameless Buffers",
			},
		},
	},

	{
		"stevearc/aerial.nvim",
		opts = {},
		-- Optional dependencies
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},

	-- Disable neo-tree (using Snacks explorer instead)
	{
		"neo-tree.nvim",
		enabled = false,
	},
}
