-- Language profiles: a combinable set of languages layered on top of the
-- always-on core (Lua, shell, Markdown, JSON, YAML).
--
-- Select with `:Profile`, or per shell with NVIM_PROFILE=web,go (`,` `+` or
-- spaces separate names; `core` alone means no extra languages).
local M = {}

local languages = {
	web = { label = "Web (TypeScript, Tailwind, ESLint)" },
	go = { label = "Go" },
	rust = { label = "Rust" },
}

local state_file = vim.fn.stdpath("state") .. "/language-profile"

---@param str string?
---@return string[]? names sorted language names, nil when nothing valid was given
---@return string[] unknown names that are neither a language nor `core`
local function parse(str)
	if str == nil or vim.trim(str) == "" then
		return nil, {}
	end
	local set, unknown, valid = {}, {}, false
	for name in str:gmatch("[^,+%s]+") do
		if languages[name] then
			set[name], valid = true, true
		elseif name == "core" then
			valid = true
		else
			unknown[#unknown + 1] = name
		end
	end
	if not valid then
		return nil, unknown
	end
	local names = vim.tbl_keys(set)
	table.sort(names)
	return names, unknown
end

local function read_saved()
	local ok, lines = pcall(vim.fn.readfile, state_file)
	return (parse(ok and lines[1] or nil))
end

---@param names string[]
local function format(names)
	return #names == 0 and "core" or table.concat(names, ",")
end

--- Active languages, sorted. Empty means core only.
---@return string[]
function M.active()
	if M._active then
		return M._active
	end

	local requested, unknown = parse(vim.env.NVIM_PROFILE)
	if #unknown > 0 then
		vim.notify(("Unknown NVIM_PROFILE language(s): %s"):format(table.concat(unknown, ", ")), vim.log.levels.WARN)
	end
	M._active = requested or read_saved() or {}
	return M._active
end

--- Display name, e.g. "core" or "go,web".
function M.name()
	return format(M.active())
end

--- Whether a language is active. `core` is always active.
---@param name string
function M.is(name)
	return name == "core" or vim.list_contains(M.active(), name)
end

function M.needs_selection()
	return parse(vim.env.NVIM_PROFILE) == nil and read_saved() == nil
end

--- Lazy specs for one language.
---
--- `plugins`: plugins only this language uses. Always declared, gated with
--- `cond`, so lazy keeps them installed and in lazy-lock.json in every profile
--- (`:Lazy sync`/`clean`/`update` are safe from any profile). They load only
--- when the language is active. If a language extra brings its own plugins,
--- list them here as `{ "owner/repo" }` too, since an inactive import is skipped.
---
--- `config`: everything else (extras imports, opts fragments for shared plugins
--- like lspconfig/mason/conform). Applied only when the language is active;
--- never put `cond` on these, it would disable the shared plugin.
---@param name string
---@param spec { plugins?: LazyPluginSpec[], config?: LazySpec[] }
---@return LazySpec[]
function M.lang(name, spec)
	local active = M.is(name)
	local out = {}
	for _, plugin in ipairs(spec.plugins or {}) do
		plugin.cond = active
		out[#out + 1] = plugin
	end
	if active then
		vim.list_extend(out, spec.config or {})
	end
	return out
end

function M.paths()
	return {
		-- Plugins, Mason tools and treesitter parsers are shared by every profile
		-- (default locations); each profile only installs what it needs.
		lazy = vim.fn.stdpath("data") .. "/lazy",
		lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
	}
end

---@param names string[]
local function save(names)
	vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")
	vim.fn.writefile({ format(names) }, state_file)
	M._active = names
end

function M.restart()
	if #vim.fn.getbufinfo({ bufmodified = 1 }) > 0 then
		vim.notify("Profile saved. Restart Neovim after saving modified buffers.", vim.log.levels.WARN)
		return
	end

	vim.cmd("restart")
end

---@param on_done fun(names: string[])
local function pick(on_done)
	local current = M.active()
	local items = { { text = "core", label = "Core only (Lua, shell, Markdown)" } }
	local names = vim.tbl_keys(languages)
	table.sort(names)
	for _, name in ipairs(names) do
		items[#items + 1] = { text = name, label = languages[name].label }
	end

	if not (_G.Snacks and Snacks.picker) then
		vim.ui.input({
			prompt = "Languages (comma-separated: " .. table.concat(names, ", ") .. "): ",
			default = format(current),
		}, function(input)
			local parsed = parse(input)
			if parsed then
				on_done(parsed)
			end
		end)
		return
	end

	Snacks.picker.pick({
		title = "Language profile (<Tab> to combine) — current: " .. format(current),
		items = items,
		layout = { preset = "select", layout = { max_width = 60 } },
		format = function(item)
			local mark = (item.text == "core" and #current == 0 or vim.list_contains(current, item.text)) and "● " or "  "
			return { { mark, "Special" }, { item.label } }
		end,
		confirm = function(picker)
			local selected = picker:selected({ fallback = true })
			picker:close()
			local chosen = {}
			for _, item in ipairs(selected) do
				if languages[item.text] then
					chosen[#chosen + 1] = item.text
				end
			end
			table.sort(chosen)
			on_done(chosen)
		end,
	})
end

---@param on_choice fun(names: string[])?
function M.select(on_choice)
	local previous = M.name()
	pick(function(names)
		save(names)
		if on_choice then
			on_choice(names)
		elseif format(names) ~= previous then
			M.restart()
		else
			vim.notify("Already using the " .. previous .. " profile")
		end
	end)
end

function M.setup_command()
	vim.api.nvim_create_user_command("Profile", function()
		M.select()
	end, { desc = "Select (and combine) LazyVim language profiles, then restart" })
end

return M
