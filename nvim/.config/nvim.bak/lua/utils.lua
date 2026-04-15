local M = {}

function M.command_exists(cmd)
	local handle = io.popen("command -v " .. cmd .. " 2>/dev/null")
	local result = handle:read("*a")
	handle:close()
	return result ~= ""
end

return M
