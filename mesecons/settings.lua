-- SETTINGS
function mesecon.setting(setting, default)
	if type(default) == "boolean" then
		local read = minetest.setting_getbool("mesecon."..setting)
		if read == nil then
			return default
		else
			return read
		end
	elseif type(default) == "string" then
		return minetest.setting_get("mesecon."..setting) or default
	elseif type(default) == "number" then
		return tonumber(minetest.setting_get("mesecon."..setting) or default)
	end
end
