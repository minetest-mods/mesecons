std = "lua51c"

ignore = {
	"21/_+", -- Unused variable, except "_", "__", etc.
	"213", -- Unused loop variable
	"421", -- Shadowing a local variable
	"422", -- Shadowing an argument
	"423", -- Shadowing a loop variable
	"431", -- Shadowing an upvalue
	"432", -- Shadowing an upvalue argument
	"433", -- Shadowing an upvalue loop variable
	"542", -- Empty if branch
}

max_line_length = 200

read_globals = {
	"default",
	"digiline",
	"doors",
	"dump",
	"jit",
	"minetest",
	"screwdriver",
	"string.split",
	"table.copy",
	"table.insert_all",
	"vector",
	"VoxelArea",
	"mcl_dyes",
	"mcl_sounds",
}

globals = {"mesecon"}

files["mesecons/actionqueue.lua"] = {
	globals = {"minetest.registered_globalsteps"},
}

-- Test-specific stuff follows.

local test_conf = {
	read_globals = {
		"assert",
		"fixture",
		"mineunit",
		"Player",
		"sourcefile",
		"world",
	},
}
files["*/spec/*.lua"] = test_conf
files[".test_fixtures/*.lua"] = test_conf

files[".test_fixtures/screwdriver.lua"] = {
	globals = {"screwdriver"},
}

files[".test_fixtures/mesecons_fpga.lua"] = {
	globals = {"minetest.register_on_player_receive_fields"},
}
