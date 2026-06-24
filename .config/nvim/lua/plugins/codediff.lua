local function apply_codediff_highlights()
	local colors = require("solarized-osaka.colors").setup()
	local darken = require("solarized-osaka.util").darken
	local lighten = require("solarized-osaka.util").lighten

	local insert_bg = darken(colors.green500, 0.18, colors.base04)
	local delete_bg = darken(colors.red500, 0.18, colors.base04)
	local move_bg = darken(colors.yellow500, 0.18, colors.base04)
	local insert_char_bg = darken(colors.green500, 0.45, colors.base04)
	local delete_char_bg = darken(colors.red500, 0.45, colors.base04)
	local move_char_bg = darken(colors.yellow500, 0.45, colors.base04)
	local selection_bg = colors.base02

	vim.api.nvim_set_hl(0, "CodeDiffLineInsert", { bg = insert_bg })
	vim.api.nvim_set_hl(0, "CodeDiffLineDelete", { bg = delete_bg })
	vim.api.nvim_set_hl(0, "CodeDiffCharInsert", { bg = insert_char_bg, fg = lighten(colors.green500, 0.9) })
	vim.api.nvim_set_hl(0, "CodeDiffCharDelete", { bg = delete_char_bg, fg = lighten(colors.red500, 0.9) })
	vim.api.nvim_set_hl(0, "CodeDiffFiller", { fg = colors.base01 })
	vim.api.nvim_set_hl(0, "CodeDiffLineMove", { bg = move_bg })
	vim.api.nvim_set_hl(0, "CodeDiffCharMove", { bg = move_char_bg, fg = lighten(colors.yellow500, 0.9) })
	vim.api.nvim_set_hl(0, "CodeDiffMoveFrom", { fg = colors.orange500 or colors.orange, bg = "NONE" })
	vim.api.nvim_set_hl(0, "CodeDiffMoveTo", { fg = colors.yellow500 or colors.yellow, bg = "NONE" })

	vim.api.nvim_set_hl(0, "CodeDiffStatusAdded", { fg = colors.green500 or colors.green })
	vim.api.nvim_set_hl(0, "CodeDiffStatusModified", { fg = colors.yellow500 or colors.yellow })
	vim.api.nvim_set_hl(0, "CodeDiffStatusDeleted", { fg = colors.red500 or colors.red })
	vim.api.nvim_set_hl(0, "CodeDiffStatusRenamed", { fg = colors.cyan500 or colors.cyan })
	vim.api.nvim_set_hl(0, "CodeDiffStatusUntracked", { fg = colors.violet500 or colors.violet })
	vim.api.nvim_set_hl(0, "CodeDiffStatusConflict", { fg = colors.orange500 or colors.orange, bold = true })
	vim.api.nvim_set_hl(0, "CodeDiffExplorerSelected", { bg = selection_bg, bold = true })

	vim.api.nvim_set_hl(0, "CodeDiffHelpSection", { fg = colors.yellow500 or colors.yellow, bold = true })
	vim.api.nvim_set_hl(0, "CodeDiffHelpKey", { fg = colors.cyan500 or colors.cyan, bold = true })
	vim.api.nvim_set_hl(0, "CodeDiffHelpSep", { fg = colors.base01 })
	vim.api.nvim_set_hl(0, "CodeDiffHelpDesc", { fg = colors.base0 })
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
				group = vim.api.nvim_create_augroup("codediff_solarized_osaka", { clear = true }),
				callback = apply_codediff_highlights,
			})
		end,
	},
}
