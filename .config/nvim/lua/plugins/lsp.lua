return {
	-- Mason tools installation
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			opts.install_root_dir = require("config.profile").paths().mason
			vim.list_extend(opts.ensure_installed, {
				"stylua",
				"luacheck",
				"shellcheck",
				"shfmt",
			})
			if require("config.profile").is("rust") then
				table.insert(opts.ensure_installed, "rust-analyzer")
			end
			opts.ui = {
				border = "rounded",
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			}
		end,
	},

	-- LSP Configuration
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },
		opts = function(_, opts)
			opts = opts or {}
			opts.inlay_hints = { enabled = false }
			opts.servers = opts.servers or {}
			local servers = opts.servers

			-- Disable inlay hints globally
			-- Server configurations
			vim.tbl_deep_extend("force", servers, {
				-- YAML (not covered by extras)
				yamlls = {
					settings = {
						yaml = {
							keyOrdering = false,
						},
					},
				},

				-- Lua (not covered by extras)
				lua_ls = {
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
							},
							completion = {
								workspaceWord = true,
								callSnippet = "Both",
							},
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
							doc = {
								privateName = { "^_" },
							},
							type = {
								castNumberToInteger = true,
							},
							diagnostics = {
								disable = { "incomplete-signature-doc", "trailing-space" },
								groupSeverity = {
									strong = "Warning",
									strict = "Warning",
								},
								groupFileStatus = {
									["ambiguity"] = "Opened",
									["await"] = "Opened",
									["codestyle"] = "None",
									["duplicate"] = "Opened",
									["global"] = "Opened",
									["luadoc"] = "Opened",
									["redefined"] = "Opened",
									["strict"] = "Opened",
									["strong"] = "Opened",
									["type-check"] = "Opened",
									["unbalanced"] = "Opened",
									["unused"] = "Opened",
								},
								unusedLocalExclude = { "_*" },
							},
							format = {
								enable = false,
								defaultConfig = {
									indent_style = "space",
									indent_size = "2",
									continuation_indent_size = "2",
								},
							},
						},
					},
				},

				-- Global settings for all servers
				["*"] = {
					keys = {
						{
							"gd",
							function()
								Snacks.picker.lsp_definitions({ jump = { reuse_win = false } })
							end,
							desc = "Goto Definition",
							has = "definition",
						},
					},
				},
			})

			if require("config.profile").is("web") then
				servers.html = {}
				servers.cssls = {}
				servers.tailwindcss = {
					settings = {
						tailwindCSS = {
							classFunctions = { "cva", "cx", "clsx", "classnames" },
							experimental = { classRegex = { { "tw`([^`]*)", "([\"'`]([^\"'`]*).*?[\"'`])" } } },
						},
					},
				}
			end

			if require("config.profile").is("rust") then
				servers.rust_analyzer = {
					settings = {
						["rust-analyzer"] = {
							cargo = { buildScripts = { enable = true }, allTargets = false },
							procMacro = { enable = true },
							checkOnSave = { command = "clippy" },
						},
					},
				}
			end

			return opts
		end,
	},
}
