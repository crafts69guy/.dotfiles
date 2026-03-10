return {
	-- Enhanced Go development (test runner, code generation, struct tags, etc.)
	{
		"ray-x/go.nvim",
		dependencies = {
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		event = { "BufReadPre *.go", "BufNewFile *.go" },
		build = ':lua require("go.install").update_all_sync()',
		opts = {
			go = "go",
			goimports = "gopls",
			gofmt = "gofumpt",
			lsp_cfg = false, -- handled by nvim-lspconfig below
			lsp_gofumpt = true,
			lsp_on_attach = false, -- handled by LazyVim
			dap_debug = true,
			dap_debug_keymap = false, -- set our own below
			trouble = true,
			test_runner = "go",
			run_in_floaterm = false,
			icons = { breakpoint = "●", currentpos = "▶" },
			verbose = false,
		},
		config = function(_, opts)
			require("go").setup(opts)
		end,
		keys = {
			{ "<leader>gr", "<cmd>GoRun<cr>", ft = "go", desc = "Go Run" },
			{ "<leader>gt", "<cmd>GoTest<cr>", ft = "go", desc = "Go Test" },
			{ "<leader>gT", "<cmd>GoTestFile<cr>", ft = "go", desc = "Go Test File" },
			{ "<leader>gf", "<cmd>GoTestFunc<cr>", ft = "go", desc = "Go Test Func" },
			{ "<leader>gc", "<cmd>GoCoverage<cr>", ft = "go", desc = "Go Coverage" },
			{ "<leader>gi", "<cmd>GoImports<cr>", ft = "go", desc = "Go Imports" },
			{ "<leader>gts", "<cmd>GoAddTag<cr>", ft = "go", desc = "Go Add Struct Tags" },
			{ "<leader>gtS", "<cmd>GoRmTag<cr>", ft = "go", desc = "Go Remove Struct Tags" },
			{ "<leader>ge", "<cmd>GoIfErr<cr>", ft = "go", desc = "Go If Err" },
			{ "<leader>gm", "<cmd>GoMod<cr>", ft = "go", desc = "Go Mod" },
			{ "<leader>gl", "<cmd>GoLint<cr>", ft = "go", desc = "Go Lint" },
		},
	},

	-- Mason tools
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				"gopls",
				"gofumpt",
				"goimports",
				"golangci-lint",
				"delve",
			})
		end,
	},

	-- gopls LSP configuration
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				gopls = {
					settings = {
						gopls = {
							gofumpt = true,
							codelenses = {
								gc_details = false,
								generate = true,
								regenerate_cgo = true,
								run_govulncheck = true,
								test = true,
								tidy = true,
								upgrade_dependency = true,
								vendor = true,
							},
							analyses = {
								fieldalignment = true,
								nilness = true,
								unusedparams = true,
								unusedwrite = true,
								useany = true,
							},
							usePlaceholders = true,
							completeUnimported = true,
							staticcheck = true,
							directoryFilters = {
								"-.git",
								"-.vscode",
								"-.idea",
								"-node_modules",
							},
							semanticTokens = true,
						},
					},
				},
			},
		},
	},

	-- Treesitter parsers
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "go", "gomod", "gowork", "gosum" })
		end,
	},

	-- Formatting: goimports first (organizes imports), then gofumpt (stricter fmt)
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				go = { "goimports", "gofumpt" },
			},
		},
	},
}
