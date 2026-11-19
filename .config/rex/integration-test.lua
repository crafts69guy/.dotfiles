-- Run with nvim --headless -u NONE -l .config/rex/integration-test.lua.
local config_dir = vim.fs.dirname(vim.uv.fs_realpath(arg[0]))
local actions, bindings, layers, pwd, hostname, layer_error, hostname_error
local splits, exec_calls, split_error, exec_error, exec_result, focused, queued, proc_cwd
local creations, creation_error
local prompts, answers, project_exec, queue_error, warnings, invalid_session
local created_session = { session_id = "session:developments" }
local origin = 'client:origin"; error("unexpected") --'
local context = { origin = "palette", client_id = origin, session_id = "session:source", block_id = "block:source" }
local cli_context = { origin = "cli", client_id = "client:cli" }
local invoked
local old_orc = package.loaded.orc
local old_getenv = os.getenv
local old_path = package.path
package.path = config_dir .. "/?.lua;" .. package.path
local home = '/home/test user "quoted";$()'
os.getenv = function(name)
  if name == "HOME" then return home end
  if name == "PATH" then return "/usr/bin:/bin" end
  return old_getenv(name)
end
package.loaded.orc = {
  open = function(opts) invoked = { method = "open", opts = opts } end,
  workers = function(opts) invoked = { method = "workers", opts = opts } end,
}

