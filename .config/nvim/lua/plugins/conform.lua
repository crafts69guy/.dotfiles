-- JS-family formatters from the biome/oxc/prettier extras, in priority order.
-- Ordered by how explicit their project config is: oxfmt also matches
-- vite.config.*, so it only wins when neither biome nor prettier is configured.
local js_formatters = { "biome-check", "prettier", "oxfmt" }

return {
	"stevearc/conform.nvim",
	opts = function(_, opts)
		opts.formatters_by_ft = opts.formatters_by_ft or {}
		opts.formatters = opts.formatters or {}

		-- Lua formatting (not covered by extras)
		opts.formatters_by_ft.lua = { "stylua" }

		-- conform's oxfmt has no config gate; without this it formats every
		-- JS/TS file with oxfmt defaults, even in projects that don't use it.
		opts.formatters.oxfmt = vim.tbl_deep_extend("force", opts.formatters.oxfmt or {}, { require_cwd = true })

		for ft, list in pairs(opts.formatters_by_ft) do
			if type(list) == "table" then
				-- Extras append independently, so the same formatter can appear twice.
				local seen, deduped = {}, {}
				for _, name in ipairs(list) do
					if not seen[name] then
						seen[name] = true
						deduped[#deduped + 1] = name
					end
				end

				-- When only JS-family formatters are listed, run the first one whose
				-- project config exists instead of chaining them (they conflict).
				local js_only = #deduped > 1
					and vim.iter(deduped):all(function(name)
						return vim.list_contains(js_formatters, name)
					end)
				if js_only then
					deduped = vim.tbl_filter(function(name)
						return seen[name]
					end, js_formatters)
					deduped.stop_after_first = true
				end

				opts.formatters_by_ft[ft] = deduped
			end
		end
		return opts
	end,
}
