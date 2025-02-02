local M = {}

function M.dumpvar(data)
	-- cache of tables already printed, to avoid infinite recursive loops
	local tablecache = {}
	local buffer = ""
	local padder = "    "
	
	local function _dumpvar(d, depth)
		local t = type(d)
		local str = tostring(d)
		if (t == "table") then
			if (tablecache[str]) then
				-- table already dumped before, so we dont
				-- dump it again, just mention it
				buffer = buffer.."<"..str..">\n"
			else
				tablecache[str] = (tablecache[str] or 0) + 1
				buffer = buffer.."("..str..") {\n"
				for k, v in pairs(d) do
				     buffer = buffer..string.rep(padder, depth+1).."["..k.."] => "
				     _dumpvar(v, depth+1)
				end
				buffer = buffer..string.rep(padder, depth).."}\n"
			end
		elseif (t == "number") then
			buffer = buffer.."("..t..") "..str.."\n"
		else
			buffer = buffer.."("..t..") \""..str.."\"\n"
		end
	end
	_dumpvar(data, 0)
	return buffer
end

function M.split(str, sep)
	local result = {}
	local regex = ("([^%s]+)"):format(sep)
	for each in str:gmatch(regex) do
		table.insert(result, each)
	end
	return result
end

return M
