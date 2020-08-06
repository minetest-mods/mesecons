local screwdriver_exists = minetest.global_exists("screwdriver")

local doublecorner_selectionbox = {
		type = "fixed",
		fixed = { -16/32, -16/32, -16/32, 16/32, -12/32, 16/32 },
}

local doublecorner_rules = {
	{--first wire
		{x=1,y=0,z=0},
		{x=0,y=0,z=1},
	},
	{--second wire
		{x=-1,y=0,z=0},
		{x=0,y=0,z=-1},
	},
}

local doublecorner_states = {
	"mesecons_extrawires:doublecorner_off",
	"mesecons_extrawires:doublecorner_01",
	"mesecons_extrawires:doublecorner_10",
	"mesecons_extrawires:doublecorner_on",
}
local wire1_states = {"off", "off", "on", "on"}
local wire2_states = {"off", "on", "off", "on"}

for k, state in ipairs(doublecorner_states) do
	w1 = wire1_states[k]
	w2 = wire2_states[k]
minetest.register_node(state, {
	drawtype = "mesh",
	mesh = "mesecons_extrawires_doublecorner.obj",
	description = "Insulated Mesecon Double Corner",
	tiles = {
		{ name = "jeija_insulated_wire_sides_" .. w1 .. ".png", backface_culling = true },
		{ name = "jeija_insulated_wire_ends_" .. w1 .. ".png", backface_culling = true },
		{ name = "jeija_insulated_wire_sides_" .. w2 .. ".png", backface_culling = true },
		{ name = "jeija_insulated_wire_ends_" .. w2 .. ".png", backface_culling = true },
	},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	walkable = false,
	sunlight_propagates = true,
	selection_box = doublecorner_selectionbox,
	groups = {dig_immediate = 3},
	drop = "mesecons_extrawires:doublecorner_off",
	sounds = default.node_sound_defaults(),
	mesecons = {
		conductor = {
			states = doublecorner_states,
			rules = doublecorner_rules,
		},
	},
	on_blast = mesecon.on_blastnode,
	on_rotate = screwdriver_exists and screwdriver.rotate_simple,
})
end

minetest.register_craft({
	type = "shapeless",
	output = "mesecons_extrawires:doublecorner_off",
	recipe = {
		"mesecons_extrawires:corner_off",
		"mesecons_extrawires:corner_off",
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "mesecons_extrawires:corner_off 2",
	recipe = {
		"mesecons_extrawires:doublecorner_off",
	},
})
