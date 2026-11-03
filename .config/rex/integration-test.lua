-- Run with nvim --headless -u NONE -l .config/rex/integration-test.lua.
local config_dir = vim.fs.dirname(vim.uv.fs_realpath(arg[0]))
local actions, bindings, layers, pwd, hostname, layer_error, hostname_error
local origin = 'client:origin"; error("unexpected") --'
local context = { client_id = origin, session_id = "session:source", block_id = "block:source" }
local invoked
local old_orc = package.loaded.orc
package.loaded.orc = {
  open = function(opts) invoked = { method = "open", opts = opts } end,
  projects = function(opts) invoked = { method = "projects", opts = opts } end,
}

local function load_config()
  actions, bindings, layers, invoked = {}, {}, {}, nil
  _G.rex = {
    action = function(action) actions[action.name] = action end,
    bind = function(key, action) bindings[key] = action end,
    block = {
      call = function(flavor, method, opts)
        assert(flavor == "com.superlogical.terminal" and method == "pwd")
        assert(opts.block_id == context.block_id)
        return pwd and { pwd = pwd } or nil
      end,
    },
    exec = function(argv, opts)
      assert(vim.deep_equal(argv, { "hostname" }) and opts.timeout == 2)
      if hostname_error then return nil, hostname_error end
      return { ok = true, stdout = hostname or "local-mac\n" }
    end,
    layout = { block = function(block) return block end },
    session = {
      new_layer = function(opts)
        layers[#layers + 1] = opts
        return layer_error and nil or { layer_id = "layer:popup", block_ids = { "block:popup" } }, layer_error
      end,
    },
  }
  dofile(config_dir .. "/init.lua")
  assert(#layers == 0, "Loading config must never create resources")
  assert(vim.tbl_count(actions) == 4 and vim.tbl_count(bindings) == 3)
  assert(bindings["ctrl+cmd+g"] == "lazygit")
  assert(bindings["ctrl+cmd+r"] == "tuicr")
  assert(bindings["ctrl+cmd+p"] == "ghq_projects")
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

pwd = "/repo literal%20 with spaces;$()"
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

for _, url in ipairs({
  "file:///repo%20with%20spaces%3B%24%28%29",
  "file://localhost/repo%20with%20spaces%3B%24%28%29",
  "file://LOCAL-MAC/repo%20with%20spaces%3B%24%28%29",
}) do
  pwd = url
  load_config()
  options = popup("orc_tasks")
  assert(options.cwd == "/repo with spaces;$()")
end

for _, invalid in ipairs({
  "relative/repo", "https://example.org/repo", "file://remote-mac/repo", "file:///repo%00",
  "file:///repo%", "file:///repo%2", "file:///repo%zz", "file://localhost", "file:///repo?query",
  "file:///repo#fragment", "/repo\nunsafe", true,
}) do
  pwd = invalid
  load_config()
  assert(not pcall(actions.orc_tasks.run, context), "Must reject invalid directory: " .. tostring(invalid))
  assert(#layers == 0)
end

pwd, hostname_error = "file://local-mac/repo", "hostname unavailable"
load_config()
assert(not pcall(actions.orc_tasks.run, context) and #layers == 0)
hostname_error = nil

for _, absent in ipairs({ false, "" }) do
  pwd = absent
  load_config()
  assert(not pcall(actions.orc_tasks.run, context) and #layers == 0)
  invoke(popup("ghq_projects"))
end

pwd = "/repo"
load_config()
for _, name in ipairs({ "ghq_projects", "orc_tasks" }) do
  assert(not pcall(actions[name].run, { session_id = context.session_id, block_id = context.block_id }))
  assert(not pcall(actions[name].run, { client_id = "", block_id = context.block_id }))
end
assert(#layers == 0)
assert(not pcall(actions.orc_tasks.run, { client_id = origin }) and #layers == 0)

layer_error = "layer refused"
load_config()
local ok, err = pcall(actions.ghq_projects.run, context)
assert(not ok and err == "layer refused")
package.loaded.orc = old_orc
print("rex integration: all assertions passed")
