-- claude-statusline.nvim: Claude Code status line renderer + `:ClaudeStatusline playground`.
-- Plugin source lives in its own repo; use the local checkout when present.
local local_dir = vim.fn.expand("~/Developments/github.com/crafts69guy/claude-statusline.nvim")
local source = vim.uv.fs_stat(local_dir) and { dir = local_dir, name = "claude-statusline.nvim" }
	or { "crafts69guy/claude-statusline.nvim" }

return {
	vim.tbl_extend("force", source, {
		main = "claude_statusline",
		cmd = "ClaudeStatusline",
		opts = {},
	}),
}
