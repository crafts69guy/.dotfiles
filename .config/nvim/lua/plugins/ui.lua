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

			-- Tabs whose worst diagnostic is a warning/error get a status-hued body:
			-- solid on the active tab (dark text), a dim tint on inactive ones,
			-- mirroring the active/inactive lift. Re-derived on :colorscheme.
			local diag_tab_hls = {
				warning = { "BufferLineWarnTab", "BufferLineWarnTabSelected" },
				error = { "BufferLineErrorTab", "BufferLineErrorTabSelected" },
			}
			local function set_diag_tab_hls()
				local hue = require("crafts69guy.hue_colors")
				local p = hue.get()
				for level, groups in pairs(diag_tab_hls) do
					local color = p[level]
					vim.api.nvim_set_hl(0, groups[1], { fg = color, bg = hue.blend(color, p.raised, 0.25) })
					vim.api.nvim_set_hl(0, groups[2], { fg = p.canvas, bg = color, bold = true })
				end
			end
			set_diag_tab_hls()
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("crafts69guy_bufferline_diag", { clear = true }),
				callback = set_diag_tab_hls,
			})

			-- bufferline only recolors the name/count per diagnostic level; icon,
			-- padding, indicator and modified dot keep the tab-body bg. Wrap
			-- ui.element so a warning/error tab repaints every body segment
			-- (separators excluded) with one group.
			local ui = require("bufferline.ui")
			if not ui._crafts69guy_diag_wrapped then
				ui._crafts69guy_diag_wrapped = true
				local element = ui.element
				ui.element = function(state, tab)
					local el = element(state, tab)
					local d = el.diagnostics
					local groups = d and (d.count or 0) > 0 and diag_tab_hls[d.level]
					if not groups then
						return el
					end
					local hl = el:current() and groups[2] or groups[1]
					local render = el.component
					el.component = function(next_item)
						local segments = render(next_item)
						for _, seg in ipairs(segments) do
							-- drop `extends` so the name doesn't get re-tinted with BufferLineWarning*/Error*
							if seg.attr then
								seg.attr.extends = nil
							end
							if seg.highlight and not seg.highlight:find("^BufferLineSeparator") then
								seg.highlight = hl
							end
						end
						return segments
					end
					return el
				end
			end

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
			-- Basenames too generic to identify a file on their own; show the
			-- parent dir too (e.g. `Button/index.jsx`).
			local generic = { index = true }

			-- incline hardcodes `border = "none"` and a 1-row geometry. To get the
			-- noice cmdline-popup look (rounded border box), patch the Winline
			-- class: the class itself is private, so grab it from the metatable of
			-- the first instance built through the module's __call constructor.
			local winline_mt = getmetatable(require("incline.winline"))
			local make = winline_mt.__call
			local patched = false
			winline_mt.__call = function(...)
				local obj = make(...)
				if not patched then
					patched = true
					local Winline = getmetatable(obj).__index

					-- Float row/col address the border's outer corner, so shift the
					-- box left by the 2 border columns to keep the right margin.
					local get_win_config = Winline.get_win_config
					function Winline:get_win_config()
						local cfg = get_win_config(self)
						cfg.border = "rounded"
						cfg.col = math.max(cfg.col - 2, 0)
						return cfg
					end

					-- The box now covers 3 rows and width + 2 cols; hide on all of them.
					local overlaps_buffer = Winline.incline_overlaps_buffer_content
					function Winline:cursor_overlaps_incline()
						if not overlaps_buffer(self) then
							return false
						end
						local cfg = self:get_win_config()
						local pos = vim.api.nvim_win_get_position(self.target_win)
						local row = pos[1] + vim.api.nvim_win_call(self.target_win, vim.fn.winline) - 1
						local col = pos[2] + vim.api.nvim_win_call(self.target_win, vim.fn.wincol) - 1
						return row >= cfg.row
							and row < cfg.row + cfg.height + 2
							and col >= cfg.col
							and col < cfg.col + cfg.width + 2
					end
				end
				return obj
			end

			-- hue-nvim is `transparent = true`: keep the box body on "NONE" so it
			-- blends into the editor bg like the cmdline popup does.
			require("incline").setup({
				highlight = {
					groups = {
						InclineNormal = { guibg = "NONE" },
						InclineNormalNC = { guibg = "NONE" },
					},
				},
				window = {
					margin = { vertical = 0, horizontal = 1 },
					padding = 1,
					winhighlight = {
						active = {
							EndOfBuffer = { guibg = "NONE" },
							FloatBorder = { guifg = c.info, guibg = "NONE" },
						},
						inactive = {
							EndOfBuffer = { guibg = "NONE" },
							FloatBorder = { guifg = c.border, guibg = "NONE" },
						},
					},
				},
				hide = {
					cursorline = true,
				},
				render = function(props)
					local fg = props.focused and c.text or c.subtext

					local path = vim.api.nvim_buf_get_name(props.buf)
					local filename = vim.fn.fnamemodify(path, ":t")
					if filename == "" then
						filename = "[No Name]"
					end
					local parent = ""
					if generic[vim.fn.fnamemodify(filename, ":r")] then
						parent = vim.fn.fnamemodify(path, ":h:t") .. "/"
					end

					local icon, icon_color = require("nvim-web-devicons").get_icon_color(filename)

					return {
						icon and { icon .. " ", guifg = icon_color } or "",
						{ parent, guifg = c.subtext },
						{ filename, guifg = fg, gui = props.focused and "bold" or "none" },
						vim.bo[props.buf].modified and { " ●", guifg = c.warning } or "",
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
