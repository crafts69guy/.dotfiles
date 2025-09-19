return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			["javascript"] = { "prettier" },
			["javascriptreact"] = { "prettier" },
			["typescript"] = { "prettier" },
			["typescriptreact"] = { "prettier" },
			["json"] = { "prettier" },
			["css"] = { "prettier" },
			["html"] = { "prettier" },
			["markdown"] = { "prettier" },
		},
	},
}
