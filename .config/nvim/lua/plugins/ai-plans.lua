-- ai-plans.nvim: Plugin specification for lazy.nvim
-- Browse, preview, and manage AI-generated plan files

return {
	{
		"crafts69guy/ai-plans.nvim",
		-- dir = "~/Developments/ai-plans.nvim",
		-- Once published to GitHub, replace with:
		-- "your-username/ai-plans.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{
				"<C-A-p>",
				function()
					require("telescope").extensions.ai_plans.ai_plans()
				end,
				desc = "AI Plans",
				mode = "n",
			},
			{
				"<leader>aP",
				function()
					require("telescope").extensions.ai_plans.ai_plans()
				end,
				desc = "Browse AI Plans",
				mode = "n",
			},
			{
				"<leader>aG",
				function()
					require("telescope").extensions.ai_plans.grep()
				end,
				desc = "Search AI Plans",
				mode = "n",
			},
		},
		opts = {
			sources = {
				claude = {
					path = "~/.claude/plans/",
					pattern = "*.md",
					display_name = "Claude",
					icon = "",
				},
				-- Add more sources as needed:
				-- chatgpt = {
				--   path = "~/ChatGPT/",
				--   pattern = "*.md",
				--   display_name = "ChatGPT",
				--   icon = "",
				-- },
			},
			use_bat = true,
			use_rg = true,
			theme = "dropdown",
			layout_config = {
				width = 0.9,
				height = 0.9,
				prompt_position = "bottom",
			},
			initial_mode = "normal", -- file picker initial mode
			grep_initial_mode = "insert", -- grep picker initial mode
			sort_by = "mtime", -- newest first
			show_title = true, -- extract markdown titles
		},
		config = function(_, opts)
			-- Setup is called automatically when loading the extension
			require("telescope").setup({
				extensions = {
					ai_plans = opts,
				},
			})
			require("telescope").load_extension("ai_plans")
		end,
	},
}
