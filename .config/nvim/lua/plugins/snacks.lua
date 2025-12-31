return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
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

			-- Snacks Picker keymaps
			{
				"<leader><space>",
				function()
					Snacks.picker.files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>ff",
				function()
					Snacks.picker.files()
				end,
				desc = "Find Files",
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
					Snacks.picker.grep()
				end,
				desc = "Grep",
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
					Snacks.picker.lsp_definitions()
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
					Snacks.lazygit()
				end,
				desc = "Lazygit (Root Dir)",
			},
			{
				"<leader>gG",
				function()
					Snacks.lazygit({ cwd = vim.fn.expand("%:p:h") })
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

			dim = {},

			zen = {
				enabled = true,
				toggles = {
					dim = true,
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

				-- Layout options: "default", "vertical", "horizontal", "ivy", "dropdown"
				layout = {
					preset = "default",
					width = 0.8,
					height = 0.8,
					border = "rounded",
					preview = {
						width = 0.5,
					},
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
						keys = {
							["<Esc>"] = "close",
							["<C-c>"] = "close",
							["<CR>"] = "confirm",
							["<C-s>"] = "confirm_split",
							["<C-v>"] = "confirm_vsplit",
							["<C-t>"] = "confirm_tab",
							["<Tab>"] = "select_next",
							["<S-Tab>"] = "select_prev",
							["<C-j>"] = "list_down",
							["<C-k>"] = "list_up",
							["<C-d>"] = "preview_scroll_down",
							["<C-u>"] = "preview_scroll_up",
							["<C-q>"] = "qflist",
							["<a-p>"] = "toggle_preview",
							["<a-f>"] = "toggle_follow",
						},
					},
				},

				-- Source-specific configurations
				sources = {
					files = {
						follow = true,
						hidden = true,
						respect_gitignore = true,
					},
					buffers = {
						sort_mru = true,
					},
					grep = {
						hidden = true,
						follow = true,
					},
				},
			},

			dashboard = {
				preset = {
					header = [[
            ddddddd                                           
            d:::::d                                           
            d:::::d                                           
            d:::::d                                           
            d:::::d                                            
    ddddddddd:::::d     eeeeeeeeeeee  vvvvvvv           vvvvvvv
  dd::::::::::::::d   ee::::::::::::ee v:::::v         v:::::v 
 d::::::::::::::::d  e::::::eeeee:::::eev:::::v       v:::::v  
d:::::::ddddd:::::d e::::::e     e:::::e v:::::v     v:::::v   
d::::::d    d:::::d e:::::::eeeee::::::e  v:::::v   v:::::v    
d:::::d     d:::::d e:::::::::::::::::e    v:::::v v:::::v     
d:::::d     d:::::d e::::::eeeeeeeeeee      v:::::v:::::v      
d:::::d     d:::::d e:::::::e                v:::::::::v       
d::::::ddddd::::::dde::::::::e                v:::::::v        
 d::::::::::::::::d e::::::::eeeeeeee         v:::::v         
  d:::::::::ddd::::d  ee:::::::::::::e          v:::v          
   ddddddddd   ddddd    eeeeeeeeeeeeee           vvv           
                                                               
                                                               
                                                               
          ]],
				},
				highlight = {
					header = "DashboardHeader",
				},
			},
		},
	},
}
