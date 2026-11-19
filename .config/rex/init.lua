-- Rex configuration. Reload with `rex config reload`; validate with `rex config check`.
-- Docs: https://www.superlogical.com/rex/docs/customize/config

local terminal = "com.superlogical.terminal"
local projects = require("ghq-projects")

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

local function open_float(ctx, options, bounds)
  local layer, err = rex.session.new_layer{
    session_id = ctx.session_id,
    bounds = bounds or { 0.05, 0.05, 0.9, 0.9 },
    focus = true,
    layout = rex.layout.block{ flavor = terminal .. ".shell", options = options },
  }
  if err ~= nil then error(err, 0) end
  return layer
end

local function git_float_action(name, title, command, git_only, args)
  rex.action{
    name     = name,
    title    = title,
    category = "Git",
    keywords = "git float " .. name,
    args     = args,
    run      = function(ctx, opts)
      projects.require_local(ctx)
      local cwd = focused_cwd(ctx.block_id)
      assert(cwd, "The focused pane has not reported a project directory")
      local argv
      if type(command) == "function" then
        argv = command(cwd, opts)
        if not argv then return end
      else
        projects.validate_tool_cwd(cwd, git_only)
        argv = command
      end
      return open_float(ctx, { cwd = cwd, command = argv, interactive = true })
    end,
  }
end

git_float_action("lazygit", "Open Lazygit", { "lazygit" }, true)
git_float_action("tuicr", "Open Tuicr Review", { "tuicr", "-w" })
git_float_action("tuicr_review_branch", "Review Branch…", function(cwd, args)
  local range = projects.review_range(cwd, args and args.base)
  if range then return { "tuicr", "-r", range } end
end, true, { base = "string?" })

rex.action{
  name = "ghq_projects",
  title = "Open GHQ Repository in New Session",
  category = "Git",
  keywords = "ghq project repository checkout",
  args = { project = "string?" },
  run = projects.open_project,
}

rex.action{
  name = "git_worktrees",
  title = "Open or Create Git Worktree…",
  category = "Git",
  keywords = "project repository checkout worktree branch",
  run = function(ctx)
    projects.require_local(ctx)
    local cwd = focused_cwd(ctx.block_id)
    assert(cwd, "The focused pane has not reported a project directory")
    return projects.open_worktrees(ctx, cwd)
  end,
}

local function orc_popup(name, title, method, bounds)
  rex.action{
    name = name,
    title = title,
    category = "Orc",
    keywords = "git float " .. name,
    run = function(ctx)
      local cwd = focused_cwd(ctx.block_id)
      assert(cwd, "The focused pane has not reported a project directory")
      assert(ctx.client_id and ctx.client_id ~= "", "Open the orc popup from a Rex app")
      local options = ("client_id=%q,quit_on_close=true,cwd=%q"):format(ctx.client_id, cwd)
      local home = os.getenv("HOME")
      assert(home and home:sub(1, 1) == "/", "HOME must be an absolute path to locate orc-popup.lua")
      -- --clean skips LazyVim (dashboard, tabline, statusline); orc-popup.lua loads only what the popup needs.
      local command = {
        "nvim", "--clean", "-u", home .. "/.config/rex/orc-popup.lua", "-n", "-c",
        ("lua require('orc').%s({%s})"):format(method, options),
      }
      return open_float(ctx, { cwd = cwd, command = command }, bounds)
    end,
  }
end

orc_popup("orc_tasks", "Open Orc Tasks", "open")
orc_popup("orc_workers", "Jump to Orc Worker", "workers", { 0.25, 0.2, 0.5, 0.6 })

rex.action{
  name = "copy_pane_id",
  title = "Copy Block ID from Picker…",
  category = "Pane",
  keywords = "copy pane block id clipboard selector session",
  run = function(ctx)
    local inventory, list_err = rex.call("session.list")
    if not inventory then error(list_err, 0) end

    local items, seen = {}, {}
    local attached_all = false
    for _, session in ipairs(inventory.sessions or {}) do
      local view, view_err = rex.session.view{ session_id = session.session_id }
      -- Keep the caller's event scope when it can already read the session.
      if not view and not attached_all and view_err:find("stream is not attached to session", 1, true) then
        local attached, attach_err = rex.call("session.attach_all", { event_scope = "session" })
        if not attached then error(attach_err, 0) end
        attached_all = true
        view, view_err = rex.session.view{ session_id = session.session_id }
      end
      if not view then rex.log("warn", view_err) end
      local name = session.label ~= "" and session.label or session.session_id
      for index, window in ipairs(view and view.windows or {}) do
        local tab = window.label or ("Tab " .. index)
        for _, layer in ipairs(window.layers or {}) do
          for _, block in ipairs(layer.blocks or {}) do
            local id = block.block_id
            if not seen[id] then
              seen[id] = true
              items[#items + 1] = {
                id = id,
                title = name .. " / " .. tab .. " / " .. (block.label or block.flavor),
                subtitle = id,
                detail = id == ctx.block_id and "Focused" or nil,
              }
            end
          end
        end
      end
    end
    assert(#items > 0, "There are no available panes on this Rex server")

    local block_id, reason, detail = rex.ui.pick{
      title = "Copy Block ID",
      placeholder = "Filter by session, tab, pane, or ID",
      items = items,
    }
    if reason == "cancelled" then return end
    if not block_id then error(detail or ("Rex picker: " .. tostring(reason)), 0) end

    local result, copy_err = rex.exec({ "/usr/bin/pbcopy" }, { stdin = block_id, timeout = 2 })
    if not result then error(copy_err, 0) end
    assert(result.ok, result.stderr ~= "" and result.stderr or "Could not copy the block ID")

    local alert, alert_err = rex.exec({
      "/usr/bin/osascript", "-e", 'display alert "Block ID copied" giving up after 2',
    }, { timeout = 5 })
    if not alert or not alert.ok then
      rex.log("warn", alert_err or ("Could not show copy confirmation: " .. alert.stderr))
    end
    return { block_id = block_id }
  end,
}

rex.action{
  name = "new_dev_session",
  title = "New Session in Developments",
  category = "Session",
  run = function(ctx)
    assert(ctx.client_id and ctx.client_id ~= "", "Open the new session from a Rex app")
    local home = os.getenv("HOME")
    assert(home and home:sub(1, 1) == "/", "HOME must be an absolute path to locate Developments")
    local session, err = rex.call("session.create", {
      initial_windows = {{
        layout = rex.layout.block{
          flavor = terminal .. ".shell",
          options = { cwd = home .. "/Developments" },
        },
      }},
    })
    if err ~= nil then error(err, 0) end
    rex.client.queue("session.select", { session_id = session.session_id })
    return session
  end,
}

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

rex.bind("shift+cmd+n", "new_dev_session")
rex.bind("ctrl+cmd+g", "lazygit")
rex.bind("ctrl+cmd+r", "tuicr")
rex.bind("ctrl+cmd+p", "ghq_projects")
rex.bind("ctrl+cmd+o", "orc_tasks")
rex.bind("ctrl+cmd+a", "orc_orchestrator")
rex.bind("ctrl+cmd+w", "orc_workers")
rex.bind("ctrl+cmd+x", "orc_prune")
rex.bind("ctrl+shift+cmd+i", "copy_pane_id")
