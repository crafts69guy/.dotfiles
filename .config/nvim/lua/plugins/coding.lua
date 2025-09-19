return {
	-- Incremental rename
	{
		"smjonas/inc-rename.nvim",
		cmd = "IncRename",
		config = true,
	},

	-- Go forward/backward with square brackets
	{
		"nvim-mini/mini.bracketed",
		event = "BufReadPost",
		config = function()
			local bracketed = require("mini.bracketed")
			bracketed.setup({
				file = { suffix = "" },
				window = { suffix = "" },
				quickfix = { suffix = "" },
				yank = { suffix = "" },
				treesitter = { suffix = "n" },
			})
		end,
	},

	-- Better increase/descrease
	{
		"monaqa/dial.nvim",
    -- stylua: ignore
    keys = {
      { "<C-a>", function() return require("dial.map").inc_normal() end, expr = true, desc = "Increment" },
      { "<C-x>", function() return require("dial.map").dec_normal() end, expr = true, desc = "Decrement" },
    },
		config = function()
			local augend = require("dial.augend")
			require("dial.config").augends:register_group({
				default = {
					augend.integer.alias.decimal,
					augend.integer.alias.hex,
					augend.date.alias["%Y/%m/%d"],
					augend.constant.alias.bool,
					augend.semver.alias.semver,
					augend.constant.new({ elements = { "let", "const" } }),
				},
			})
		end,
	},

	{
		"simrat39/symbols-outline.nvim",
		keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
		cmd = "SymbolsOutline",
		opts = {
			position = "right",
		},
	},

	{
		"saghen/blink.cmp",
		dependencies = {
			{
				"codeium.nvim",
				"saghen/blink.compat",
				"rafamadriz/friendly-snippets",
			},
		},
		opts = {
			snippets = {
				expand = function(snippet)
					require("luasnip").lsp_expand(snippet)
				end,
				active = function(filter)
					if filter and filter.direction then
						return require("luasnip").jumpable(filter.direction)
					end
					return require("luasnip").in_snippet()
				end,
				jump = function(direction)
					require("luasnip").jump(direction)
				end,
			},

			signature = {
				enabled = true,
				window = {
					winblend = vim.o.pumblend,
				},
			},

			appearance = {
				use_nvim_cmp_as_default = false,
				-- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},

			completion = {
				accept = {
					auto_brackets = {
						enabled = true,
					},
				},
				menu = {
					draw = {
						treesitter = { "lsp" },
						columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
					},
					winblend = vim.o.pumblend,
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},
				ghost_text = {
					enabled = vim.g.ai_cmp,
				},
			},

			sources = {
				-- adding any nvim-cmp sources here will enable them
				-- with blink.compat
				compat = { "codeium" },
				default = { "lsp", "path", "snippets", "buffer" },

				-- add lazydev to your completion providers
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100, -- show at a higher priority than lsp
					},
					codeium = {
						kind = "Codeium",
						score_offset = 100,
						async = true,
					},
				},
			},

			keymap = {
				preset = "enter",
				["<C-y>"] = { "select_and_accept" },
			},
		},
	},

	{
		"xzbdmw/colorful-menu.nvim",
		config = function() end,
	},

	{
		"saghen/blink.compat",
		optional = true, -- make optional so it's only enabled if any extras need it
		lazy = true,
		opts = {},
		version = not vim.g.lazyvim_blink_main and "*",
	},

	{
		"catppuccin",
		optional = true,
		opts = {
			integrations = { blink_cmp = true },
		},
	},

	{
		"chentoast/marks.nvim",
		event = "VeryLazy",
		opts = {},
	},
}
