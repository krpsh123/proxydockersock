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

function M.ltrim(str)
  return string.match(str, "^%s*(.-)$")
end

function M.rtrim(str)
  return string.match(str, "^(.-)%s*$")
end

function M.trim(str)
  return string.match(str, "^%s*(.-)%s*$")
end

function M.script_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*/)")
end

-- https://stackoverflow.com/questions/1283388/how-to-merge-two-tables-overwriting-the-elements-which-are-in-both
function M.table_merge(t1, t2)
	for k,v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k] or false) == "table" then
				M.table_merge(t1[k] or {}, t2[k] or {})
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
	return t1
end


return M
