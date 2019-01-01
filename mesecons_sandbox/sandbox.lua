local BASE = minetest.get_modpath(minetest.get_current_modname())
local LIBS = BASE .. "/sandbox"

local function load_lib(name)
	local filename = string.format("%s/%s.lua", LIBS, name)
	local file = io.open(filename, "rb")
	local code = file:read("*a")
	file:close()
	return code
end

local f_init = load_lib("_init")
local f_fini = load_lib("_fini")
local f_helpers = load_lib("helpers")
local f_serialize = load_lib("serialize")
local c_test = load_lib("test")

print("Testing")
local a,b,c,d,e,f = libluabox.run(0.1, 128, f_helpers, f_serialize, f_init, c_test, f_fini)
print(a,b,c,d,e,f)
print("Tested")
