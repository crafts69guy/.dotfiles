-- Minimal Neovim for the Rex orc picker popups, run as `nvim --clean -u <this file>`.
-- Only Snacks, orc and the Hue theme load: no LazyVim dashboard, tabline or statusline.
local home = vim.env.HOME
local repos = home .. "/Developments/github.com/crafts69guy"
-- Same plugin dir as the editor (nvim/lua/config/profile.lua); --clean keeps stdpath.
vim.opt.rtp:prepend({ vim.fn.stdpath("data") .. "/lazy/snacks.nvim", repos .. "/orc.nvim" })
vim.o.laststatus, vim.o.showtabline, vim.o.cmdheight = 0, 0, 0
vim.o.ruler, vim.o.showmode, vim.o.termguicolors = false, false, true

-- Match the editor's current Hue mood (same state file as nvim/lua/config/lazy.lua).
local hue = (vim.env.HUE_THEME_HOME or repos .. "/hue-theme") .. "/packages/nvim-plugin"
if vim.uv.fs_stat(hue) then
  vim.opt.rtp:prepend(hue)
  local state = (vim.env.XDG_STATE_HOME ~= nil and vim.env.XDG_STATE_HOME ~= "" and vim.env.XDG_STATE_HOME)
    or home .. "/.local/state"
  local ok, lines = pcall(vim.fn.readfile, state .. "/hue-theme/current")
  local mood = ok and ({ mua = true, huong = true, cung = true })[lines[1]] and lines[1] or "mua"
  -- A broken theme must not block the picker; the default colors are fine.
  pcall(function()
    require("hue").setup({ transparent = true })
    vim.cmd.colorscheme("hue-" .. mood)
  end)
end

-- The notifier keeps errors in floats; with cmdheight=0 plain messages raise a hit-enter prompt.
require("snacks").setup({ picker = {}, notifier = {} })
