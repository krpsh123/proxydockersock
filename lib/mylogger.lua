local M = {}

local function logger(prfx, ...)
	io.stderr:write(prfx .. os.time() .. "; " .. string.format(...), "\n")
end

function M.info(...)
	logger("INFO; ", ...)
end

function M.warn(...)
	logger("WARN; ", ...)
end

function M.debug(...)
	logger("DEBU; ", ...)
end

function M.err(...)
	logger("ERRO; ", ...)
end

return M
