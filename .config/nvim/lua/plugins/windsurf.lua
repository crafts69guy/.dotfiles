local windsurf_icon = "🌊"

return {
	{
		"Exafunction/windsurf.nvim",
		cmd = "Codeium",
		event = "InsertEnter",
		main = "codeium",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"saghen/blink.cmp",
		},
		opts = {
			config_path = vim.fn.expand("~/.config/windsurf.nvim/config.json"),
			enable_cmp_source = false,
			virtual_text = {
				enabled = false,
			},
		},
	},

	{
		"saghen/blink.cmp",
		optional = true,
		dependencies = { "Exafunction/windsurf.nvim" },
		opts = function(_, opts)
			opts.sources = opts.sources or {}
			opts.sources.default = opts.sources.default or {}

			local seen = {}
			opts.sources.default = vim.tbl_filter(function(source)
				if seen[source] then
					return false
				end
				seen[source] = true
				return true
			end, opts.sources.default)

			if not vim.tbl_contains(opts.sources.default, "codeium") then
				table.insert(opts.sources.default, "codeium")
			end

			opts.sources.providers = opts.sources.providers or {}
			opts.sources.providers.codeium = {
				name = "Windsurf",
				module = "codeium.blink",
				async = true,
				score_offset = 100,
				transform_items = function(_, items)
					for _, item in ipairs(items) do
						item.kind_icon = windsurf_icon
						item.kind_name = "Windsurf"
					end
					return items
				end,
			}
		end,
	},
}
