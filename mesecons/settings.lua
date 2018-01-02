-- SETTINGS

-- legacy:
minetest.settings = minetest.settings or {
	get = function(_, k)
		return minetest.setting_get(k)
	end,
	get_bool = function(_, k, default)
		local s = minetest.setting_getbool(k)
		if s == nil then
			s = default
		end
		return s
	end,
	set = function(_, k, v)
		return minetest.setting_set(k, v)
	end,
	set_bool = function(_, k, v)
		return minetest.setting_setbool(k, v)
	end,
	get_names = function()
		return {}
	end,
	write = function()
		return minetest.setting_save()
	end,
}
-- do not use get_np_group, set_np_group, remove or to_table


function mesecon.setting(setting, default)
	if type(default) == "boolean" then
		local read = minetest.settings:get_bool("mesecon."..setting, default)
		 -- legacy:
		if read == nil then
			return default
		else
			return read
		end
	elseif type(default) == "string" then
		return minetest.settings:get("mesecon."..setting) or default
	elseif type(default) == "number" then
		return tonumber(minetest.settings:get("mesecon."..setting) or default)
	end
end
