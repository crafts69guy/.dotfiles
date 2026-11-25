return {
	{
		"kchmck/vim-coffee-script",
		ft = { "coffee", "litcoffee" },
	},
	{
		"mason-org/mason.nvim",
		opts = { ensure_installed = { "coffeesense-language-server" } },
	},
	{
		"neovim/nvim-lspconfig",
		opts = { servers = { coffeesense = {} } },
	},
}
