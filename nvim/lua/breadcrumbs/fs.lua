local symbols = {}

local function find_project_root(path)
	local results = {}
	local token = vim.fn.fnamemodify(path, ":t")
	path = vim.fn.fnamemodify(path, ":h")
	while true do
		if path == "/" then
			table.insert(results, 1, { type = "dir", name = "/" .. token })
			return results
		end
		if vim.fn.isdirectory(path .. "/.git") == 1 then
			table.insert(results, 1, { type = "dir", name = token })
			return results
		elseif vim.fn.isdirectory(path) == 1 then
			table.insert(results, 1, { type = "dir", name = token })
		elseif path == "health:" then
			table.insert(results, 1, { type = "dir", name = "health" })
      return results
		else
			table.insert(results, 1, { type = "dir", name = path })
      return results
			-- error("unknown type: '" .. path .. "'")
		end
		token = vim.fn.fnamemodify(path, ":t")
		path = vim.fn.fnamemodify(path, ":h")
	end
end

local function get_path(buf)
	if not symbols[buf] then
		local path = vim.fn.simplify(vim.api.nvim_buf_get_name(buf))
		symbols[buf] = find_project_root(path)
	end
	return symbols[buf]
end

return {
	get_path = get_path,
}
