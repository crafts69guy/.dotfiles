return {
	-- Mason tools installation
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				"stylua",
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
			-- tbl_deep_extend returns a new table; assign it or the overrides are dropped.
			opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, {
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
			})
			local servers = opts.servers

			if require("config.profile").is("web") then
				servers.html = {}
				servers.cssls = {}
				-- vscode-eslint needs the project's own eslint package; without it the server
				-- spams "Unable to find ESLint library". Skip attaching until deps are installed.
				-- Root is resolved per buffer, so `:e` after `npm install` picks it up.
				servers.eslint = {
					root_dir = function(bufnr, on_dir)
						local file = vim.api.nvim_get_runtime_file("lsp/eslint.lua", false)[1]
						if not file then
							return
						end
						dofile(file).root_dir(bufnr, function(root)
							local has_eslint = vim.fs.root(bufnr, function(name, path)
								return name == ".pnp.cjs"
									or (name == "node_modules" and vim.uv.fs_stat(path .. "/node_modules/eslint") ~= nil)
							end)
							if has_eslint then
								on_dir(root)
							end
						end)
					end,
				}
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
