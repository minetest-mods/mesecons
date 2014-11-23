-- SETTINGS
function mesecon.setting(setting, default)
	if type(default) == "bool" then
		return minetest.setting_getbool("mesecon."..setting) or default
	elseif type(default) == "string" then
		return minetest.setting_get("mesecon."..setting) or default
	elseif type(default) == "number" then
		return tonumber(minetest.setting_get("mesecon."..setting) or default)
	end
end
