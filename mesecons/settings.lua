-- SETTINGS
function mesecon.setting(setting, default)
	if type(default) == "bool" then
		local setting = minetest.setting_getbool("mesecon."..setting)
		if setting == nil then
			return default
		end
		return setting
	elseif type(default) == "string" then
		return minetest.setting_get("mesecon."..setting) or default
	elseif type(default) == "number" then
		return tonumber(minetest.setting_get("mesecon."..setting) or default)
	end
end
