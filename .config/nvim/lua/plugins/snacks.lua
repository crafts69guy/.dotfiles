local function buffer_cwd()
	local path = vim.api.nvim_buf_get_name(0)
	if vim.bo.buftype == "" and path ~= "" and not path:match("^%w[%w+.-]*://") then
		if vim.fn.isdirectory(path) == 1 then
			return path
		end
		for parent in vim.fs.parents(path) do
			if vim.fn.isdirectory(parent) == 1 then
				return parent
			end
		end
	end
	return vim.fn.getcwd()
end

local function review_git(cwd, args, error_message, on_success)
	local cmd = vim.list_extend({ "git" }, args)
	local on_exit = vim.schedule_wrap(function(result)
		if result.code ~= 0 then
			local detail = vim.trim(result.stderr)
			vim.notify(error_message .. (detail ~= "" and ("\n" .. detail) or ""), vim.log.levels.ERROR)
			return
		end
		on_success(vim.trim(result.stdout))
	end)
	local ok, err = pcall(vim.system, cmd, { cwd = cwd, text = true }, on_exit)
	if not ok then
		vim.notify(error_message .. "\n" .. tostring(err), vim.log.levels.ERROR)
	end
end

local function tuicr_review(opts)
	if vim.fn.executable("tuicr") == 0 then
		vim.notify("TuicrReview requires tuicr on PATH", vim.log.levels.ERROR)
		return
	end
	local cwd = buffer_cwd()
	if opts.args == "" then
		Snacks.terminal({ "tuicr", "-w" }, { cwd = cwd })
		return
	end

	local base = opts.args
	if base:sub(1, 1) == "-" then
		vim.notify(("Git review base cannot start with a hyphen: %q"):format(base), vim.log.levels.ERROR)
		return
	end
	review_git(
		cwd,
		{ "rev-parse", "--verify", base .. "^{commit}" },
		("Could not resolve Git review base %q in %s"):format(base, cwd),
		function(commit)
			review_git(
				cwd,
				{ "merge-base", "HEAD", commit },
				("Could not find a Git merge base between HEAD and %q in %s"):format(base, cwd),
				function(merge_base)
					Snacks.terminal({ "tuicr", "-r", merge_base .. "..HEAD" }, { cwd = cwd })
				end
			)
		end
	)
end

