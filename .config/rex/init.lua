-- Rex configuration. Reload with `rex config reload`; validate with `rex config check`.
-- Docs: https://www.superlogical.com/rex/docs/customize/config

local terminal = "com.superlogical.terminal"

-- The focused pane's directory as a plain path, or nil when the shell never reported one.
-- pwd is a file:// URL when the shell used OSC 7 (fish does), so strip the host and %XX escapes.
local function focused_cwd(block_id)
  local r = rex.block.call(terminal, "pwd", { block_id = block_id })
  if r == nil or r.pwd == nil or r.pwd == "" then return nil end
  local path = r.pwd:gsub("^file://[^/]*", "")
  return (path:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

-- Lazygit in a floating pane over the current tab, opened in the focused pane's repo.
-- The float closes itself when lazygit quits (q).
rex.action{
  name     = "lazygit",
  title    = "Open Lazygit",
  category = "Git",
  keywords = "git lazygit float",
  run      = function(ctx)
    local _, err = rex.session.new_layer{
      bounds = { 0.05, 0.05, 0.9, 0.9 },
      focus  = true,
      layout = rex.layout.block{
        flavor  = terminal .. ".shell",
        options = { command = { "lazygit" }, cwd = focused_cwd(ctx.block_id) },
      },
    }
    if err ~= nil then error(err, 0) end
  end,
}

rex.bind("ctrl+cmd+g", "lazygit")
