-- SETTINGS

-- legacy:
minetest.settings = minetest.settings or {
	get = function(_, k)
		return minetest.setting_get(k)
	end,
	get_bool = function(_, k, default)
		local s = minetest.setting_getbool(k)
		if s == nil then
			return default
		end
		return s
	end,
	set = function(_, k, v)
		return minetest.setting_set(k, v)
	end,
	set_bool = function(_, k, v)
		return minetest.setting_setbool(k, v)
	end,
}
-- do not use get_np_group, set_np_group, remove, get_names, write or to_table


function mesecon.setting(setting, default)
	if type(default) == "boolean" then
		local read = minetest.settings:get_bool("mesecon."..setting, default)
		if read == nil then -- legacy
			return default
		end
		return read
	elseif type(default) == "string" then
		return minetest.settings:get("mesecon."..setting) or default
	elseif type(default) == "number" then
		return tonumber(minetest.settings:get("mesecon."..setting) or default)
	end
end
