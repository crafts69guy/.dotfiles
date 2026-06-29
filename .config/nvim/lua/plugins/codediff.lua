local function apply_codediff_highlights()
	local hue = require("insideee-dev.hue_colors")
	local c = hue.get()
	local darken, lighten = hue.darken, hue.lighten

	local insert_bg = darken(c.success, 0.18, c.canvas)
	local delete_bg = darken(c.error, 0.18, c.canvas)
	local move_bg = darken(c.warning, 0.18, c.canvas)
	local insert_char_bg = darken(c.success, 0.45, c.canvas)
	local delete_char_bg = darken(c.error, 0.45, c.canvas)
	local move_char_bg = darken(c.warning, 0.45, c.canvas)
	local selection_bg = c.selected

	vim.api.nvim_set_hl(0, "CodeDiffLineInsert", { bg = insert_bg })
	vim.api.nvim_set_hl(0, "CodeDiffLineDelete", { bg = delete_bg })
	vim.api.nvim_set_hl(0, "CodeDiffCharInsert", { bg = insert_char_bg, fg = lighten(c.success, 0.9) })
	vim.api.nvim_set_hl(0, "CodeDiffCharDelete", { bg = delete_char_bg, fg = lighten(c.error, 0.9) })
	vim.api.nvim_set_hl(0, "CodeDiffFiller", { fg = c.border })
	vim.api.nvim_set_hl(0, "CodeDiffLineMove", { bg = move_bg })
	vim.api.nvim_set_hl(0, "CodeDiffCharMove", { bg = move_char_bg, fg = lighten(c.warning, 0.9) })
	vim.api.nvim_set_hl(0, "CodeDiffMoveFrom", { fg = c.warning, bg = "NONE" })
	vim.api.nvim_set_hl(0, "CodeDiffMoveTo", { fg = c.notice, bg = "NONE" })

	vim.api.nvim_set_hl(0, "CodeDiffStatusAdded", { fg = c.success })
	vim.api.nvim_set_hl(0, "CodeDiffStatusModified", { fg = c.warning })
	vim.api.nvim_set_hl(0, "CodeDiffStatusDeleted", { fg = c.error })
	vim.api.nvim_set_hl(0, "CodeDiffStatusRenamed", { fg = c.info })
	vim.api.nvim_set_hl(0, "CodeDiffStatusUntracked", { fg = c.secondary })
	vim.api.nvim_set_hl(0, "CodeDiffStatusConflict", { fg = c.warning, bold = true })
	vim.api.nvim_set_hl(0, "CodeDiffExplorerSelected", { bg = selection_bg, bold = true })

	vim.api.nvim_set_hl(0, "CodeDiffHelpSection", { fg = c.warning, bold = true })
	vim.api.nvim_set_hl(0, "CodeDiffHelpKey", { fg = c.info, bold = true })
	vim.api.nvim_set_hl(0, "CodeDiffHelpSep", { fg = c.border })
	vim.api.nvim_set_hl(0, "CodeDiffHelpDesc", { fg = c.subtext })
end

return {
	{
		"esmuellert/codediff.nvim",
		cmd = "CodeDiff",
		keys = {
			{ "<leader>gdd", "<cmd>CodeDiff<cr>", desc = "CodeDiff Status" },
			{ "<leader>gdf", "<cmd>CodeDiff file HEAD<cr>", desc = "CodeDiff File" },
			{ "<leader>gdh", "<cmd>CodeDiff history<cr>", desc = "CodeDiff History" },
			{ "<leader>gdm", "<cmd>CodeDiff main...<cr>", desc = "CodeDiff Main" },
			{ "<leader>gdi", "<cmd>CodeDiff --inline<cr>", desc = "CodeDiff Inline" },
			{ "<leader>gds", "<cmd>CodeDiff --side-by-side<cr>", desc = "CodeDiff Side-by-side" },
		},
		opts = {
			highlights = {
				line_insert = "CodeDiffLineInsert",
				line_delete = "CodeDiffLineDelete",
				char_insert = "CodeDiffCharInsert",
				char_delete = "CodeDiffCharDelete",
				conflict_sign = "CodeDiffStatusConflict",
				conflict_sign_resolved = "Comment",
				conflict_sign_accepted = "CodeDiffStatusAdded",
				conflict_sign_rejected = "CodeDiffStatusDeleted",
			},
			diff = {
				layout = "side-by-side",
				disable_inlay_hints = true,
				ignore_trim_whitespace = false,
				hide_merge_artifacts = true,
				cycle_hunks_across_files = false,
				jump_to_first_change = true,
				highlight_priority = 120,
				compute_moves = false,
				compact_context_lines = 3,
				compact_sync_folds = true,
			},
			explorer = {
				position = "left",
				hidden = false,
				width = 40,
				auto_refresh = true,
				indent_markers = true,
				view_mode = "list",
				flatten_dirs = true,
				initial_focus = "explorer",
				file_filter = {
					ignore = { ".git/**", ".jj/**", "node_modules/**", "dist/**", "build/**" },
				},
			},
			history = {
				position = "bottom",
				height = 15,
				initial_focus = "history",
				view_mode = "list",
			},
			keymaps = {
				view = {
					focus_explorer = "ge",
					toggle_explorer = "gb",
				},
			},
		},
		config = function(_, opts)
			apply_codediff_highlights()
			require("codediff").setup(opts)

			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("codediff_hue", { clear = true }),
				callback = apply_codediff_highlights,
			})
		end,
	},
}
