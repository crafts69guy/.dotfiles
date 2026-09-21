-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	command = "set nopaste",
})

-- Spellcheck only in code filetypes (treesitter limits it to comments/strings).
-- Global `spell` is off because it loads the dictionary at startup.
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("code_spell", { clear = true }),
	pattern = {
		"typescript",
		"typescriptreact",
		"javascript",
		"javascriptreact",
		"lua",
		"go",
		"rust",
		"sh",
		"fish",
		"astro",
	},
	callback = function()
		vim.opt_local.spell = true
	end,
})

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "json", "jsonc", "markdown" },
	callback = function()
		vim.opt.conceallevel = 0
	end,
})
