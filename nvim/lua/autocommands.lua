local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight current line on active window only
local active_line_highligh = augroup('HighlightActiveLine', { clear = true })
autocmd('WinEnter', {
  desc = 'show cursorline',
  callback = function() vim.wo.cursorline = true end,
  group = active_line_highligh
})
autocmd('WinLeave', {
  desc = 'hide cursorline',
  callback = function() vim.wo.cursorline = false end,
  group = active_line_highligh
})

-- Use vertical splits for help windows
local vertical_help = augroup('VerticalHelp', { clear = true })
autocmd('FileType', {
  desc = 'make help split vertical',
  pattern='help',
  command = 'wincmd L',
  group = vertical_help
})

-- Highlight yanked text
local highlight_yank = augroup('HighlightYank', { clear = true })
autocmd('TextYankPost', {
  desc = 'highlight yanked text',
  callback = function() vim.hl.on_yank({ higroup = 'IncSearch', timeout = 50 }) end,
  group = highlight_yank
})


-- open file at last position
local last_position = augroup('LastPosition', { clear = true })
vim.api.nvim_create_autocmd(
	"BufWinEnter",
	vim.tbl_extend("force", {
		desc = "jump to the last position when reopening a file",
		pattern = "*",
		command = [[ if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif ]],
	}, { group = last_position })
)

-- show lsp progress bar for lsp server
vim.api.nvim_create_autocmd("LspProgress", {
	callback = function(ev)
		local value = ev.data.params.value or {}
		local msg = value.message or "done"

		-- rust analyszer in particular has really long LSP messages so truncate them
		if #msg > 40 then
			msg = msg:sub(1, 37) .. "..."
		end

		-- :h LspProgress
		vim.api.nvim_echo({ { msg } }, false, {
			id = "lsp",
			kind = "progress",
			title = value.title,
			status = value.kind ~= "end" and "running" or "success",
			percent = value.percentage,
			source = "lsp",
		})
	end,
})
