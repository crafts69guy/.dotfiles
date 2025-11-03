return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			-- Lua formatting (not covered by extras)
			lua = { "stylua" },

			-- Note: The prettier extra already configures these file types:
			-- javascript, javascriptreact, typescript, typescriptreact, json, css, html, markdown
			-- Only override here if you need custom settings
		},
	},
}
