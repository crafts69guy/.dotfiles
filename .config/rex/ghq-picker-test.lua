-- Run with nvim --headless -u NONE -l .config/rex/ghq-picker-test.lua.
local config_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:gsub("^@", ""), ":h")
local start = dofile(config_dir .. "/ghq-picker.lua")
local root = vim.fn.tempname()
local repo = root .. "/-repo with spaces;$()"
vim.fn.mkdir(repo, "p")

local calls, responses, messages, scheduled, opts, closed, quit
local client = "client:originating-app"
local function flush()
  for _, fn in ipairs(scheduled) do
    fn()
  end
  scheduled = {}
end
local function reset(results)
  calls, responses, messages, scheduled = {}, results or {}, {}, {}
  opts, closed, quit = nil, false, false
  _G.Snacks = { picker = { pick = function(config) opts = config end } }
end
local function ok(stdout) return { code = 0, stdout = stdout or "", stderr = "" } end
local function bad(stderr) return { code = 1, stdout = "", stderr = stderr } end
local listing = ok(repo .. "\n")
local session = ok('{"session_id":"session:new"}')
local picker = {
  close = function()
    closed = true
    opts.on_close()
  end,
}
vim.system = function(argv)
  calls[#calls + 1] = argv
  local response = table.remove(responses, 1)
  assert(response, "Unexpected command: " .. vim.inspect(argv))
  if type(response) == "string" then error(response) end
  return { wait = function() return response end }
end
vim.notify = function(message) messages[#messages + 1] = message end
vim.schedule = function(fn) scheduled[#scheduled + 1] = fn end
vim.cmd = function(command)
  assert(command == "qa!")
  quit = true
end

reset()
start(nil)
assert(#calls == 0 and messages[1]:find("Missing originating", 1, true))

reset({ bad("ghq failed") })
start(client)
assert(not opts and messages[1] == "ghq failed")
assert(vim.api.nvim_buf_get_lines(0, 0, -1, false)[3] == "ghq failed")

reset({ bad("ghq failed\ncheck configuration") })
start(client)
assert(vim.api.nvim_buf_get_lines(0, 0, -1, false)[4] == "check configuration")

reset({ "ghq executable missing" })
start(client)
assert(not opts and messages[1]:find("ghq executable missing", 1, true))

reset({ ok("") })
start(client)
assert(not opts and messages[1]:find("No repositories", 1, true))

reset({ listing })
_G.Snacks = nil
start(client)
assert(not opts and messages[1]:find("Snacks Picker", 1, true))

reset({ listing })
start(client)
assert(opts.layout.preset == "telescope" and opts.items[1].path == repo)
assert(vim.deep_equal(calls[1], { "ghq", "list", "-p" }))
assert(vim.deep_equal(opts.win.input.keys["<Esc>"].mode, { "n", "i" }))
assert(vim.deep_equal(opts.win.input.keys["<CR>"], { "confirm", mode = { "n", "i" } }))
opts.confirm(picker, nil)
opts.on_close()
assert(#calls == 1 and not quit)
flush()
assert(quit)

reset({ listing })
start(client)
opts.confirm(picker, { path = root .. "/missing" })
assert(#calls == 1 and not closed and messages[1]:find("no longer exists", 1, true))

reset({ listing, session, ok() })
start(client)
opts.confirm(picker, opts.items[1])
local rex = calls[2][1]
assert(vim.deep_equal(vim.list_slice(calls[2], 1, 4), { rex, "api", "call", "session.create" }))
local create_args = vim.json.decode(calls[2][5])
assert(create_args.label == "-repo with spaces;$()")
assert(create_args.initial_windows[1].window_label == "Terminal")
assert(create_args.initial_windows[1].layout.block.flavor == "com.superlogical.terminal.shell")
assert(create_args.initial_windows[1].layout.block.options.cwd == repo)
assert(
  vim.deep_equal(
    calls[3],
    { rex, "-C", client, "do", "session.select", "--args", vim.json.encode({ session_id = "session:new" }) }
  )
)
assert(closed and not quit)
flush()
assert(quit and #messages == 0)

reset({ listing, bad("creation failed") })
start(client)
opts.confirm(picker, opts.items[1])
assert(not closed and messages[1]:find("creation failed", 1, true) and #calls == 2)
opts.confirm(picker, opts.items[1])
assert(not closed and #calls == 2 and messages[2]:find("check rex ls", 1, true))

reset({ listing, session, bad("switch denied"), ok() })
start(client)
opts.confirm(picker, opts.items[1])
assert(not closed and messages[1]:find("press Enter to retry", 1, true))
opts.confirm(picker, opts.items[1])
assert(closed and #calls == 4 and vim.deep_equal(calls[3], calls[4]))

for _, invalid in ipairs({ "not json", "null", "{}", '{"session_id":""}' }) do
  reset({ listing, ok(invalid) })
  start(client)
  opts.confirm(picker, opts.items[1])
  opts.confirm(picker, opts.items[1])
  assert(not closed and #calls == 2 and messages[2]:find("check rex ls", 1, true))
end

local getinfo = debug.getinfo
for _, source in ipairs({ "/tmp/rex config/init.lua", "@/tmp/rex config/init.lua" }) do
  local actions, bindings, layer_args = {}, {}, nil
  debug.getinfo = function() return { source = source } end
  _G.rex = {
    action = function(action) actions[action.name] = action end,
    bind = function(key, action) bindings[key] = action end,
    block = { call = function() return nil end },
    layout = { block = function(block) return block end },
    session = {
      new_layer = function(args)
        layer_args = args
        return { layer_id = "layer:test", block_ids = { "block:test" } }
      end,
    },
  }
  dofile(config_dir .. "/init.lua")
  debug.getinfo = getinfo
  local layer = actions.ghq_projects.run({ client_id = client })
  assert(layer.layer_id == "layer:test" and bindings["ctrl+cmd+p"] == "ghq_projects")
  local command = layer_args.layout.options.command
  assert(vim.deep_equal(vim.list_slice(command, 1, 5), { "nvim", "-n", "-i", "NONE", "-c" }))
  assert(command[6] == ("lua dofile(%q)(%q)"):format("/tmp/rex config/ghq-picker.lua", client))
  assert(loadstring(command[6]:gsub("^lua ", "")))
  actions.lazygit.run({})
  assert(vim.deep_equal(layer_args.layout.options.command, { "lazygit" }))
  actions.tuicr.run({})
  assert(vim.deep_equal(layer_args.layout.options.command, { "tuicr" }))
end

vim.fn.delete(root, "rf")
io.stdout:write("ghq-picker: all assertions passed\n")
