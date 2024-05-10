local group = vim.api.nvim_create_augroup("SpielhuusAutoCmdsGroup", { clear = true })

-- open file at last position
vim.api.nvim_create_autocmd("BufWinEnter", vim.tbl_extend("force", {
		desc = "jump to the last position when reopening a file",
		pattern = "*",
		command = [[ if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif ]],
	}, { group = group }))


-- remove trailing whitespaces on save.
vim.api.nvim_create_autocmd("BufWritePre", vim.tbl_extend("force", {
		desc = "remove whitespaces on save",
		pattern = "*",
		command = "%s/\\s\\+$//e",
	}, { group = group }))

-- highlight text on yank.
vim.api.nvim_create_autocmd("TextYankPost", vim.tbl_extend("force", {
		desc = "highlight text on yank",
		pattern = "*",
		callback = function()
			vim.highlight.on_yank({
				higroup = "Search",
				timeout = 150,
				on_visual = true,
			})
		end,
	}, { group = group }))