return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		init = function()
			vim.api.nvim_create_user_command("TuicrReview", tuicr_review, {
				nargs = "?",
				desc = "Review local changes or changes since a Git base in Tuicr",
			})
		end,
		keys = {
			{
				"<leader>e",
				function()
					Snacks.explorer()
				end,
				desc = "Explorer (Snacks)",
			},
			{
				"<leader>.",
				function()
					Snacks.explorer()
				end,
				desc = "Explorer (Snacks)",
			},

			-- Migrated picker aliases
			{
				"<leader>fP",
				function()
					Snacks.picker.files({ cwd = require("lazy.core.config").options.root })
				end,
				desc = "Find Plugin File",
			},
			{
				";f",
				function()
					Snacks.picker.files({
						cwd = vim.uv.cwd(),
						hidden = true,
						ignored = false,
					})
				end,
				desc = "Find Files (cwd)",
			},
			{
				";r",
				function()
					Snacks.picker.grep({
						cwd = vim.uv.cwd(),
						hidden = true,
						ignored = false,
					})
				end,
				desc = "Grep (cwd)",
			},
			{
				"\\\\",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				";t",
				function()
					Snacks.picker.help()
				end,
				desc = "Help Pages",
			},
			{
				";;",
				function()
					Snacks.picker.resume()
				end,
				desc = "Resume Picker",
			},
			{
				";e",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				";s",
				function()
					Snacks.picker.treesitter()
				end,
				desc = "Treesitter Symbols",
			},
			{
				"sf",
				function()
					Snacks.explorer({ cwd = vim.fn.expand("%:p:h") })
				end,
				desc = "Explorer (Buffer Directory)",
			},

			-- Snacks Picker keymaps
			{
				"<leader><space>",
				function()
					LazyVim.pick("files")()
				end,
				desc = "Find Files (Root Dir)",
			},
			{
				"<leader>ff",
				function()
					LazyVim.pick("files")()
				end,
				desc = "Find Files (Root Dir)",
			},
			{
				"<leader>fb",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Find Buffers",
			},
			{
				"<leader>fr",
				function()
					Snacks.picker.recent()
				end,
				desc = "Recent Files",
			},
			{
				"<leader>fg",
				function()
					Snacks.picker.git_files()
				end,
				desc = "Find Files (git-files)",
			},
			{
				"<leader>fw",
				function()
					Snacks.picker.grep_word()
				end,
				desc = "Grep Word",
			},
			{
				"<leader>fc",
				function()
					Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "Find Config Files",
			},

			-- Git pickers
			{
				"<leader>gc",
				function()
					Snacks.picker.git_log()
				end,
				desc = "Git Log",
			},
			{
				"<leader>gs",
				function()
					Snacks.picker.git_status()
				end,
				desc = "Git Status",
			},

			-- LSP pickers
			{
				"<leader>sd",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>ss",
				function()
					Snacks.picker.lsp_symbols()
				end,
				desc = "LSP Symbols",
			},
			{
				"gr",
				function()
					Snacks.picker.lsp_references()
				end,
				desc = "LSP References",
			},
			{
				"gd",
				function()
					Snacks.picker.lsp_definitions({ jump = { reuse_win = false } })
				end,
				desc = "LSP Definitions",
			},

			-- Other useful pickers
			{
				"<leader>sk",
				function()
					Snacks.picker.keymaps()
				end,
				desc = "Keymaps",
			},
			{
				"<leader>sh",
				function()
					Snacks.picker.help()
				end,
				desc = "Help Pages",
			},
			{
				"<leader>sm",
				function()
					Snacks.picker.marks()
				end,
				desc = "Marks",
			},
			{
				"<leader>sj",
				function()
					Snacks.picker.jumps()
				end,
				desc = "Jumps",
			},
			{
				"<leader>su",
				function()
					Snacks.picker.undo()
				end,
				desc = "Undo History",
			},
			{
				"<leader>sp",
				function()
					Snacks.picker()
				end,
				desc = "Pickers",
			},
			{
				'<leader>s"',
				function()
					Snacks.picker.registers()
				end,
				desc = "Registers",
			},
			{
				"<leader>sq",
				function()
					Snacks.picker.qflist()
				end,
				desc = "Quickfix List",
			},
			{
				"<leader>sl",
				function()
					Snacks.picker.loclist()
				end,
				desc = "Location List",
			},

			-- Resume last picker
			{
				"<leader>sR",
				function()
					Snacks.picker.resume()
				end,
				desc = "Resume Picker",
			},

			-- Terminal keymaps
			{
				"<C-/>",
				function()
					Snacks.terminal()
				end,
				desc = "Toggle Terminal",
				mode = { "n", "t" },
			},
			{
				"<C-_>", -- Terminal sees <C-/> as <C-_> in some terminals
				function()
					Snacks.terminal()
				end,
				desc = "Toggle Terminal",
				mode = { "n", "t" },
			},
			{
				"<leader>ft",
				function()
					Snacks.terminal()
				end,
				desc = "Terminal (Root Dir)",
			},
			{
				"<leader>fT",
				function()
					Snacks.terminal(nil, { cwd = vim.fn.expand("%:p:h") })
				end,
				desc = "Terminal (Current Dir)",
			},
			{
				"<leader>gg",
				function()
					local cwd = buffer_cwd()
					Snacks.lazygit({ cwd = Snacks.git.get_root(cwd) or cwd })
				end,
				desc = "Lazygit (Root Dir)",
			},
			{
				"<leader>gG",
				function()
					Snacks.lazygit({ cwd = buffer_cwd() })
				end,
				desc = "Lazygit (Current Dir)",
			},
			{
				"<leader>gf",
				function()
					Snacks.lazygit.log_file()
				end,
				desc = "Lazygit Current File History",
			},
			{
				"<leader>gl",
				function()
					Snacks.lazygit.log()
				end,
				desc = "Lazygit Log",
			},
			{
				"<C-\\>",
				function()
					Snacks.terminal()
				end,
				desc = "Terminal (floating)",
				mode = { "n", "t" },
			},
			-- Zen mode
			{
				"<leader>z",
				function()
					Snacks.zen()
				end,
				desc = "Zen Mode",
			},
		},
		opts = {
			scroll = { enabled = false },

			notifier = { timeout = 5000 },

			dim = {},

			zen = {
				enabled = true,
				toggles = {
					dim = false,
					git_signs = true,
				},
				show = {
					statusline = false,
					tabline = false,
				},
				win = {
					backdrop = { transparent = false },
				},
				-- Integration with tmux and kitty
				on_open = function()
					-- Tmux integration
					if vim.env.TMUX then
						vim.fn.system("tmux set status off")
						vim.fn.system("tmux list-panes -F '#F' | grep -q Z || tmux resize-pane -Z")
					end
					-- Kitty integration
					if vim.env.KITTY_LISTEN_ON then
						vim.fn.system("kitty @ set-font-size +2")
					end
				end,
				on_close = function()
					-- Tmux integration
					if vim.env.TMUX then
						vim.fn.system("tmux set status on")
						vim.fn.system("tmux list-panes -F '#F' | grep -q Z && tmux resize-pane -Z")
					end
					-- Kitty integration
					if vim.env.KITTY_LISTEN_ON then
						vim.fn.system("kitty @ set-font-size -2")
					end
				end,
			},

			-- Disable to working with mini.surround
			input = { enabled = false },

			statuscolumn = { enabled = true },

			image = { enabled = true },

			scope = { enabled = true },

			explorer = { enabled = true },

			lazygit = {
				enabled = true,
				configure = true,
				win = {
					position = "float",
					height = 0.9,
					width = 0.9,
					border = "rounded",
				},
			},

			picker = {
				enabled = true,

				-- UI Configuration
				prompt = " ",
				focus = "input",

				-- Roomier default layout with separation between results and preview
				layout = {
					preset = "default",
					config = function(resolved)
						local root = resolved.layout

						if root.box ~= "horizontal" or not root[2] or root[2].win ~= "preview" then
							return resolved
						end

						root.width = 0.92
						root.height = 0.9
						root[2].width = 0.55

						table.insert(root, 2, {
							box = "vertical",
							width = 2,
						})

						return resolved
					end,
				},

				-- Matching and sorting
				matcher = {
					fuzzy = true,
					smartcase = true,
					filename_bonus = true,
				},

				-- Icons
				icons = {
					files = {
						enabled = true,
					},
					git = {
						enabled = true,
					},
				},

				-- Formatters
				formatters = {
					file = {
						truncate = "right",
					},
				},

				-- Performance
				debounce = 10,

				-- Window options
				win = {
					input = {
						-- A plain-string spec maps normal mode only; the input starts in insert mode.
						keys = {
							["<Esc>"] = "close",
							["<C-c>"] = { "close", mode = { "n", "i" } },
							["<CR>"] = { "confirm", mode = { "n", "i" } },
							["<C-s>"] = { "edit_split", mode = { "n", "i" } },
							["<C-v>"] = { "edit_vsplit", mode = { "n", "i" } },
							["<C-t>"] = { "tab", mode = { "n", "i" } },
							["<Tab>"] = { "select_next", mode = { "n", "i" } },
							["<S-Tab>"] = { "select_prev", mode = { "n", "i" } },
							["<C-j>"] = { "list_down", mode = { "n", "i" } },
							["<C-k>"] = { "list_up", mode = { "n", "i" } },
							["<C-d>"] = { "preview_scroll_down", mode = { "n", "i" } },
							["<C-u>"] = { "preview_scroll_up", mode = { "n", "i" } },
							["<C-q>"] = { "qflist", mode = { "n", "i" } },
							["<a-p>"] = { "toggle_preview", mode = { "n", "i" } },
							["<a-f>"] = { "toggle_follow", mode = { "n", "i" } },
						},
					},
					preview = {
						wo = {
							spell = false,
						},
					},
				},

				-- Source-specific configurations
				sources = {
					files = {
						follow = true,
						hidden = true,
						ignored = true,
					},
					explorer = {
						follow = true,
						hidden = true,
						ignored = true,
					},
					buffers = {
						sort_mru = true,
					},
					grep = {
						hidden = true,
						ignored = true,
						follow = true,
					},
				},
			},

			dashboard = {
				preset = {
					header = [[
╭ · · · · · · · · · · · · · · · · · · · · · · · ╮
·                                               ·
·                < c j s / >                    ·
·                                               ·
·                    ╭───────────────────────╮  ·
·                    │ psst... ship happens. │  ·
·                    ╰───────────╲───────────╯  ·
·                               ╱  ◉ ◉          ·
·                              ╱    ᴗ           ·
·                          ───╱────┬──╼         ·
·                            ╱     │            ·
·                                 ╱ ╲           ·
·                                               ·
·          fig. nvim · the slash is shipping    ·
·                                               ·
╰ · · · · · · · · · · · · · · · · · · · · · · · ╯
]],
				},
				highlight = {
					header = "DashboardHeader",
				},
			},
		},
	},
}
