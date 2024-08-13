local yaml   = require("tinyyaml")
local util   = require("myutil")

local M = {}

-- All possible restrictions should be described here.
local function get_default_acl()
	return {
		containers = {
			create = {
				allow = true,
				json  = {
					HostConfig = {
						Privileged = false, -- --privileged
					},
					Volumes = {},
				},
			}
		}
	}
end

-- TODO make a check
local function check_acl(merget_acl)
	return merget_acl
end

function M.parse_acl(user)
	local file, err = io.open(util.script_path().."../acl.yaml", "r")
	if not file then
		return nil, err
	end
	local file_content = file:read('*a');
	file:close()
	
	
	-- the file is all commented out
	local file_is_all_commented = true
	for _, line in pairs(util.split(file_content, "\n")) do
		local ls = string.find(line, "^#")
		if ls == nil then
			if string.len(util.trim(line)) ~= 0 then
				file_is_all_commented = false
				break
			end
		end
	end
	
	
	local default_acl = get_default_acl()
	
	if file_is_all_commented then
		return default_acl
	end
	
	
	local yaml = yaml.parse(file_content)
	
	if yaml["users"] == nil then
		return default_acl
	end
	
	if yaml.users[user] == nil then
		return default_acl
	end
	
	
	-- TODO: If the types of identical keys in the tables do not match,
	-- then the key type will change in the default acl list.
	-- see function "check_acl"
	local merget_acl = util.table_merge(default_acl, yaml.users[user])
	
	return check_acl(merget_acl)
end

return M
