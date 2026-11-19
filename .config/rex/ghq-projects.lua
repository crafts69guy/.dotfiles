local M = {}
local max_items = 2000
local create_id = "create"
local heads = "refs/heads/"

local function absolute_path(path)
  return type(path) == "string" and path:sub(1, 1) == "/" and not path:find("%c")
end

local function basename(path)
  return path:match("([^/]+)/?$") or path
end

local function tool_path()
  local path = os.getenv("PATH") or ""
  local home = os.getenv("HOME")
  local fallback = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
  if absolute_path(home) then fallback = home .. "/.local/bin:" .. fallback end
  return path ~= "" and (path .. ":" .. fallback) or fallback
end

local function run(argv, cwd, missing_code)
  local program = argv[1]
  if program:sub(1, 1) ~= "/" then
    table.insert(argv, 1, "PATH=" .. tool_path())
    table.insert(argv, 1, "/usr/bin/env")
  end
  local result, err = rex.exec(argv, { cwd = cwd, timeout = 5 })
  if not result then error(program .. ": " .. tostring(err), 0) end
  if result.timed_out then error(program .. " timed out", 0) end
  if result.ok then return result.stdout or "" end
  if missing_code and result.code == missing_code then return nil end
  local message = result.stderr and result.stderr ~= "" and result.stderr or result.stdout
  error(program .. ": " .. (message and message ~= "" and message:gsub("\n$", "")
    or ("exited with status " .. tostring(result.code))), 0)
end

local function directory(path)
  return absolute_path(path) and run({ "/bin/test", "-d", path }, nil, 1) ~= nil
end

local prompt_errors = {
  busy = "Rex already has a prompt open",
  no_client = "No Rex app is connected to answer the prompt",
  timeout = "Rex prompt timed out",
  unsupported = "Update Rex and the connected app to a version that supports Custom UI",
}

local function ask(method, options, allow_no_client)
  local prompt = rex.ui and rex.ui[method]
  if not prompt then error(prompt_errors.unsupported, 0) end
  local value, reason, detail = prompt(options)
  if value ~= nil then return value end
  if reason == "cancelled" or (allow_no_client and reason == "no_client") then return nil, reason end
  error(prompt_errors[reason] or ("Rex prompt failed" .. (detail and (": " .. detail) or "")), 0)
end

