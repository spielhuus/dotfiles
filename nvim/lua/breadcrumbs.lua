local M = {}

M.buffers = {}

M.langs = { "lua", "python", "rust" }

function M.supported(lang)
	for _, l in ipairs(M.langs) do
		if l == lang then
			return true
		end
	end
	return false
end

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		M.buffers[args.buf] = args
		M.load_lsp_data(args.buf)
	end,
})

vim.api.nvim_create_autocmd("LspTokenUpdate", {
	callback = function(args)
		require("lungan.log").debug("Update", args, vim.lsp.status())
		M.buffers[args.buf] = args
		M.load_lsp_data(args.buf)
		vim.opt.titlestring = M.get_path(args.buf)
	end,
})

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorHold" }, {
	callback = function(args)
		if vim.api.nvim_buf_is_valid(args.buf) then
			vim.opt.titlestring = M.get_path(args.buf)
		end
	end,
})

local icons = {
	[1] = "󰈙 ", -- File
	[2] = " ", -- Module
	[3] = "󰌗 ", -- Namespace
	[4] = "󰄾 ", -- Package
	[5] = "󰌗 ", -- Class
	[6] = "󰆧 ", -- Method
	[7] = " ", -- Property
	[8] = " ", -- Field
	[9] = " ", -- Constructor
	[10] = "󰕘 ", -- Enum
	[11] = "󰕘 ", -- Interface
	[12] = "󰊕 ", -- Function
	[13] = "", -- Variable
	[14] = "󰅴 ", -- Constant
	[15] = "󰀬 ", -- String
	[16] = "󰎠 ", -- Number
	[17] = "◩ ", -- Boolean
	[18] = "󰅪 ", -- Array
	[19] = "󰅩 ", -- Object
	[20] = "󰌋 ", -- Key
	[21] = "󰟢 ", -- Null
	[22] = " ", -- EnumMember
	[23] = "󰌗 ", -- Struct
	[24] = " ", -- Event
	[25] = "󰆕 ", -- Operator
	[26] = "󰊄 ", -- TypeParameter
	[255] = "󰉨 ", -- Macro
}

function M.load_lsp_data(buf)
	local args = M.buffers[buf]
	if not args then
		return
	end
	local client = vim.lsp.get_client_by_id(args.data.client_id)
	assert(client)
	if not client.server_capabilities.documentSymbolProvider then
		return
	end

	-- Request the current function name and class name
	local params = vim.lsp.util.make_text_document_params()

	client.request("textDocument/documentSymbol", { textDocument = params }, function(err, symbols, _)
		if err or not symbols then
			return
		end
		M.buffers[buf]["symbols"] = symbols
		vim.opt.titlestring = M.get_path(args.buf)
	end, buf)
end

local function get_next(line, symbols, results)
	for _, s in ipairs(symbols) do
		local from = s["range"]["start"]["line"]
		local to = s["range"]["end"]["line"]
		if line >= from and line <= to then
			table.insert(results, { kind = s.kind, name = s.name, detail = s.detail })
			if s["children"] then
				get_next(line, s["children"], results)
			end
		end
	end
end

function M.find_project_root(path)
	local results = {}
	local token = vim.fn.fnamemodify(path, ":t")
	path = vim.fn.fnamemodify(path, ":h")
	while true do
		if path == "/" then
			table.insert(results, 1, { type = "dir", item = "/" .. token })
			return results
		end
		if vim.fn.isdirectory(path .. "/.git") == 1 then
			table.insert(results, 1, { type = "dir", item = token })
			return results
		elseif vim.fn.isdirectory(path) == 1 then
			table.insert(results, 1, { type = "dir", item = token })
		else
			error("unknown type: " .. path)
		end
		token = vim.fn.fnamemodify(path, ":t")
		path = vim.fn.fnamemodify(path, ":h")
	end
end

local function is_valid_buffer(buf)
	if
		vim.api.nvim_get_option_value("buftype", { buf = buf }) == ""
		and vim.api.nvim_get_option_value("readonly", { buf = buf }) == false
		and vim.api.nvim_buf_is_valid(buf)
		and vim.api.nvim_buf_is_loaded(buf)
	then
		return true
	end
	return false
	-- fied: " .. vim.inspect(vim.api.nvim_get_option_value("modified", { buf = buf })))
end

function M.get_path(buf)
	local filetype = vim.bo[buf].filetype
	local path = vim.fn.simplify(vim.api.nvim_buf_get_name(buf))
	local line
	if is_valid_buffer(buf) then
		local pathlist = M.find_project_root(path)
		if M.supported(filetype) then
			line = filetype .. " "
		else
			line = "nvim "
		end
		local first = true
		for i, t in ipairs(pathlist) do
			if first then
				line = line .. "  "
				first = false
			end
			if i == 1 then
				line = line .. t.item
			else
				line = line .. "/" .. t.item
			end
		end
	else
		line = path
	end

	if M.buffers[buf] and M.buffers[buf]["symbols"] then
		local symbols = M.buffers[buf]["symbols"]
		if symbols then
			local lsp_results = {}
			get_next(vim.fn.line(".") - 1, symbols, lsp_results)
			for _, lsp in ipairs(lsp_results) do
				line = line .. " " .. icons[lsp.kind] .. " " .. lsp.name
			end
		end
	end

	return line
end

return M
