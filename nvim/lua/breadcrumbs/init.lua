local lsp = require("breadcrumbs.lsp")
local fs = require("breadcrumbs.fs")

local options = {
	langs = { "lua", "python", "rust" },
	symbols = {
		path = "",
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
	},
}

local function supported(lang)
	for _, l in ipairs(options.langs) do
		if l == lang then
			return true
		end
	end
	return false
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
end

local function get_path(buf)
	local line = ""

	local filetype = vim.bo[buf].filetype
	-- add the window title name
	if supported(filetype) then
		line = filetype .. " "
	else
		line = "nvim "
	end
	-- add the filepath
	for i, entry in ipairs(fs.get_path(buf)) do
		if i == 1 then
			line = line .. entry["name"]
		else
			line = line .. " " .. options.symbols.path .. " " .. entry["name"]
		end
	end
	-- add the lsp symbols
	if lsp.get_path(buf) then
		line = line .. " "
		for _, entry in ipairs(lsp.get_path(buf)) do
			line = line .. " " .. options.symbols[entry.kind] .. " " .. entry["name"]
		end
	end

	return line
end

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorHold" }, {
	callback = function(args)
		if is_valid_buffer(args.buf) then
			vim.opt.titlestring = get_path(args.buf)
		end
	end,
})

vim.api.nvim_create_autocmd("LspTokenUpdate", {
	callback = function(args)
		vim.opt.titlestring = get_path(args.buf)
	end,
})

return {
	setup = function() end,
	update = function(buf)
		vim.opt.titlestring = get_path(buf)
	end,
}
