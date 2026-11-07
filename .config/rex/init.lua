-- Rex configuration. Reload with `rex config reload`; validate with `rex config check`.
-- Docs: https://www.superlogical.com/rex/docs/customize/config

local terminal = "com.superlogical.terminal"

-- The focused pane's directory as a plain path, or nil when the shell never reported one.
local function focused_cwd(block_id)
  if not block_id then return nil end
  local r = rex.block.call(terminal, "pwd", { block_id = block_id })
  if r == nil or r.pwd == nil or r.pwd == "" then return nil end
  assert(type(r.pwd) == "string", "Rex pane reported an invalid directory")
  local path = r.pwd
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
local function float_action(name, title, command, needs_cwd)
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
        bounds = { 0.05, 0.05, 0.9, 0.9 },
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
    return {
      "nvim", "-n", "-i", "NONE", "-c",
      ("lua require('orc').%s({%s})"):format(method, options),
    }
  end
end

float_action("ghq_projects", "Open GHQ Repository in New Session", orc_popup("projects"))
float_action("orc_tasks", "Open Orc Tasks", orc_popup("open"), true)
float_action("orc_workers", "Jump to Orc Worker", orc_popup("workers"), true)

rex.action{
  name = "orc_orchestrator",
  title = "Open Orc Orchestrator",
  category = "Orc",
  run = function(ctx)
    local cwd = focused_cwd(ctx.block_id)
    assert(cwd, "The focused pane has not reported a project directory")
    assert(ctx.session_id and ctx.session_id ~= "", "Open the orc orchestrator from a Rex session")
    local split, err = rex.session.new_split{
      session_id = ctx.session_id,
      anchor_id = ctx.block_id,
      direction = "horizontal",
      side = "after",
      focus = true,
      layout = rex.layout.block{
        flavor = terminal .. ".shell",
        options = { command = { "orc", "claude" }, cwd = cwd },
      },
    }
    if err ~= nil then error(err, 0) end
    return split
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
