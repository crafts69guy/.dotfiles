local M = {}

local profiles = {
	core = { label = "Core (Lua, shell, Markdown)" },
	web = { label = "Web (TypeScript, Tailwind, ESLint)" },
	go = { label = "Go" },
	rust = { label = "Rust" },
}

local state_file = vim.fn.stdpath("state") .. "/language-profile"

local function valid(name)
	return type(name) == "string" and profiles[name] ~= nil
end

local function read_saved()
	local ok, lines = pcall(vim.fn.readfile, state_file)
	local name = ok and lines[1] or nil
	return valid(name) and name or nil
end

function M.current()
	if M._current then
		return M._current
	end

	local requested = vim.env.NVIM_PROFILE
	if requested and requested ~= "" and not valid(requested) then
		vim.notify("Unknown NVIM_PROFILE '" .. requested .. "'; using core", vim.log.levels.WARN)
	end
	M._current = valid(requested) and requested or read_saved() or "core"
	return M._current
end

function M.needs_selection()
	local requested = vim.env.NVIM_PROFILE
	return not valid(requested) and read_saved() == nil
end

function M.is(name)
	return M.current() == name
end

function M.paths()
	local profile = M.current()
	local data = vim.fn.stdpath("data")
	return {
		-- Plugins are shared. Profile-specific language tools are isolated below.
		lazy = data .. "/lazy",
		mason = data .. "/mason-" .. profile,
		treesitter = data .. "/treesitter-" .. profile,
		lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
	}
end

local function save(profile)
	vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")
	vim.fn.writefile({ profile }, state_file)
	M._current = profile
end

function M.restart()
	if #vim.fn.getbufinfo({ bufmodified = 1 }) > 0 then
		vim.notify("Profile saved. Restart Neovim after saving modified buffers.", vim.log.levels.WARN)
		return
	end

	vim.cmd("restart")
end

function M.select(on_choice)
	local choices = vim.tbl_keys(profiles)
	table.sort(choices)
	vim.ui.select(choices, {
		prompt = "LazyVim language profile",
		format_item = function(profile)
			return profiles[profile].label
		end,
	}, function(profile)
		if not profile then
			return
		end
		local previous = M.current()
		save(profile)
		if on_choice then
			on_choice(profile)
		elseif profile ~= previous then
			M.restart()
		else
			vim.notify("Already using the " .. profile .. " profile")
		end
	end)
end

function M.setup_command()
	vim.api.nvim_create_user_command("Profile", function()
		local previous = M.current()
		M.select(function(profile)
			if profile == previous then
				vim.notify("Already using the " .. profile .. " profile")
			else
				M.restart()
			end
		end)
	end, { desc = "Select and restart a LazyVim language profile" })
end

return M
