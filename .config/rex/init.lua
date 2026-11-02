-- Rex configuration. Reload with `rex config reload`; validate with `rex config check`.
-- Docs: https://www.superlogical.com/rex/docs/customize/config

local terminal = "com.superlogical.terminal"
local config_dir = debug.getinfo(1, "S").source:gsub("^@", ""):match("^(.*)/")

-- The focused pane's directory as a plain path, or nil when the shell never reported one.
-- pwd is a file:// URL when the shell used OSC 7 (fish does), so strip the host and %XX escapes.
local function focused_cwd(block_id)
  local r = rex.block.call(terminal, "pwd", { block_id = block_id })
  if r == nil or r.pwd == nil or r.pwd == "" then return nil end
  local path = r.pwd:gsub("^file://[^/]*", "")
  return (path:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

-- A TUI in a floating pane over the current tab, opened in the focused pane's repo.
-- The float closes itself when the program quits.
local function float_action(name, title, command)
  rex.action{
    name     = name,
    title    = title,
    category = "Git",
    keywords = "git float " .. name,
    run      = function(ctx)
      local layer, err = rex.session.new_layer{
        bounds = { 0.05, 0.05, 0.9, 0.9 },
        focus  = true,
        layout = rex.layout.block{
          flavor  = terminal .. ".shell",
          options = {
            command = type(command) == "function" and command(ctx) or command,
            cwd = focused_cwd(ctx.block_id),
          },
        },
      }
      if err ~= nil then error(err, 0) end
      return layer
    end,
  }
end

float_action("lazygit", "Open Lazygit", { "lazygit" })
float_action("tuicr", "Open Tuicr Review", { "tuicr" })
float_action("ghq_projects", "Open GHQ Repository in New Session", function(ctx)
  assert(ctx.client_id, "Open the repository picker from a Rex app")
  return {
    "nvim", "-n", "-i", "NONE", "-c",
    ("lua dofile(%q)(%q)"):format(config_dir .. "/ghq-picker.lua", ctx.client_id),
  }
end)

rex.bind("ctrl+cmd+g", "lazygit")
rex.bind("ctrl+cmd+r", "tuicr")
rex.bind("ctrl+cmd+p", "ghq_projects")
