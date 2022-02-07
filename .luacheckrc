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
	"DIR_DELIM",
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
}

globals = {
	"mesecon",
	"minetest.registered_globalsteps",
}
