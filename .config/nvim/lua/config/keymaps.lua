-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local discipline = require("insideee-dev/discripline")
discipline.cowboy()

local utils = require("insideee-dev.utils")

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "x", '"_x')

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d')

-- Select all
keymap.set("n", "<C-a>a", "gg<S-v>G")

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- Disable continuations
keymap.set("n", "<Leader>o", "o<Esc>^Da", opts)
keymap.set("n", "<Leader>O", "O<Esc>^Da", opts)

-- Jumplist
keymap.set("n", "<C-m>", "<C-i>", opts)

-- New tab
keymap.set("n", "te", ":tabedit")
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)
-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)
-- Move window
keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sl", "<C-w>l")

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

-- Pick a buffer
keymap.set("n", "<Leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>", {})
keymap.set("n", "<Leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>", {})
keymap.set("n", "<Leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>", {})
keymap.set("n", "<Leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>", {})
keymap.set("n", "<Leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>", {})
keymap.set("n", "<Leader>6", "<Cmd>BufferLineGoToBuffer 6<CR>", {})
keymap.set("n", "<Leader>9", "<Cmd>BufferLineGoToBuffer -1<CR>", {})

-- Moving text
-- Move text up and down
keymap.set("n", "<C-Down>", "<Esc>:m .+1<CR>", opts)
keymap.set("n", "<C-Up>", "<Esc>:m .-2<CR>", opts)
keymap.set("v", "<C-Down>", ":m .+1<CR>", opts)
keymap.set("v", "<C-Up>", ":m .-2<CR>", opts)
keymap.set("x", "<C-Down>", ":move '>+1<CR>gv-gv", opts)
keymap.set("x", "<C-Up>", ":move '<-2<CR>gv-gv", opts)

-- Copy to clipboard
keymap.set("n", "<Leader>yr", function()
	utils.copy_to_clipboard()
end, utils.shallow_merge(opts, { desc = "Copy relative path to clipboard" }))

keymap.set("n", "<Leader>yR", function()
	utils.copy_to_clipboard(true)
end, utils.shallow_merge(opts, { desc = "Copy relative path and line number to clipboard" }))

-- Diagnostics
keymap.set("n", "<C-j>", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, opts)

-- Open diagnostic float at current line and enter it
keymap.set("n", "<leader>de", function()
	local float_opts = {
		scope = "line",
		focusable = true,
		focus_id = "diagnostics",
		close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre" },
	}
	vim.diagnostic.open_float(float_opts)

	-- Explicitly move cursor to the floating window
	local win = vim.api.nvim_get_current_win()
	local wins = vim.api.nvim_list_wins()
	for _, w in ipairs(wins) do
		local config = vim.api.nvim_win_get_config(w)
		if config.relative ~= "" and w ~= win then
			vim.api.nvim_set_current_win(w)
			break
		end
	end
end, utils.shallow_merge(opts, { desc = "Enter diagnostic popup at current line" }))

keymap.set("n", "<leader>r", function()
	utils.replace_hex_with_HSL()
end, utils.shallow_merge(opts, { desc = "Replace hex code with HSL" }))

keymap.set("n", "<leader>i", function()
	require("insideee-dev.lsp").toggleInlayHints()
end, utils.shallow_merge(opts, { desc = "Toggle inlay hints" }))

keymap.set("n", "<leader>ob", function()
	local file = vim.fn.expand("%:p")
	-- vim.fn.jobstart({ "xdg-open", file }, { detach = true }) -- Linux
	vim.fn.jobstart({ "open", file }, { detach = true }) -- macOS
	-- vim.fn.jobstart({ "start", file }, { detach = true }) -- Windows
end, { desc = "Open in browser" })
