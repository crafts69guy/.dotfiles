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

			opts.views = opts.views or {}
			opts.views.mini = opts.views.mini or {}
			opts.views.mini.border = {
				style = "rounded",
				padding = { 0, 1 },
			}
			opts.views.lsp_progress = {
				view = "mini",
				position = {
					row = 1,
					col = "100%",
				},
				border = {
					style = "rounded",
					padding = { 0, 1 },
				},
			}
			opts.lsp = opts.lsp or {}
			opts.lsp.progress = opts.lsp.progress or {}
			opts.lsp.progress.view = "lsp_progress"

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

	-- buffer line
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
			{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
			{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
		},
		opts = function()
			local c = require("crafts69guy.hue_colors").get()

			-- hue-nvim runs with `transparent = true`: the real editor bg is
			-- "NONE" (terminal shows through), not c.canvas's hex. Slant
			-- separators need an opaque backdrop to fake their fill color, so
			-- under transparency use "thin" bars on a NONE gap instead —
			-- anything using c.canvas as a stand-in bg paints a mismatched
			-- solid rectangle over the transparent terminal.
			local fill = "NONE"
			local inactive = c.raised -- inactive tab body, lifted one step above fill so chips stay distinct
			local active = c.selected -- active tab body, clearly lifted over inactive

			return {
				options = {
					mode = "tabs",
					separator_style = "thin",
					indicator = { style = "icon", icon = "▎" },
					show_buffer_close_icons = false,
					show_close_icon = false,
					show_duplicate_prefix = true,
					color_icons = true,
					modified_icon = "●",
					always_show_bufferline = true,
					tab_size = 18,
					diagnostics = "nvim_lsp",
					diagnostics_indicator = function(count, level)
						local icon = level:match("error") and " " or " "
						return icon .. count
					end,
				},
				highlights = {
					fill = { bg = fill },

					-- inactive tab
					background = { fg = c.subtext, bg = inactive },
					buffer_visible = { fg = c.text, bg = inactive },
					-- active tab: Hue primary accent (jade)
					buffer_selected = { fg = c.primary, bg = active, bold = true, italic = false },
					numbers_selected = { fg = c.primary, bg = active, bold = true },

					-- thin separators: subtle divider on the transparent gap
					separator = { fg = c.border, bg = fill },
					separator_visible = { fg = c.border, bg = fill },
					separator_selected = { fg = c.primary, bg = fill },

					-- active indicator (theme accent)
					indicator_selected = { fg = c.primary, bg = active },
					indicator_visible = { fg = inactive, bg = inactive },

					-- modified dot (warning hue on the active tab, dim elsewhere)
					modified = { fg = c.warning, bg = inactive },
					modified_visible = { fg = c.warning, bg = inactive },
					modified_selected = { fg = c.warning, bg = active },

					-- file-type icons keep their colors but match tab bg
					duplicate = { fg = c.subtext, bg = inactive, italic = true },
					duplicate_visible = { fg = c.subtext, bg = inactive, italic = true },
					duplicate_selected = { fg = c.primary, bg = active, italic = true },
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
		event = "BufReadPre",
		priority = 1200,
		config = function()
			local c = require("crafts69guy.hue_colors").get()
			-- hue-nvim is `transparent = true`, so the real backdrop is "NONE"
			-- (terminal/wallpaper), not c.canvas's hex — the caps must sit on
			-- NONE too, or they paint a mismatched solid rectangle behind the
			-- pill instead of blending into the transparent editor bg.
			local cap_left, cap_right = "", ""

			require("incline").setup({
				highlight = {
					groups = {
						InclineNormal = { guibg = "NONE" },
						InclineNormalNC = { guibg = "NONE" },
					},
				},
				window = {
					margin = { vertical = 0, horizontal = 1 },
					padding = 0,
					winhighlight = {
						active = { EndOfBuffer = { guibg = "NONE" } },
						inactive = { EndOfBuffer = { guibg = "NONE" } },
					},
				},
				hide = {
					cursorline = true,
				},
				render = function(props)
					local pill = props.focused and c.secondary or c.raised
					local fg = props.focused and c.canvas or c.subtext

					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					if vim.bo[props.buf].modified then
						filename = "[+] " .. filename
					end

					local icon, icon_color = require("nvim-web-devicons").get_icon_color(filename)

					return {
						{ cap_left, guifg = pill, guibg = "NONE" },
						{ (icon and icon .. " " or ""), guifg = icon_color, guibg = pill },
						{ filename, guifg = fg, guibg = pill },
						{ " ", guibg = pill },
						{ cap_right, guifg = pill, guibg = "NONE" },
					}
				end,
			})
		end,
	},

	{
		"MeanderingProgrammer/render-markdown.nvim",
		enabled = false,
	},
}
