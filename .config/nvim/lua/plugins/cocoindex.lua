-- cocoindex-code (`ccc`): semantic search, structural grep and index management.
-- Plugin source lives in its own repo; use the local checkout when present.
local local_dir = vim.fn.expand("~/Developments/github.com/crafts69guy/cocoindex.nvim")
local source = vim.uv.fs_stat(local_dir) and { dir = local_dir, name = "cocoindex.nvim" }
	or { "crafts69guy/cocoindex.nvim" }

return {
	vim.tbl_extend("force", source, {
		dependencies = { "folke/snacks.nvim" },
		cmd = "Ccc",
		-- Loaded on startup-ish so auto-index sees the first write.
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				";c",
				function()
					require("cocoindex").search()
				end,
				desc = "Semantic Search (ccc)",
			},
			{
				";c",
				function()
					require("cocoindex").search_visual()
				end,
				mode = "x",
				desc = "Semantic Search Selection (ccc)",
			},
			{
				";C",
				function()
					require("cocoindex").grep()
				end,
				desc = "Structural Grep (ccc)",
			},
			{
				"<leader>ks",
				function()
					require("cocoindex").search_word()
				end,
				desc = "Search Word",
			},
			{ "<leader>ki", "<cmd>Ccc index<cr>", desc = "Update Index" },
			{ "<leader>kS", "<cmd>Ccc status<cr>", desc = "Status" },
			{ "<leader>kd", "<cmd>Ccc doctor<cr>", desc = "Doctor" },
			{ "<leader>kI", "<cmd>Ccc init<cr>", desc = "Init Project" },
			{ "<leader>kh", "<cmd>checkhealth cocoindex<cr>", desc = "Health" },
		},
	}),
	{
		"folke/which-key.nvim",
		opts = {
			spec = {
				{ "<leader>k", group = "cocoindex", icon = { icon = "󰊕 ", color = "purple" } },
			},
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
			table.insert(opts.sections.lualine_x, 1, {
				function()
					return require("cocoindex.statusline").get()
				end,
				cond = function()
					return package.loaded["cocoindex"] ~= nil and require("cocoindex.statusline").cond()
				end,
				color = function()
					return { fg = Snacks.util.color(require("cocoindex.statusline").highlight()) }
				end,
			})
		end,
	},
}
