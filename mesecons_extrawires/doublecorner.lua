local S = minetest.get_translator(minetest.get_current_modname())

local doublecorner_selectionbox = {
	type = "fixed",
	fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
}

local doublecorner_get_rules = mesecon.horiz_rules_getter({
	{
		{ x = 1, y = 0, z = 0 },
		{ x = 0, y = 0, z = 1 },
	},
	{
		{ x = -1, y = 0, z = 0 },
		{ x = 0, y = 0, z = -1 },
	},
})

local doublecorner_states = {
	"mesecons_extrawires:doublecorner_00",
	"mesecons_extrawires:doublecorner_01",
	"mesecons_extrawires:doublecorner_10",
	"mesecons_extrawires:doublecorner_11",
}
local wire1_states = { "off", "off", "on", "on" }
local wire2_states = { "off", "on", "off", "on" }

for k, state in ipairs(doublecorner_states) do
	local w1 = wire1_states[k]
	local w2 = wire2_states[k]
	local groups =  { dig_immediate = 3 }
	if k ~= 1 then groups.not_in_creative_inventory = 1 end
	minetest.register_node(state, {
		drawtype = "mesh",
		mesh = "mesecons_extrawires_doublecorner.obj",
		description = S("Insulated Mesecon Double Corner"),
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
		groups = groups,
		drop = doublecorner_states[1],
		sounds = mesecon.node_sound.default,
		mesecons = {
			conductor = {
				states = doublecorner_states,
				rule_node_nocopy = true,
				rules = doublecorner_get_rules,
			},
		},
		on_blast = mesecon.on_blastnode,
		on_rotate = mesecon.on_rotate_horiz,
	})
end

minetest.register_craft({
	type = "shapeless",
	output = "mesecons_extrawires:doublecorner_00",
	recipe = {
		"mesecons_extrawires:corner_off",
		"mesecons_extrawires:corner_off",
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "mesecons_extrawires:corner_off 2",
	recipe = {
		"mesecons_extrawires:doublecorner_00",
	},
})