local function prompt(method, opts)
  prompts[#prompts + 1] = { method = method, opts = opts }
  local answer = assert(table.remove(answers, 1), "Unexpected Rex prompt: " .. opts.title)
  if type(answer) == "function" then return answer(method, opts) end
  return answer.value, answer.reason, answer.detail
end

local function success(stdout)
  return { ok = true, stdout = stdout or "", stderr = "" }
end

local function load_config()
  actions, bindings, layers, invoked = {}, {}, {}, nil
  splits, exec_calls, focused, queued = {}, {}, nil, {}
  creations = {}
  prompts, answers, warnings = {}, {}, {}
  _G.rex = {
    action = function(action) actions[action.name] = action end,
    bind = function(key, action)
      assert(bindings[key] == nil, "Duplicate shortcut: " .. key)
      bindings[key] = action
    end,
    call = function(method, opts)
      creations[#creations + 1] = { method = method, opts = opts }
      if creation_error then return nil, creation_error end
      if invalid_session then return {} end
      return created_session
    end,
    block = {
      call = function(flavor, method, opts)
        assert(flavor == "com.superlogical.terminal" and (method == "pwd" or method == "process"))
        assert(opts.block_id == context.block_id)
        if method == "process" then return proc_cwd and { foreground = { cwd = proc_cwd } } or nil end
        return pwd and { pwd = pwd } or nil
      end,
    },
    client = { queue = function(name, args)
      if queue_error then error(queue_error, 0) end
      queued[#queued + 1] = { name = name, args = args }
    end },
    ui = {
      input = function(opts) return prompt("input", opts) end,
      pick = function(opts) return prompt("pick", opts) end,
    },
    log = function(level, message) warnings[#warnings + 1] = { level, message } end,
    exec = function(argv, opts)
      exec_calls[#exec_calls + 1] = { argv = argv, opts = opts }
      if argv[1] == "hostname" then
        assert(#argv == 1 and opts.timeout == 2)
        if hostname_error then return nil, hostname_error end
        return { ok = true, stdout = hostname or "local-mac\n" }
      end
      if argv[3] ~= (home or "") .. "/.local/bin/orc" then
        if project_exec then return project_exec(argv, opts) end
        if argv[1] == "/bin/test" then return success() end
        if argv[3] == "git" and argv[4] == "rev-parse" then
          return success(argv[5] == "--show-toplevel" and (opts.cwd .. "\n") or (opts.cwd .. "/.git\nfalse\n"))
        end
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
  assert(#layers == 0 and #splits == 0 and #exec_calls == 0 and #creations == 0 and #queued == 0 and #prompts == 0,
    "Loading config must never create resources")
  assert(vim.tbl_count(actions) == 11 and vim.tbl_count(bindings) == 9)
  assert(bindings["shift+cmd+n"] == "new_dev_session")
  assert(bindings["ctrl+cmd+g"] == "lazygit")
  assert(bindings["ctrl+cmd+r"] == "tuicr")
  assert(bindings["ctrl+cmd+p"] == "ghq_projects")
  assert(bindings["ctrl+cmd+o"] == "orc_tasks")
  assert(bindings["ctrl+cmd+a"] == "orc_orchestrator")
  assert(bindings["ctrl+cmd+w"] == "orc_workers")
  assert(bindings["ctrl+cmd+x"] == "orc_prune")
  assert(bindings["ctrl+shift+cmd+i"] == "copy_pane_id")
end

local picker_actions = { orc_workers = true }

local function popup(name, ctx)
  local result = actions[name].run(ctx or context)
  assert(result.layer_id == "layer:popup")
  local options = layers[#layers]
  local bounds = picker_actions[name] and { 0.25, 0.2, 0.5, 0.6 } or { 0.05, 0.05, 0.9, 0.9 }
  assert(vim.deep_equal(options.bounds, bounds) and options.focus)
  assert(options.session_id == (ctx or context).session_id)
  assert(options.layout.flavor == "com.superlogical.terminal.shell")
  return options.layout.options
end

local function invoke(options)
  assert(vim.deep_equal(vim.list_slice(options.command, 1, 6),
    { "nvim", "--clean", "-u", home .. "/.config/rex/orc-popup.lua", "-n", "-c" }))
  assert(loadstring(options.command[7]:gsub("^lua ", "")))()
  assert(invoked.opts.client_id == origin and invoked.opts.quit_on_close == true)
end

pwd = '/repo literal%20 with "quotes" and \\slashes;$()'
load_config()
local attached = 0
rex.call = function(method, opts)
  if method == "session.attach_all" then
    assert(opts.event_scope == "session")
    attached = attached + 1
    return {}
  end
  assert(method == "session.list")
  return { sessions = {
    { session_id = context.session_id, label = "Source" },
    { session_id = "session:closed", label = "Closed" },
    { session_id = "session:work", label = "Work" },
  } }
end
rex.session.view = function(opts)
  if opts.session_id == "session:closed" then return nil, "Session closed" end
  if opts.session_id == context.session_id then
    return { windows = { { label = "Shell", layers = { { blocks = {
      { block_id = context.block_id, label = "shell" },
    } } } } } }
  end
  assert(opts.session_id == "session:work")
  if attached == 0 then return nil, "stream is not attached to session (status=409 code=conflict)" end
  return { windows = {
    { label = "Logs", layers = {
      { blocks = {
        { block_id = "block:logs", label = "tail" },
        { block_id = context.block_id, label = "moved shell" },
      } },
      { kind = "floating", blocks = { { block_id = "block:popup", flavor = "terminal.shell" } } },
    } },
  } }
end
answers = {
  { value = "block:popup" }, { reason = "cancelled" }, { reason = "no_client" },
  { value = "block:logs" }, { value = "block:logs" },
}
assert(actions.copy_pane_id.run(context).block_id == "block:popup")
assert(prompts[1].method == "pick" and vim.deep_equal(prompts[1].opts.items, {
  { id = context.block_id, title = "Source / Shell / shell", subtitle = context.block_id, detail = "Focused" },
  { id = "block:logs", title = "Work / Logs / tail", subtitle = "block:logs" },
  { id = "block:popup", title = "Work / Logs / terminal.shell", subtitle = "block:popup" },
}))
assert(vim.deep_equal(warnings, { { "warn", "Session closed" } }))
assert(actions.copy_pane_id.run(context) == nil)
local picked, pick_err = pcall(actions.copy_pane_id.run, context)
assert(not picked and pick_err == "Rex picker: no_client")
assert(vim.deep_equal(exec_calls, {
  { argv = { "/usr/bin/pbcopy" }, opts = { stdin = "block:popup", timeout = 2 } },
  { argv = { "/usr/bin/osascript", "-e", 'display alert "Block ID copied" giving up after 2' }, opts = { timeout = 5 } },
}))
exec_result = { ok = false, stderr = "Clipboard unavailable" }
local copied, copy_err = pcall(actions.copy_pane_id.run, context)
assert(not copied and copy_err:find("Clipboard unavailable", 1, true))
assert(#exec_calls == 3 and exec_calls[3].argv[1] == "/usr/bin/pbcopy")
exec_result = nil
project_exec = function(argv)
  if argv[1] == "/usr/bin/osascript" then return nil, "Alert unavailable" end
  return success()
end
assert(actions.copy_pane_id.run(context).block_id == "block:logs")
assert(vim.deep_equal(warnings[#warnings], { "warn", "Alert unavailable" }))
project_exec = nil
assert(attached == 1 and focused == nil and #queued == 0)

load_config()
assert(actions.new_dev_session.run({ client_id = origin }) == created_session)
assert(vim.deep_equal(creations, {{
  method = "session.create",
  opts = { initial_windows = {{
    layout = { flavor = "com.superlogical.terminal.shell", options = { cwd = home .. "/Developments" } },
  }} },
}}))
assert(vim.deep_equal(queued, {
  { name = "session.select", args = { session_id = created_session.session_id } },
}))
load_config()
for _, ctx in ipairs({ {}, { client_id = "" } }) do
  assert(not pcall(actions.new_dev_session.run, ctx))
end
assert(#creations == 0 and #queued == 0)
creation_error = "session refused"
local created, creation_err = pcall(actions.new_dev_session.run, context)
assert(not created and creation_err == creation_error and #creations == 1 and #queued == 0)
creation_error = nil
load_config()
assert(vim.deep_equal(popup("lazygit").command, { "lazygit" }))
assert(vim.deep_equal(popup("tuicr").command, { "tuicr", "-w" }))
exec_calls = {}
local options = popup("orc_tasks")
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
end

-- A pane running claude directly never sends OSC 7: fall back to the foreground process's cwd.
for _, absent in ipairs({ false, "" }) do
  pwd, proc_cwd = absent, "/repo from process"
  load_config()
  assert(popup("lazygit").cwd == proc_cwd and popup("tuicr").cwd == proc_cwd)
  options = popup("orc_tasks")
  invoke(options)
  assert(invoked.opts.cwd == proc_cwd)
  actions.orc_orchestrator.run(context)
  assert(splits[1].layout.options.cwd == proc_cwd)
  proc_cwd = "relative/repo"
  load_config()
  assert(not pcall(actions.orc_tasks.run, context) and #layers == 0)
end
proc_cwd = nil

pwd = "/repo"
load_config()
for _, name in ipairs({ "orc_tasks", "orc_workers" }) do
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
for _, name in ipairs({ "orc_tasks", "orc_workers" }) do
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
  assert(not pcall(actions.new_dev_session.run, context) and #creations == 0 and #queued == 0)
end
home = nil
load_config()
assert(not pcall(actions.orc_prune.run, context) and #exec_calls == 0)
assert(not pcall(actions.new_dev_session.run, context) and #creations == 0 and #queued == 0)

home = '/home/test user "quoted";$()'
exec_result, layer_error = nil, nil
local path_env = "PATH=/usr/bin:/bin:" .. home .. "/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
local main = "/ghq/github.com/owner/répo space"
local other = "/other-ghq/github.com/duplicate/répo space"
local linked = main .. " linked"
local detached = main .. " détaché ;$()"
local stale = main .. " stale"
local missing = main .. " missing locked"
local bare = "/ghq/github.com/owner/bare"
local common, bare_common = main .. "/.git", bare .. "/.git"
local oid, merge = string.rep("a", 40), string.rep("b", 40)
local function record(path, fields)
  return "worktree " .. path .. "\0" .. table.concat(fields, "\0") .. "\0\0"
end

local main_entry = record(main, { "HEAD " .. oid, "branch refs/heads/production" })
local linked_entry = record(linked, { "HEAD " .. oid, "branch refs/heads/topic", "locked a reason\nwith a newline" })
local detached_entry = record(detached, { "HEAD " .. oid, "detached" })
local unavailable_entries = record(stale, { "HEAD " .. oid, "branch refs/heads/stale", "prunable metadata" })
  .. record(missing, { "HEAD " .. oid, "branch refs/heads/missing", "locked" })
local worktrees, ghq_response, ghq_error, remove_path, changed_root, changed_branch, changed_base, wt_error, plain_bare

local function fixture()
  worktrees, ghq_response = main_entry .. linked_entry .. detached_entry .. unavailable_entries,
    success(other .. "\n" .. main .. "\n" .. main .. "\n" .. bare .. "\n")
  ghq_error, remove_path, changed_root, changed_branch, changed_base, wt_error, plain_bare = nil, nil, nil, nil, nil, nil, nil
  pwd = main
  load_config()
end

local status_one = { ok = false, code = 1 }
project_exec = function(argv, opts)
  local cwd = opts.cwd
  assert(opts.timeout == 5)
  if argv[1] == "/bin/test" then
    assert(argv[2] == "-d" and cwd == nil)
    if argv[3] == missing or argv[3] == remove_path then return status_one end
    return success()
  end
  if argv[1] == "/bin/pwd" then
    assert(argv[2] == "-P")
    return success(cwd .. "\n")
  end
  assert(argv[1] == "/usr/bin/env" and argv[2] == path_env)
  if argv[3] == "ghq" then
    assert(cwd == nil and vim.deep_equal(vim.list_slice(argv, 4), { "list", "--full-path", "--vcs", "git" }))
    if ghq_error then return nil, ghq_error end
    return ghq_response
  end
  if argv[3] == "wt" or argv[3] == "fish" then
    assert(cwd == main and argv[4] == "--version")
    if argv[3] == "wt" and wt_error then return nil, wt_error end
    return success()
  end
  assert(argv[3] == "git")
  local op = argv[4]
  if op == "rev-parse" then
    if argv[5] == "--path-format=absolute" then
      if cwd == bare then return success((plain_bare and bare or bare_common) .. "\ntrue\n") end
      if cwd == bare .. "/topic" then return success((plain_bare and bare or bare_common) .. "\nfalse\n") end
      return success((cwd == changed_root and "/unrelated/.git" or common) .. "\nfalse\n")
    end
    if argv[5] == "--show-toplevel" then return success((cwd == linked .. "/src" and linked or cwd) .. "\n") end
    assert(argv[5] == "--verify" and argv[6] == "--end-of-options")
    if argv[7] == "refs/heads/production^{commit}" or argv[7] == "HEAD^{commit}" then
      return success((changed_base and merge or oid) .. "\n")
    end
    return { ok = false, code = 128, stderr = "fatal: Needed a single revision" }
  elseif op == "worktree" then
    assert(vim.deep_equal(vim.list_slice(argv, 5), { "list", "--porcelain", "-z" }))
    if cwd == bare then
      return success(record(plain_bare and bare or bare_common, { "bare" })
        .. record(bare .. "/topic", { "HEAD " .. oid, "branch refs/heads/topic" }))
    end
    return success(worktrees)
  elseif op == "symbolic-ref" then
    assert(vim.deep_equal(vim.list_slice(argv, 5), { "--quiet", "HEAD" }))
    if cwd == detached then return status_one end
    return success("refs/heads/" .. (changed_branch or (cwd == main and "production" or "topic")) .. "\n")
  elseif op == "check-ref-format" then
    assert(argv[5] == "--branch")
    if argv[6] == "bad branch" then return { ok = false, code = 128, stderr = "fatal: invalid branch name" } end
    return success(argv[6] .. "\n")
  elseif op == "show-ref" then
    assert(argv[5] == "--verify" and argv[6] == "--quiet")
    return argv[7] == "refs/heads/unattached" and success() or status_one
  elseif op == "for-each-ref" then
    assert(argv[7] == "refs/heads/")
    return success("refs/heads/production\nrefs/heads/topic\nrefs/heads/unattached\n")
  elseif op == "merge-base" then
    assert(argv[5] == oid and argv[6] == "HEAD" and cwd == linked .. "/src")
    return success(merge .. "\n")
  end
  error("Unexpected subprocess: " .. vim.inspect(argv))
end

local function choose(value) return { value = value } end
local cancel = { reason = "cancelled" }
local function fails(name, message, ctx, args)
  local succeeded, failure = pcall(actions[name].run, ctx or context, args)
  assert(not succeeded and tostring(failure):find(message, 1, true), tostring(failure))
  assert(#layers == 0 and #queued == 0)
end
local function launched(cwd, name)
  assert(#creations == 1 and #layers == 0)
  assert(creations[1].method == "session.create" and creations[1].opts.label == name)
  local window = creations[1].opts.initial_windows[1]
  assert(window.window_label == "Shell" and window.layout.flavor == "com.superlogical.terminal.shell")
  assert(window.layout.options.cwd == cwd)
  return window.layout.options
end

fixture()
answers = {
  function(method, opts)
    assert(method == "pick" and #exec_calls == 1 and #opts.items == 3)
    assert(vim.deep_equal(opts.items[2], { id = main, title = "répo space", subtitle = main, icon = "folder" }))
    assert(vim.deep_equal(opts.items[3], { id = other, title = "répo space", subtitle = other, icon = "folder" }))
    return main
  end,
  function(method, opts)
    local items = opts.items
    assert(method == "pick" and #items == 4)
    assert(items[1].id == main and items[1].title == "production")
    assert(items[2].id == linked and items[2].title == "topic" and items[2].detail == "Locked")
    assert(items[3].id == detached and items[3].title == "Detached HEAD" and items[3].detail == oid:sub(1, 12))
    assert(items[4].id == "create")
    return linked
  end,
}
assert(actions.ghq_projects.run(context) == created_session)
assert(launched(linked, "répo space · topic").command == nil)
assert(#queued == 1 and queued[1].name == "session.select" and queued[1].args.session_id == created_session.session_id)

fixture()
worktrees = main_entry .. unavailable_entries
answers = { choose(main) }
local key_context = vim.tbl_extend("force", context, { origin = "key" })
assert(actions.ghq_projects.run(key_context) == created_session and #prompts == 1)
launched(main, "répo space")
assert(#queued == 1 and queued[1].args.session_id == created_session.session_id)

fixture()
answers = { choose(main), choose(detached) }
actions.ghq_projects.run(context)
launched(detached, "répo space · detached HEAD")

for _, plain in ipairs({ false, true }) do
  fixture()
  plain_bare = plain
  answers = { choose(bare) }
  actions.ghq_projects.run(context)
  assert(#prompts == 1)
  launched(bare .. "/topic", "bare · topic")
end

fixture()
assert(actions.ghq_projects.run({}, { project = main }) == created_session and #prompts == 0 and #queued == 0)
launched(main, "répo space")
fixture()
worktrees = main_entry
assert(actions.ghq_projects.run(cli_context, { project = main }) == created_session)
launched(main, "répo space")
assert(#prompts == 0 and #queued == 0, "A CLI client ID does not identify an app to focus")
fixture()
fails("ghq_projects", "absent from the GHQ", {}, { project = "/other/checkout" })
assert(#exec_calls == 1 and #prompts == 0 and #creations == 0)
fixture()
fails("ghq_projects", "hosts the checkout", { server = "remote" }, { project = main })
fails("git_worktrees", "hosts the checkout", { server = "remote", block_id = context.block_id })
assert(#exec_calls == 0 and #prompts == 0 and #creations == 0)

for reason, message in pairs({
  busy = "prompt open", no_client = "No Rex app", timeout = "prompt timed out", unsupported = "supports Custom UI",
  failed = "Rex prompt failed: backend refused",
}) do
  fixture()
  answers = {{ reason = reason, detail = "backend refused" }}
  fails("ghq_projects", message)
  assert(#creations == 0 and #exec_calls == 1)
end
fixture()
answers = {{ reason = "no_client" }}
assert(actions.ghq_projects.run(cli_context, { project = main }) == created_session)
launched(main, "répo space")
assert(#prompts == 1 and #queued == 0)
fixture()
rex.ui = nil
fails("ghq_projects", "supports Custom UI")
assert(#creations == 0)

for _, result in ipairs({
  { success(), "GHQ has no Git repositories" },
  { { ok = false, code = 127, stderr = "ghq: No such file or directory" }, "No such file or directory" },
  { { ok = false, code = 2, stderr = "invalid ghq configuration" }, "invalid ghq configuration" },
  { { ok = false, timed_out = true }, "ghq timed out" },
}) do
  fixture()
  ghq_response = result[1]
  fails("ghq_projects", result[2])
  assert(#exec_calls == 1 and #prompts == 0 and #creations == 0)
end
fixture()
ghq_error = "exec unavailable"
fails("ghq_projects", ghq_error)

fixture()
local large = { main }
for i = 1, 2001 do large[#large + 1] = "/ghq/github.com/bulk/item-" .. i end
ghq_response = success(table.concat(large, "\n"))
answers = {
  function(method)
    assert(method == "input" and #exec_calls == 1)
    return "owner/répo"
  end,
  function(method, opts)
    assert(method == "pick" and #opts.items == 1 and opts.items[1].id == main and #exec_calls == 1)
    return nil, "cancelled"
  end,
}
assert(actions.ghq_projects.run(context) == nil and #creations == 0 and #prompts == 2)
fixture()
local long_path = main .. "/" .. string.rep("é", 129)
ghq_response = success(long_path .. "\n")
worktrees = record(long_path, { "HEAD " .. oid, "branch refs/heads/topic" })
actions.ghq_projects.run({}, { project = long_path })
launched(long_path, string.rep("é", 128))

for _, changed in ipairs({ "missing", "repo", "branch" }) do
  fixture()
  answers = { choose(main), function()
    if changed == "missing" then remove_path = linked end
    if changed == "repo" then changed_root = linked end
    if changed == "branch" then changed_branch = "other" end
    return linked
  end }
  fails("ghq_projects", "Reopen the worktree picker")
  assert(#creations == 0)
end

for step, prefix in ipairs({
  {}, { choose(main) }, { choose(main), choose("create") },
  { choose(main), choose("create"), choose("new-branch") },
  { choose(main), choose("create"), choose("new-branch"), choose("default") },
}) do
  fixture()
  answers = prefix
  answers[#answers + 1] = cancel
  assert(actions.ghq_projects.run(context) == nil and #prompts == step)
  assert(#creations == 0 and #queued == 0 and #layers == 0)
end

fixture()
worktrees = main_entry
answers = { function(_, opts)
  assert(#opts.items == 2 and opts.items[2].id == "create")
  return nil, "cancelled"
end }
assert(actions.git_worktrees.run(context) == nil and #creations == 0)

for _, branch in ipairs({ "@{-1}", "^", "@", "-", "pr:123", "mr:23", "bad branch" }) do
  fixture()
  answers = { choose("create"), choose(branch) }
  fails("git_worktrees", branch == "bad branch" and "invalid branch name" or "literal Git branch name")
  assert(#creations == 0)
end
fixture()
answers = { choose("create"), choose("missing") }
fails("git_worktrees", "unavailable worktree")
assert(#creations == 0)
fixture()
answers = { choose("create"), choose("topic") }
assert(actions.git_worktrees.run(context) == created_session and #prompts == 2)
assert(launched(linked, "répo space · topic").command == nil)

for _, case in ipairs({
  { branch = "unattached" },
  { branch = "new/topic", base = "default" },
  { branch = "new-vietnamese-é", base = "HEAD", arg = oid },
  { branch = "new/explicit", base = "refs/heads/production", arg = "refs/heads/production" },
}) do
  fixture()
  answers = { choose("create"), choose(case.branch) }
  if case.base then
    answers[3] = function(_, opts)
      assert(opts.items[1].id == "default" and opts.items[2].id == "HEAD" and opts.items[3].id == "refs/heads/production")
      return case.base
    end
  end
  answers[#answers + 1] = choose("run")
  assert(actions.git_worktrees.run(context) == created_session)
  local layout = launched(main, "répo space · " .. case.branch)
  local expected = { "/usr/bin/env", path_env, "wt", "switch", "-C", main }
  if case.base then expected[#expected + 1] = "--create" end
  if case.arg then vim.list_extend(expected, { "--base", case.arg }) end
  vim.list_extend(expected, { case.branch, "--no-cd", "--execute", "fish", "--", "-il" })
  assert(vim.deep_equal(layout.command, expected) and layout.shell == "none" and layout.exit.on_completion == false)
end
fixture()
answers = { choose("create"), choose("feature"), choose("refs/heads/production"), function()
  changed_base = true
  return "run"
end }
fails("git_worktrees", "Base changed")
assert(#creations == 0)
fixture()
wt_error = "wt is missing"
answers = { choose("create"), choose("unattached"), choose("run") }
fails("git_worktrees", wt_error)
assert(#creations == 0)

for _, malformed in ipairs({ false, true }) do
  fixture()
  if malformed then invalid_session = true else creation_error = "server refused" end
  fails("ghq_projects", "Check rex ls before trying again", {}, { project = main })
  assert(#creations == 1)
  creation_error, invalid_session = nil, nil
end
fixture()
worktrees = main_entry
queue_error = "origin disconnected"
assert(actions.ghq_projects.run(context, { project = main }) == created_session)
assert(#creations == 1 and #queued == 0 and #warnings == 1 and warnings[1][2]:find(created_session.session_id, 1, true))
queue_error = nil

fixture()
pwd = linked .. "/src"
local lazygit = popup("lazygit")
local tuicr = popup("tuicr")
assert(lazygit.cwd == pwd and lazygit.interactive and vim.deep_equal(lazygit.command, { "lazygit" }))
assert(tuicr.cwd == pwd and tuicr.interactive and vim.deep_equal(tuicr.command, { "tuicr", "-w" }))
answers = { choose("refs/heads/production") }
local review = popup("tuicr_review_branch")
assert(review.cwd == pwd and vim.deep_equal(review.command, { "tuicr", "-r", merge .. "..HEAD" }))
fixture()
pwd = linked .. "/src"
assert(actions.tuicr_review_branch.run(context, { base = "refs/heads/production" }).layer_id == "layer:popup")
assert(#prompts == 0)
fixture()
answers = { cancel }
assert(actions.tuicr_review_branch.run(context) == nil and #layers == 0)
fixture()
fails("tuicr_review_branch", "Needed a single revision", context, { base = "--not-a-ref" })
fixture()
pwd, remove_path = linked, linked
for _, name in ipairs({ "lazygit", "tuicr", "tuicr_review_branch", "git_worktrees" }) do
  fails(name, "directory")
end
fixture()
pwd = "/non-colocated-jj/subdir"
assert(popup("tuicr").cwd == pwd and #exec_calls == 1 and exec_calls[1].argv[1] == "/bin/test")

os.getenv = old_getenv
package.loaded.orc = old_orc
package.path = old_path
print("rex integration: all assertions passed")
