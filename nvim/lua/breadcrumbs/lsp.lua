local loaded = false
local groupid = vim.api.nvim_create_augroup("BreadcrumbLsp", {})
local sources = {}
local lsp_commands = {}

---Update LSP symbols from an LSP client
---Side effect: update symbol_list
---@param buf integer buffer handler
---@param ttl integer? limit the number of recursive requests, default 60
local function update_symbols(buf, ttl)
	ttl = ttl or 60
	if ttl <= 0 or not vim.api.nvim_buf_is_valid(buf) then
		sources[buf] = nil
		return
	end

	local function _defer_update_symbols()
		vim.defer_fn(function()
			update_symbols(buf, ttl - 1)
		end, 1000)
	end

	local client = vim.tbl_filter(
		function(client)
			return client.supports_method("textDocument/documentSymbol")
		end,
		vim.lsp.get_clients({
			bufnr = buf,
		})
	)[1]
	if not client then
		_defer_update_symbols()
		return
	end

	client.request(
		"textDocument/documentSymbol",
		{ textDocument = vim.lsp.util.make_text_document_params(buf) },
		function(err, symbols, _)
			if err or not symbols or vim.tbl_isempty(symbols) then
				_defer_update_symbols()
				return
			end

			sources[buf] = symbols
			require("breadcrumbs").update(buf)
		end,
		buf
	)
end

local function attach(buf)
	update_symbols(buf)
	lsp_commands[buf] = vim.api.nvim_create_autocmd(
		{ "BufModifiedSet", "FileChangedShellPost", "TextChanged", "ModeChanged" },
		{
			group = groupid,
			buffer = buf,
			callback = function(info)
				update_symbols(info.buf)
			end,
		}
	)
end

---Initialize lsp source
---@return nil
local function init()
	if loaded then
		return
	end
	loaded = true

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local clients = vim.tbl_filter(function(client)
			return client.supports_method("textDocument/documentSymbol")
		end, vim.lsp.get_clients({ bufnr = buf }))
		if not vim.tbl_isempty(clients) then
			attach(buf)
		end
	end

	vim.api.nvim_create_autocmd({ "LspAttach" }, {
		desc = "Attach LSP symbol getter to buffer when an LS that supports documentSymbol attaches.",
		group = groupid,
		callback = function(info)
			if info.data then
				local client = vim.lsp.get_client_by_id(info.data.client_id)
				if client and client:supports_method("textDocument/documentSymbol") then
					attach(info.buf)
				end
			end
		end,
	})

	vim.api.nvim_create_autocmd({ "LspDetach" }, {
		desc = "Detach LSP symbol getter from buffer when no LS supporting documentSymbol is attached.",
		group = groupid,
		callback = function(info)
			if
				vim.tbl_isempty(vim.tbl_filter(function(client)
					return client.supports_method("textDocument/documentSymbol") and client.id ~= info.data.client_id
				end, vim.lsp.get_clients({ bufnr = info.buf })))
			then
				if lsp_commands[info.buf] then
					vim.api.nvim_del_autocmd(lsp_commands[info.buf])
					lsp_commands[info.buf] = nil
				end
				sources[info.buf] = nil
			end
		end,
	})

	vim.api.nvim_create_autocmd({ "BufDelete", "BufUnload", "BufWipeOut" }, {
		desc = "Detach LSP symbol getter from buffer on buffer delete/unload/wipeout.",
		group = groupid,
		callback = function(info)
			if lsp_commands[info.buf] then
				vim.api.nvim_del_autocmd(lsp_commands[info.buf])
				lsp_commands[info.buf] = nil
			end
			sources[info.buf] = nil
		end,
	})
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

local function get_path(buf)
	init()
	buf = buf or vim.api.nvim_get_current_buf()
	if sources[buf] then
		local lsp_results = {}
		get_next(vim.fn.line(".") - 1, sources[buf], lsp_results)
		return lsp_results
	end
end

return {
	get_path = get_path,
}
