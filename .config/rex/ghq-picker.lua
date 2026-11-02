-- Loaded by the Rex floating Neovim; the caller supplies the originating app ID.
return function(client_id)
  local function quit()
    vim.schedule(function() vim.cmd("qa!") end)
  end

  local function fail(message) vim.notify(message, vim.log.levels.ERROR, { title = "GHQ → Rex" }) end

  local function run(argv)
    local ok, result = pcall(function() return vim.system(argv, { text = true }):wait() end)
    if not ok then return nil, tostring(result) end
    if result.code ~= 0 then
      local message = vim.trim(result.stderr or "")
      return nil, message ~= "" and message or ("Command failed (%s): %s"):format(result.code, argv[1])
    end
    return result.stdout or ""
  end

  -- Keep startup errors readable even when there is no picker to cancel.
  local function startup_error(message)
    local lines = vim.list_extend({ "GHQ → New Rex Session", "" }, vim.split(message, "\n", { plain = true }))
    vim.list_extend(lines, { "", "Press Esc or q to close." })
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.bo.buftype, vim.bo.bufhidden, vim.bo.swapfile = "nofile", "wipe", false
    vim.bo.modified = false
    vim.keymap.set("n", "<Esc>", quit, { buffer = true })
    vim.keymap.set("n", "q", quit, { buffer = true })
    fail(message)
  end

  if not client_id or client_id == "" then
    startup_error("Missing originating Rex app client")
    return
  end
  local output, err = run({ "ghq", "list", "-p" })
  if not output then
    startup_error(err)
    return
  end
  local items = {}
  for path in output:gmatch("[^\r\n]+") do
    items[#items + 1] = { text = path, path = path }
  end
  if #items == 0 then
    startup_error("No repositories found by ghq list -p")
    return
  end
  if not (_G.Snacks and Snacks.picker) then
    startup_error("Snacks Picker is not available in this Neovim configuration")
    return
  end

  local rex = vim.fn.exepath("rex")
  if rex == "" then rex = "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex" end
  local created = {}
  local unconfirmed = false
  local uncertain_message = "Session creation is unconfirmed; check rex ls before reopening"
  Snacks.picker.pick({
    title = "GHQ → New Rex Session",
    items = items,
    format = "text",
    layout = { preset = "telescope", hidden = { "preview" } },
    win = {
      input = {
        keys = {
          ["<CR>"] = { "confirm", mode = { "n", "i" } },
          ["<Esc>"] = { "close", mode = { "n", "i" } },
          ["<C-c>"] = { "close", mode = { "n", "i" } },
          ["<C-j>"] = { "list_down", mode = { "n", "i" } },
          ["<C-k>"] = { "list_up", mode = { "n", "i" } },
        },
      },
    },
    on_close = quit,
    confirm = function(picker, item)
      if not item then return end
      if unconfirmed then
        fail(uncertain_message)
        return
      end
      local path = item.path
      if vim.fn.isdirectory(path) ~= 1 then
        fail("Repository directory no longer exists: " .. path)
        return
      end
      if not created[path] then
        local label = vim.fn.strcharpart(vim.fs.basename(path), 0, 128)
        -- A failed CLI reply can still mean the server created the session.
        unconfirmed = true
        local result, create_err = run({
          rex,
          "api",
          "call",
          "session.create",
          vim.json.encode({
            label = label,
            initial_windows = {
              {
                window_label = "Terminal",
                layout = { block = { flavor = "com.superlogical.terminal.shell", options = { cwd = path } } },
              },
            },
          }),
        })
        if not result then
          fail(create_err .. ". " .. uncertain_message)
          return
        end
        local ok, session = pcall(vim.json.decode, result)
        if not ok or type(session) ~= "table" or type(session.session_id) ~= "string" or session.session_id == "" then
          fail(uncertain_message)
          return
        end
        created[path] = session.session_id
        unconfirmed = false
      end
      local _, select_err = run({
        rex,
        "-C",
        client_id,
        "do",
        "session.select",
        "--args",
        vim.json.encode({ session_id = created[path] }),
      })
      if select_err then
        fail("Session " .. created[path] .. " was created; press Enter to retry switching. " .. select_err)
        return
      end
      picker:close()
    end,
  })
end