local function pick(title, items, allow_no_client)
  local matches, query = items, nil
  while #matches > max_items do
    local reason
    query, reason = ask("input", {
      title = title .. " (" .. #matches .. " results)", placeholder = "Enter a keyword to narrow the list", value = query,
    }, allow_no_client)
    if query == nil then return nil, reason end
    local needle = query:lower()
    matches = {}
    for _, row in ipairs(items) do
      if (row.title .. " " .. (row.subtitle or "")):lower():find(needle, 1, true) then
        matches[#matches + 1] = row
      end
    end
  end
  assert(#matches > 0, "No results match the filter")
  local selected, reason = ask("pick", { title = title, items = matches }, allow_no_client)
  if not selected then return nil, reason end
  for _, row in ipairs(matches) do
    if row.id == selected then return selected end
  end
  error("Rex returned a selection outside the picker", 0)
end

local function inventory(cwd)
  local output = run({ "git", "worktree", "list", "--porcelain", "-z" }, cwd)
  local entries, entry = {}, nil
  -- Lua 5.1 patterns use %z for NUL, including inside character classes.
  for field in output:gmatch("([^%z]*)%z") do
    local key, value = field:match("^(%S+) ?(.*)$")
    if key == "worktree" then
      entry = { path = value }
      entries[#entries + 1] = entry
    elseif entry and key then
      entry[key] = value ~= "" and value or true
    end
  end
  assert(entries[1] and absolute_path(entries[1].path), "Git did not report a main worktree")
  return entries
end

local function inspect(cwd)
  assert(directory(cwd), "Git directory is missing or invalid: " .. tostring(cwd))
  local output = run({ "git", "rev-parse", "--path-format=absolute", "--git-common-dir", "--is-bare-repository" }, cwd)
  local common, bare = output:match("^([^\n]+)\n(%a+)\n$")
  assert(absolute_path(common) and (bare == "true" or bare == "false"), "Git returned invalid repository information")
  local root
  if bare == "false" then
    root = run({ "git", "rev-parse", "--show-toplevel" }, cwd):gsub("\n$", "")
    assert(absolute_path(root), "Git returned an invalid checkout root")
  else
    -- ghq --clean-bare keeps the Git directory in .git, under the project path.
    local physical = run({ "/bin/pwd", "-P" }, cwd):gsub("\n$", "")
    assert(common == physical or common == physical .. "/.git", "The directory is outside the bare Git repository root")
  end
  return { cwd = cwd, common = common, root = root }
end

local function eligible(entry)
  return entry and not entry.bare and not entry.prunable and directory(entry.path)
end

local function label(repo, branch)
  local value = repo .. (branch and (" · " .. branch) or "")
  local count = 0
  for byte in value:gmatch("()[^\128-\191]") do
    count = count + 1
    if count > 128 then return value:sub(1, byte - 1) end
  end
  return value
end

local function create_session(ctx, name, options)
  local session, err = rex.call("session.create", {
    label = name,
    initial_windows = {{
      window_label = "Shell",
      layout = rex.layout.block{ flavor = "com.superlogical.terminal.shell", options = options },
    }},
  })
  if err or type(session) ~= "table" or type(session.session_id) ~= "string" or session.session_id == "" then
    error((err or "Rex returned no session ID") .. ". Check rex ls before trying again.", 0)
  end
  -- The CLI can supply a client ID without an app target for deferred dispatch.
  if (ctx.origin == "key" or ctx.origin == "palette") and ctx.client_id and ctx.client_id ~= "" then
    local ok, queue_error = pcall(rex.client.queue, "session.select", { session_id = session.session_id })
    if not ok then
      rex.log("warn", "Open " .. session.session_id .. " manually. Rex could not queue session selection: " .. tostring(queue_error))
    end
  end
  return session
end

local function open_checkout(ctx, repo, entry, main)
  assert(eligible(entry), "Worktree is unavailable. Reopen the worktree picker.")
  local current = inspect(entry.path)
  assert(current.common == repo.common and current.root == entry.path,
    "Worktree path changed. Reopen the worktree picker.")
  local ref = run({ "git", "symbolic-ref", "--quiet", "HEAD" }, entry.path, 1)
  assert((ref and ref:gsub("\n$", "")) == entry.branch, "Worktree branch changed. Reopen the worktree picker.")
  local branch = entry.branch and entry.branch:sub(#heads + 1) or "detached HEAD"
  return create_session(ctx, label(repo.name, entry.path ~= main.path and branch or nil), { cwd = entry.path })
end

local function resolve_commit(cwd, ref)
  assert(type(ref) == "string" and ref ~= "" and not ref:find("%c"), "Enter a Git base ref or commit")
  local oid = run({ "git", "rev-parse", "--verify", "--end-of-options", ref .. "^{commit}" }, cwd):match("^(%x+)\n$")
  assert(oid, "Git did not resolve a commit for " .. ref)
  return oid
end

local function choose_base(repo)
  local items = {{ id = "default", title = "Default branch (Worktrunk)", icon = "branch" }}
  if repo.root then
    items[#items + 1] = { id = "HEAD", title = "Current checkout (HEAD)", subtitle = repo.root, icon = "folder" }
  end
  local refs = run({ "git", "for-each-ref", "--sort=refname", "--format=%(refname)", heads }, repo.cwd)
  for ref in refs:gmatch("[^\n]+") do
    items[#items + 1] = { id = ref, title = ref:sub(#heads + 1), subtitle = ref, icon = "branch" }
  end
  return pick("Choose a base for the new branch", items)
end

local function branch_checkout(entries, ref)
  local registered
  for _, entry in ipairs(entries) do
    if entry.branch == ref then
      if eligible(entry) then return entry end
      registered = true
    end
  end
  assert(not registered, "The branch has an unavailable worktree. Check Git's worktree inventory before switching.")
end

local function local_branch(cwd, ref)
  return run({ "git", "show-ref", "--verify", "--quiet", ref }, cwd, 1) ~= nil
end

local function create_worktree(ctx, repo)
  local branch = ask("input", { title = "Create or switch to a worktree", placeholder = "Local branch name" })
  if branch == nil then return end
  assert(branch ~= "" and branch ~= "@" and branch ~= "-" and branch ~= "^" and not branch:find("%c")
    and not branch:match("^@{") and not branch:match("^[pm]r:"), "Enter a literal Git branch name")
  assert(run({ "git", "check-ref-format", "--branch", branch }, repo.cwd) == branch .. "\n",
    "Enter a literal Git branch name")

  local ref = heads .. branch
  local entries = inventory(repo.cwd)
  local entry = branch_checkout(entries, ref)
  if entry then return open_checkout(ctx, repo, entry, entries[1]) end
  local existing = local_branch(repo.cwd, ref)
  local base, base_oid, description
  if existing then
    description = "Existing local branch"
  else
    base = choose_base(repo)
    if not base then return end
    if base ~= "default" then base_oid = resolve_commit(repo.cwd, base) end
    description = base == "default" and "Default branch (Worktrunk)" or base
  end
  local confirmed = pick("Open worktree for " .. branch .. "?", {{
    id = "run", title = "Run Worktrunk", subtitle = description .. " · " .. repo.cwd, icon = "terminal",
  }})
  if not confirmed then return end

  local current = inspect(repo.cwd)
  assert(current.common == repo.common and current.root == repo.root, "Repository changed. Reopen the worktree picker.")
  entries = inventory(repo.cwd)
  entry = branch_checkout(entries, ref)
  if entry then return open_checkout(ctx, repo, entry, entries[1]) end
  assert(local_branch(repo.cwd, ref) == existing, "Branch changed. Reopen the worktree picker.")
  if base_oid then
    assert(resolve_commit(repo.cwd, base) == base_oid, "Base changed. Reopen the worktree picker.")
  end
  run({ "wt", "--version" }, repo.cwd)
  run({ "fish", "--version" }, repo.cwd)

  local command = { "/usr/bin/env", "PATH=" .. tool_path(), "wt", "switch", "-C", repo.cwd }
  if not existing then command[#command + 1] = "--create" end
  if base_oid then
    command[#command + 1] = "--base"
    command[#command + 1] = base == "HEAD" and base_oid or base
  end
  for _, part in ipairs({ branch, "--no-cd", "--execute", "fish", "--", "-il" }) do
    command[#command + 1] = part
  end
  return create_session(ctx, label(repo.name, branch), {
    cwd = repo.cwd, command = command, shell = "none", exit = { on_completion = false },
  })
end

local function checkout_picker(ctx, repo, force_picker, explicit_project)
  local entries = inventory(repo.cwd)
  local main = entries[1]
  local main_path = main.bare and (main.path:match("^(.+)/%.git$") or main.path) or main.path
  repo.name = basename(main_path)
  local items, by_path = {}, {}
  for _, entry in ipairs(entries) do
    if eligible(entry) then
      local title = entry.branch and entry.branch:sub(#heads + 1) or "Detached HEAD"
      local detail = entry.detached and type(entry.HEAD) == "string" and entry.HEAD:sub(1, 12) or nil
      if entry.locked then detail = detail and (detail .. " · Locked") or "Locked" end
      items[#items + 1] = { id = entry.path, title = title, subtitle = entry.path, detail = detail, icon = "folder" }
      by_path[entry.path] = entry
    end
  end
  local default = explicit_project and repo.root and by_path[repo.root] or nil
  if not force_picker then
    if #items == 1 then return open_checkout(ctx, repo, by_path[items[1].id], main) end
    if default and not (ctx.client_id and ctx.client_id ~= "") then return open_checkout(ctx, repo, default, main) end
  end
  items[#items + 1] = { id = create_id, title = "Create or switch to a branch…", icon = "plus" }
  local selected, reason = pick("Choose a worktree for " .. repo.name, items, default ~= nil)
  if reason == "no_client" then return open_checkout(ctx, repo, default, main) end
  if not selected then return end
  if selected == create_id then return create_worktree(ctx, repo) end
  return open_checkout(ctx, repo, by_path[selected], main)
end

-- This config discovers paths on the server running it.
function M.require_local(ctx)
  assert(not ctx.server or ctx.server == "", "Run this action on the Rex server that hosts the checkout")
end

-- Open a member of the current GHQ inventory. An explicit project skips the repository prompt.
function M.open_project(ctx, args)
  M.require_local(ctx)
  local output = run({ "ghq", "list", "--full-path", "--vcs", "git" })
  local items, seen = {}, {}
  for path in output:gmatch("[^\n]+") do
    if absolute_path(path) and not seen[path] then
      seen[path] = true
      items[#items + 1] = { id = path, title = basename(path), subtitle = path, icon = "folder" }
    end
  end
  assert(#items > 0, "GHQ has no Git repositories")
  local explicit = args and args.project
  if explicit ~= nil then assert(seen[explicit], "Project is absent from the GHQ Git inventory") end
  local project = explicit
  if not project then
    table.sort(items, function(a, b) return a.id < b.id end)
    project = pick("Open a GHQ repository", items)
    if not project then return end
  end
  local repo = inspect(project)
  if repo.root then
    local physical = run({ "/bin/pwd", "-P" }, project):gsub("\n$", "")
    assert(repo.root == physical, "GHQ path is no longer a Git checkout root")
  end
  return checkout_picker(ctx, repo, false, explicit ~= nil)
end

-- Show the focused repository's inventory even when it has a single checkout.
function M.open_worktrees(ctx, cwd)
  local repo = inspect(cwd)
  repo.cwd = repo.root or cwd
  return checkout_picker(ctx, repo, true)
end

-- Preserve the focused directory for TUI discovery, including non-Git Jujutsu workspaces.
function M.validate_tool_cwd(cwd, git_only)
  if git_only then
    assert(inspect(cwd).root, "The focused pane must be in a Git checkout")
  else
    assert(directory(cwd), "The focused pane has no existing local directory: " .. tostring(cwd))
  end
end

-- Resolve an explicit Git base and return the commit-only range for the focused checkout.
function M.review_range(cwd, base)
  local repo = inspect(cwd)
  assert(repo.root, "The focused pane must be in a Git checkout")
  if base == nil then
    base = ask("input", { title = "Review branch against Git base", placeholder = "Branch, tag, or commit" })
    if base == nil then return end
    local current = inspect(cwd)
    assert(current.common == repo.common and current.root == repo.root, "Checkout changed. Reopen Review Branch.")
  end
  local oid = resolve_commit(cwd, base)
  local merge_base = run({ "git", "merge-base", oid, "HEAD" }, cwd):match("^(%x+)\n$")
  assert(merge_base, "Git did not return a merge base")
  return merge_base .. "..HEAD"
end

return M
