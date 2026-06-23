return {
	-- messages, cmdline and the popupmenu
	{
		"folke/noice.nvim",
		opts = function(_, opts)
			table.insert(opts.routes, {
				filter = {
					event = "notify",
					find = "No information available",
				},
				opts = { skip = true },
			})
			local focused = true
			vim.api.nvim_create_autocmd("FocusGained", {
				callback = function()
					focused = true
				end,
			})
			vim.api.nvim_create_autocmd("FocusLost", {
				callback = function()
					focused = false
				end,
			})
			table.insert(opts.routes, 1, {
				filter = {
					cond = function()
						return not focused
					end,
				},
				view = "notify_send",
				opts = { stop = false },
			})

			opts.commands = {
				all = {
					-- options for the message history that you get with `:Noice`
					view = "split",
					opts = { enter = true, format = "details" },
					filter = {},
				},
			}

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function(event)
					vim.schedule(function()
						require("noice.text.markdown").keys(event.buf)
					end)
				end,
			})

			-- Disable noice's input handling to allow Snacks.input to handle it
			-- Temp disabled to use mini.surround with snack issue
			-- opts.cmdline = opts.cmdline or {}
			-- opts.cmdline.format = opts.cmdline.format or {}
			-- opts.cmdline.format.input = false

			opts.presets.lsp_doc_border = true
			opts.presets.inc_rename = true
		end,
	},

	{
		"rcarriga/nvim-notify",
		opts = {
			timeout = 5000,
		},
	},

	-- buffer line
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
			{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
			{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
		},
		opts = function()
			local c = require("solarized-osaka.colors").setup()
			local lighten = require("solarized-osaka.util").lighten

			local fill = c.base03 -- empty strip: matches the editor's active line (CursorLine = base03)
			local inactive = c.base02 -- inactive tab body, lifted one step above fill so chips stay distinct
			local active = lighten(c.base02, 0.85) -- active tab body, slightly lifted over base02

			return {
				options = {
					mode = "tabs",
					separator_style = "slant",
					indicator = { style = "none" },
					show_buffer_close_icons = false,
					show_close_icon = false,
					color_icons = true,
					modified_icon = "●",
					always_show_bufferline = true,
				},
				highlights = {
					fill = { bg = fill },

					-- inactive tab
					background = { fg = c.base01, bg = inactive },
					buffer_visible = { fg = c.base0, bg = inactive },
					-- active tab: bright yellow text (solarized-osaka accent)
					buffer_selected = { fg = c.yellow300, bg = active, bold = true, italic = false },
					numbers_selected = { fg = c.yellow300, bg = active, bold = true },

					-- slant separators: fg = gap color, bg = tab body
					separator = { fg = fill, bg = inactive },
					separator_visible = { fg = fill, bg = inactive },
					separator_selected = { fg = fill, bg = active },

					-- active indicator (yellow, theme accent)
					indicator_selected = { fg = c.yellow500, bg = active },
					indicator_visible = { fg = inactive, bg = inactive },

					-- modified dot (yellow on the active tab, dim elsewhere)
					modified = { fg = c.orange500, bg = inactive },
					modified_visible = { fg = c.orange500, bg = inactive },
					modified_selected = { fg = c.yellow300, bg = active },

					-- file-type icons keep their colors but match tab bg
					duplicate = { fg = c.base00, bg = inactive, italic = true },
					duplicate_visible = { fg = c.base00, bg = inactive, italic = true },
					duplicate_selected = { fg = c.yellow300, bg = active, italic = true },
				},
			}
		end,
	},

	-- statusline
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
			local LazyVim = require("lazyvim.util")

			opts.sections.lualine_c[4] = {
				LazyVim.lualine.pretty_path({
					length = 0,
					relative = "cwd",
					modified_hl = "MatchParen",
					directory_hl = "",
					filename_hl = "Bold",
					modified_sign = "",
					readonly_icon = " 󰌾 ",
				}),
			}
		end,
	},

	-- filename
	{
		"b0o/incline.nvim",
		dependencies = { "craftzdog/solarized-osaka.nvim" },
		event = "BufReadPre",
		priority = 1200,
		config = function()
			local colors = require("solarized-osaka.colors").setup()
			require("incline").setup({
				highlight = {
					groups = {
						InclineNormal = { guibg = colors.magenta500, guifg = colors.base04 },
						InclineNormalNC = { guifg = colors.violet500, guibg = colors.base03 },
					},
				},
				window = { margin = { vertical = 0, horizontal = 1 } },
				hide = {
					cursorline = true,
				},
				render = function(props)
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					if vim.bo[props.buf].modified then
						filename = "[+] " .. filename
					end

					local icon, color = require("nvim-web-devicons").get_icon_color(filename)
					return { { icon, guifg = color }, { " " }, { filename } }
				end,
			})
		end,
	},

	{
		"MeanderingProgrammer/render-markdown.nvim",
		enabled = false,
	},
}
