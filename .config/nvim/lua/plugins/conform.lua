return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			["javascript"] = { "biome-check" },
			["javascriptreact"] = { "biome-check" },
			["typescript"] = { "biome-check" },
			["typescriptreact"] = { "biome-check" },
			["json"] = { "biome-check" },
			["css"] = { "biome-check" },
			["markdown"] = { "prettier" },
		},
	},
}
