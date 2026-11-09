-- Rex configuration. Reload with `rex config reload`; validate with `rex config check`.
-- Docs: https://www.superlogical.com/rex/docs/customize/config

local terminal = "com.superlogical.terminal"

-- The focused pane's directory as a plain path, or nil when nothing reported one.
local function focused_cwd(block_id)
  if not block_id then return nil end
  local r = rex.block.call(terminal, "pwd", { block_id = block_id })
  local path = r and r.pwd
  if path == nil or path == "" then
    -- Programs started without a shell (claude, orc workers) never send OSC 7; use the process's own cwd.
    local p = rex.block.call(terminal, "process", { block_id = block_id })
    local fg = p and (p.foreground or p.child)
    path = fg and fg.cwd
    if path == nil or path == "" then return nil end
  end
  assert(type(path) == "string", "Rex pane reported an invalid directory")
  if path:sub(1, 7) == "file://" then
    local host
    host, path = path:match("^file://([^/]*)(/.*)$")
    assert(path and not path:find("[?#]"), "Rex pane reported an invalid file URL")
    if host ~= "" and host:lower() ~= "localhost" then
      local hostname, err = rex.exec({ "hostname" }, { timeout = 2 })
      assert(hostname and hostname.ok, err or "Cannot verify the Rex pane's local host")
      assert(host:lower() == hostname.stdout:gsub("%s+$", ""):lower(), "Rex pane directory belongs to another host")
    end
    assert(not path:gsub("%%(%x%x)", ""):find("%%"), "Rex pane reported invalid URL encoding")
    path = path:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
  end
  assert(path:sub(1, 1) == "/" and not path:find("%c"), "Rex pane directory must be an absolute local path")
  return path
end

-- A TUI in a floating pane over the current tab, opened in the focused pane's repo.
-- The float closes itself when the program quits.
local function float_action(name, title, command, needs_cwd, bounds)
  rex.action{
    name     = name,
    title    = title,
    category = name:match("^orc_") and "Orc" or "Git",
    keywords = "git float " .. name,
    run      = function(ctx)
      local cwd = focused_cwd(ctx.block_id)
      assert(not needs_cwd or cwd, "The focused pane has not reported a project directory")
      local layer, err = rex.session.new_layer{
        session_id = ctx.session_id,
        bounds = bounds or { 0.05, 0.05, 0.9, 0.9 },
        focus  = true,
        layout = rex.layout.block{
          flavor  = terminal .. ".shell",
          options = {
            command = type(command) == "function" and command(ctx, cwd) or command,
            cwd = cwd,
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

local function orc_popup(method)
  return function(ctx, cwd)
    assert(ctx.client_id and ctx.client_id ~= "", "Open the orc popup from a Rex app")
    local options = ("client_id=%q,quit_on_close=true"):format(ctx.client_id)
    if method == "open" or method == "workers" then options = options .. (",cwd=%q"):format(cwd) end
    local home = os.getenv("HOME")
    assert(home and home:sub(1, 1) == "/", "HOME must be an absolute path to locate orc-popup.lua")
    -- --clean skips LazyVim (dashboard, tabline, statusline); orc-popup.lua loads only what the popup needs.
    return {
      "nvim", "--clean", "-u", home .. "/.config/rex/orc-popup.lua", "-n", "-c",
      ("lua require('orc').%s({%s})"):format(method, options),
    }
  end
end

-- Pickers fill their popup, so a small centered layer keeps the current tab visible around them.
local picker_bounds = { 0.25, 0.2, 0.5, 0.6 }
float_action("ghq_projects", "Open GHQ Repository in New Session", orc_popup("projects"), false, picker_bounds)
float_action("orc_tasks", "Open Orc Tasks", orc_popup("open"), true)
float_action("orc_workers", "Jump to Orc Worker", orc_popup("workers"), true, picker_bounds)

rex.action{
  name = "orc_orchestrator",
  title = "Open Orc Orchestrator",
  category = "Orc",
  run = function(ctx)
    local cwd = focused_cwd(ctx.block_id)
    assert(cwd, "The focused pane has not reported a project directory")
    assert(ctx.session_id and ctx.session_id ~= "", "Open the orc orchestrator from a Rex session")
    -- A new tab, like Cmd+T, so the orchestrator gets the full window.
    local window, err = rex.session.new_window{
      session_id = ctx.session_id,
      window_label = "Orc",
      focus = true,
      layout = rex.layout.block{
        flavor = terminal .. ".shell",
        options = { command = { "orc", "claude" }, cwd = cwd },
      },
    }
    if err ~= nil then error(err, 0) end
    -- Put keyboard focus on the orchestrator's terminal, not just the tab.
    local block = window.block_ids and window.block_ids[1]
    assert(block, "Rex did not report the orchestrator's pane")
    local _, focus_err = rex.session.focus_block{ session_id = ctx.session_id, block_id = block }
    if focus_err ~= nil then error(focus_err, 0) end
    -- The app keeps its own tab selection; queue the switch on the app that ran the shortcut.
    if ctx.client_id and ctx.client_id ~= "" then
      rex.client.queue("session.select", { session_id = ctx.session_id, window_id = window.window_id })
    end
    return window
  end,
}

rex.action{
  name = "orc_prune",
  title = "Close Finished Orc Workers",
  category = "Orc",
  run = function(ctx)
    local cwd = focused_cwd(ctx.block_id)
    assert(cwd, "The focused pane has not reported a project directory")
    local home = os.getenv("HOME")
    assert(home and home:sub(1, 1) == "/", "HOME must be an absolute path to locate orc")
    -- The Rex server's PATH is /usr/bin:/bin, but bin/orc's shebang needs nvim.
    local path = home .. "/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    local result, err = rex.exec(
      { "/usr/bin/env", "PATH=" .. path, home .. "/.local/bin/orc", "pane", "prune", "--path", cwd },
      { cwd = cwd, timeout = 25 })
    if result == nil then error(err, 0) end
    if not result.ok then
      -- orc reports failures as JSON on stdout.
      local message = result.stderr
      if not message or message == "" then message = result.stdout end
      if not message or message == "" then message = "Orc worker prune failed" end
      error(message, 0)
    end
    return { output = result.stdout }
  end,
}

rex.bind("ctrl+cmd+g", "lazygit")
rex.bind("ctrl+cmd+r", "tuicr")
rex.bind("ctrl+cmd+p", "ghq_projects")
rex.bind("ctrl+cmd+o", "orc_tasks")
rex.bind("ctrl+cmd+a", "orc_orchestrator")
rex.bind("ctrl+cmd+w", "orc_workers")
rex.bind("ctrl+cmd+x", "orc_prune")
