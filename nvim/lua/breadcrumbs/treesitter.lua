local name_regex = [=[[#~!@\*&.]*[[:keyword:]]\+!\?]=]
	.. [=[\(\(\(->\)\+\|-\+\|\.\+\|:\+\|\s\+\)\?[#~!@\*&.]*[[:keyword:]]\+!\?\)*]=]
local valid_types = {
	"array",
	"boolean",
	"break_statement",
	"call",
	"case_statement",
	"class",
	"constant",
	"constructor",
	"continue_statement",
	"delete",
	"do_statement",
	"element",
	"enum",
	"enum_member",
	"event",
	"for_statement",
	"function",
	"h1_marker",
	"h2_marker",
	"h3_marker",
	"h4_marker",
	"h5_marker",
	"h6_marker",
	"if_statement",
	"interface",
	"keyword",
	"macro",
	"method",
	"module",
	"namespace",
	"null",
	"number",
	"operator",
	"package",
	"pair",
	"property",
	"reference",
	"repeat",
	"rule_set",
	"scope",
	"specifier",
	"struct",
	"switch_statement",
	"table",
	"type",
	"type_parameter",
	"unit",
	"value",
	"variable",
	"while_statement",
	"declaration",
	"field",
	"identifier",
	"object",
	"statement",
}
symbols = {
	Array = "󰅪 ",
	Boolean = " ",
	BreakStatement = "󰙧 ",
	Call = "󰃷 ",
	CaseStatement = "󱃙 ",
	Class = " ",
	Color = "󰏘 ",
	Constant = "󰏿 ",
	Constructor = " ",
	ContinueStatement = "→ ",
	Copilot = " ",
	Declaration = "󰙠 ",
	Delete = "󰩺 ",
	DoStatement = "󰑖 ",
	Element = "󰅩 ",
	Enum = " ",
	EnumMember = " ",
	Event = " ",
	Field = " ",
	File = "󰈔 ",
	Folder = "󰉋 ",
	ForStatement = "󰑖 ",
	Function = "󰊕 ",
	H1Marker = "󰉫 ",
	H2Marker = "󰉬 ",
	H3Marker = "󰉭 ",
	H4Marker = "󰉮 ",
	H5Marker = "󰉯 ",
	H6Marker = "󰉰 ",
	Identifier = "󰀫 ",
	IfStatement = "󰇉 ",
	Interface = " ",
	Keyword = "󰌋 ",
	List = "󰅪 ",
	Log = "󰦪 ",
	Lsp = " ",
	Macro = "󰁌 ",
	MarkdownH1 = "󰉫 ",
	MarkdownH2 = "󰉬 ",
	MarkdownH3 = "󰉭 ",
	MarkdownH4 = "󰉮 ",
	MarkdownH5 = "󰉯 ",
	MarkdownH6 = "󰉰 ",
	Method = "󰆧 ",
	Module = "󰏗 ",
	Namespace = "󰅩 ",
	Null = "󰢤 ",
	Number = "󰎠 ",
	Object = "󰅩 ",
	Operator = "󰆕 ",
	Package = "󰆦 ",
	Pair = "󰅪 ",
	Property = " ",
	Reference = "󰦾 ",
	Regex = " ",
	Repeat = "󰑖 ",
	RuleSet = "󰅩 ",
	Scope = "󰅩 ",
	Snippet = "󰩫 ",
	Specifier = "󰦪 ",
	Statement = "󰅩 ",
	String = "󰉾 ",
	Struct = " ",
	SwitchStatement = "󰺟 ",
	Table = "󰅩 ",
	Terminal = " ",
	Text = " ",
	Type = " ",
	TypeParameter = "󰆩 ",
	Unit = " ",
	Value = "󰎠 ",
	Variable = "󰀫 ",
	WhileStatement = "󰑖 ",
}

---Initialize lsp source
---@return nil
local function init() end

---Convert a snake_case string to camelCase
---@param str string?
---@return string?
local function snake_to_camel(str)
	if not str then
		return nil
	end
	return (str:gsub("^%l", string.upper):gsub("_%l", string.upper):gsub("_", ""))
end

---Get short name of treesitter symbols in buffer buf
---@param node TSNode
---@param buf integer buffer handler
local function get_node_short_name(node, buf)
	return vim.trim(vim.fn.matchstr(vim.treesitter.get_node_text(node, buf):gsub("\n", " "), name_regex))
		:gsub("%s+", " ")
end

---Get valid treesitter node type name
---@param node TSNode
---@return string type_name
local function get_node_short_type(node)
	local ts_type = node:type()
	for _, type in ipairs(valid_types) do
		if vim.startswith(ts_type, type) then
			return type
		end
	end
	return ""
end

---Check if treesitter node is valid
---@param node TSNode
---@param buf integer buffer handler
---@return boolean
local function valid_node(node, buf)
	return get_node_short_type(node) ~= "" and get_node_short_name(node, buf) ~= ""
end

local function get_path(buf, win, cursor)
	local symbols = {}
	local ts_ok = pcall(vim.treesitter.get_parser, buf or 0)
	if not ts_ok then
		return {}
	end

	local node = vim.F.npcall(vim.treesitter.get_node, {
		ft = vim.filetype.match({ buf = buf }),
		bufnr = buf,
		pos = {
			cursor[1] - 1,
			cursor[2] - (cursor[2] >= 1 and vim.startswith(vim.fn.mode(), "i") and 1 or 0),
		},
	})

	print("node: " .. require("lungan.str").to_string(node:type()))

	---Convert TSNode into winbar symbol structure
	---@param ts_node TSNode
	---@param buf integer buffer handler
	---@param win integer window handler
	---@return dropbar_symbol_t?
	local function convert(ts_node, buf, win)
		if not valid_node(ts_node, buf) then
			return nil
		end
		local kind = snake_to_camel(get_node_short_type(ts_node))
		local range = { ts_node:range() }
		-- return bar.dropbar_symbol_t:new(setmetatable({
		return {
			buf = buf,
			win = win,
			name = get_node_short_name(ts_node, buf),
			icon = symbols[kind],
			type = kind,
			range = {
				start = {
					line = range[1],
					character = range[2],
				},
				["end"] = {
					line = range[3],
					character = range[4],
				},
			},
		}
	end

	while node and #symbols < 10 do -- configs.opts.sources.treesitter.max_depth do
		if valid_node(node, buf) then
			table.insert(symbols, 1, convert(node, buf, win))
		end
		node = node:parent()
	end

	return symbols
end

return {
	get_path = get_path,
}
