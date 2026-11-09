-- Run with nvim --headless -u NONE -l .config/rex/integration-test.lua.
local config_dir = vim.fs.dirname(vim.uv.fs_realpath(arg[0]))
local actions, bindings, layers, pwd, hostname, layer_error, hostname_error
local splits, exec_calls, split_error, exec_error, exec_result, focused, queued
local origin = 'client:origin"; error("unexpected") --'
local context = { client_id = origin, session_id = "session:source", block_id = "block:source" }
local invoked
local old_orc = package.loaded.orc
local old_getenv = os.getenv
local home = '/home/test user "quoted";$()'
os.getenv = function(name)
  if name == "HOME" then return home end
  return old_getenv(name)
end
package.loaded.orc = {
  open = function(opts) invoked = { method = "open", opts = opts } end,
  projects = function(opts) invoked = { method = "projects", opts = opts } end,
  workers = function(opts) invoked = { method = "workers", opts = opts } end,
}

local function load_config()
  actions, bindings, layers, invoked = {}, {}, {}, nil
  splits, exec_calls, focused, queued = {}, {}, nil, {}
  _G.rex = {
    action = function(action) actions[action.name] = action end,
    bind = function(key, action)
      assert(bindings[key] == nil, "Duplicate shortcut: " .. key)
      bindings[key] = action
    end,
    block = {
      call = function(flavor, method, opts)
        assert(flavor == "com.superlogical.terminal" and method == "pwd")
        assert(opts.block_id == context.block_id)
        return pwd and { pwd = pwd } or nil
      end,
    },
    client = { queue = function(name, args) queued[#queued + 1] = { name = name, args = args } end },
    exec = function(argv, opts)
      exec_calls[#exec_calls + 1] = { argv = argv, opts = opts }
      if argv[1] == "hostname" then
        assert(#argv == 1 and opts.timeout == 2)
        if hostname_error then return nil, hostname_error end
        return { ok = true, stdout = hostname or "local-mac\n" }
      end
      if exec_error then return nil, exec_error end
      return exec_result or { ok = true, stdout = '{"status":"pruned"}', stderr = "" }
    end,
    layout = { block = function(block) return block end },
    session = {
      new_layer = function(opts)
        layers[#layers + 1] = opts
        if layer_error then return nil, layer_error end
        return { layer_id = "layer:popup", block_ids = { "block:popup" } }
      end,
      focus_block = function(opts) focused = opts; return {} end,
      new_window = function(opts)
        splits[#splits + 1] = opts
        if split_error then return nil, split_error end
        return { window_id = "window:orc", block_ids = { "block:orchestrator" } }
      end,
    },
  }
  dofile(config_dir .. "/init.lua")
  assert(#layers == 0 and #splits == 0 and #exec_calls == 0, "Loading config must never create resources")
  assert(vim.tbl_count(actions) == 7 and vim.tbl_count(bindings) == 7)
  assert(bindings["ctrl+cmd+g"] == "lazygit")
  assert(bindings["ctrl+cmd+r"] == "tuicr")
  assert(bindings["ctrl+cmd+p"] == "ghq_projects")
  assert(bindings["ctrl+cmd+o"] == "orc_tasks")
  assert(bindings["ctrl+cmd+a"] == "orc_orchestrator")
  assert(bindings["ctrl+cmd+w"] == "orc_workers")
  assert(bindings["ctrl+cmd+x"] == "orc_prune")
end

local function popup(name, ctx)
  local result = actions[name].run(ctx or context)
  assert(result.layer_id == "layer:popup")
  local options = layers[#layers]
  assert(vim.deep_equal(options.bounds, { 0.05, 0.05, 0.9, 0.9 }) and options.focus)
  assert(options.session_id == (ctx or context).session_id)
  assert(options.layout.flavor == "com.superlogical.terminal.shell")
  return options.layout.options
end

local function invoke(options)
  assert(vim.deep_equal(vim.list_slice(options.command, 1, 5), { "nvim", "-n", "-i", "NONE", "-c" }))
  assert(loadstring(options.command[6]:gsub("^lua ", "")))()
  assert(invoked.opts.client_id == origin and invoked.opts.quit_on_close == true)
end

pwd = '/repo literal%20 with "quotes" and \\slashes;$()'
load_config()
assert(vim.deep_equal(popup("lazygit").command, { "lazygit" }))
assert(vim.deep_equal(popup("tuicr").command, { "tuicr" }))
local options = popup("ghq_projects")
assert(options.cwd == pwd)
invoke(options)
assert(invoked.method == "projects" and invoked.opts.cwd == nil)
options = popup("orc_tasks")
invoke(options)
assert(invoked.method == "open" and invoked.opts.cwd == pwd)
options = popup("orc_workers")
invoke(options)
assert(invoked.method == "workers" and invoked.opts.cwd == pwd and options.cwd == pwd)
assert(actions.orc_workers.title == "Jump to Orc Worker" and actions.orc_workers.category == "Orc")
assert(actions.orc_orchestrator.title == "Open Orc Orchestrator")
local result = actions.orc_orchestrator.run(context)
assert(result.block_ids[1] == "block:orchestrator")
assert(vim.deep_equal(focused, { session_id = context.session_id, block_id = "block:orchestrator" }))
assert(vim.deep_equal(queued, {
  { name = "session.select", args = { session_id = context.session_id, window_id = "window:orc" } },
}))
assert(vim.deep_equal(splits[1], {
  session_id = context.session_id,
  window_label = "Orc",
  focus = true,
  layout = { flavor = "com.superlogical.terminal.shell", options = { command = { "orc", "claude" }, cwd = pwd } },
}))
assert(actions.orc_prune.title == "Close Finished Orc Workers")
assert(actions.orc_prune.run(context).output == '{"status":"pruned"}')
assert(vim.deep_equal(exec_calls[1], {
  argv = {
    "/usr/bin/env",
    "PATH=" .. home .. "/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
    home .. "/.local/bin/orc", "pane", "prune", "--path", pwd,
  },
  opts = { cwd = pwd, timeout = 25 },
}))

local cwd_actions = { "orc_tasks", "orc_workers", "orc_orchestrator", "orc_prune" }

for _, url in ipairs({
  "file:///repo%20with%20spaces%3B%24%28%29",
  "file://localhost/repo%20with%20spaces%3B%24%28%29",
  "file://LOCAL-MAC/repo%20with%20spaces%3B%24%28%29",
}) do
  pwd = url
  load_config()
  for _, name in ipairs({ "orc_tasks", "orc_workers" }) do
    options = popup(name)
    assert(options.cwd == "/repo with spaces;$()")
  end
  actions.orc_orchestrator.run(context)
  assert(splits[1].layout.options.cwd == "/repo with spaces;$()")
  actions.orc_prune.run(context)
  assert(exec_calls[#exec_calls].argv[7] == "/repo with spaces;$()")
end

for _, invalid in ipairs({
  "relative/repo", "https://example.org/repo", "file://remote-mac/repo", "file:///repo%00",
  "file:///repo%", "file:///repo%2", "file:///repo%zz", "file://localhost", "file:///repo?query",
  "file:///repo#fragment", "/repo\nunsafe", true,
}) do
  pwd = invalid
  load_config()
  for _, name in ipairs(cwd_actions) do
    assert(not pcall(actions[name].run, context), "Must reject invalid directory: " .. tostring(invalid))
  end
  assert(#layers == 0 and #splits == 0)
end

pwd, hostname_error = "file://local-mac/repo", "hostname unavailable"
load_config()
for _, name in ipairs(cwd_actions) do
  assert(not pcall(actions[name].run, context))
end
assert(#layers == 0 and #splits == 0)
hostname_error = nil

for _, absent in ipairs({ false, "" }) do
  pwd = absent
  load_config()
  for _, name in ipairs(cwd_actions) do
    assert(not pcall(actions[name].run, context))
    assert(not pcall(actions[name].run, { client_id = origin, session_id = context.session_id }))
  end
  assert(#layers == 0 and #splits == 0 and #exec_calls == 0)
  invoke(popup("ghq_projects"))
end

pwd = "/repo"
load_config()
for _, name in ipairs({ "ghq_projects", "orc_tasks", "orc_workers" }) do
  assert(not pcall(actions[name].run, { session_id = context.session_id, block_id = context.block_id }))
  assert(not pcall(actions[name].run, { client_id = "", block_id = context.block_id }))
end
assert(#layers == 0)
for _, name in ipairs(cwd_actions) do
  assert(not pcall(actions[name].run, { client_id = origin, session_id = context.session_id }))
end
assert(#layers == 0 and #splits == 0 and #exec_calls == 0)
assert(not pcall(actions.orc_orchestrator.run, { block_id = context.block_id }) and #splits == 0)
assert(not pcall(actions.orc_orchestrator.run, { session_id = "", block_id = context.block_id }))

layer_error = "layer refused"
load_config()
for _, name in ipairs({ "ghq_projects", "orc_tasks", "orc_workers" }) do
  local ok, err = pcall(actions[name].run, context)
  assert(not ok and err == "layer refused")
end
split_error = "window refused"
local ok, err = pcall(actions.orc_orchestrator.run, context)
assert(not ok and err == "window refused")
exec_error = "orc executable missing"
ok, err = pcall(actions.orc_prune.run, context)
assert(not ok and err == exec_error)
exec_error = nil
for _, failure in ipairs({
  { ok = false, code = 1, stderr = "prune refused" },
  { ok = false, timed_out = true, stderr = "prune timed out" },
}) do
  exec_result = failure
  ok, err = pcall(actions.orc_prune.run, context)
  assert(not ok and err == failure.stderr)
end
exec_result = { ok = false, code = 1, stdout = '{"status":"error"}', stderr = "" }
ok, err = pcall(actions.orc_prune.run, context)
assert(not ok and err == '{"status":"error"}')
exec_result = { ok = false, code = 1, stdout = "", stderr = "" }
ok, err = pcall(actions.orc_prune.run, context)
assert(not ok and err == "Orc worker prune failed")
for _, missing_home in ipairs({ false, "", "relative/home" }) do
  home = missing_home
  load_config()
  assert(not pcall(actions.orc_prune.run, context) and #exec_calls == 0)
end
home = nil
load_config()
assert(not pcall(actions.orc_prune.run, context) and #exec_calls == 0)
os.getenv = old_getenv
package.loaded.orc = old_orc
print("rex integration: all assertions passed")
