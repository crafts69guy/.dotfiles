return {
	"stevearc/conform.nvim",
	opts = function(_, opts)
		opts.formatters_by_ft = opts.formatters_by_ft or {}
		-- Lua formatting (not covered by extras)
		opts.formatters_by_ft.lua = { "stylua" }
		-- Note: The prettier extra already configures these file types:
		-- javascript, javascriptreact, typescript, typescriptreact, json, css, html, markdown
		-- Only override here if you need custom settings
		return opts
	end,
}
