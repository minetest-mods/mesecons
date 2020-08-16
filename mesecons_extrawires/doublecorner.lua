local rotate
if minetest.global_exists("screwdriver") then rotate = screwdriver.rotate_simple end

local doublecorner_selectionbox = {
	type = "fixed",
	fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
}

local rules = {
	{
		{ x = 1, y = 0, z = 0 },
		{ x = 0, y = 0, z = 1 },
	},
	{
		{ x = -1, y = 0, z = 0 },
		{ x = 0, y = 0, z = -1 },
	},
}

local doublecorner_rules = {}
for k = 1, 4 do
	doublecorner_rules[k] = table.copy(rules)
	for i, r in ipairs(rules) do
		rules[i] = mesecon.rotate_rules_left(r)
	end
end

local function doublecorner_get_rules(node)
	return doublecorner_rules[node.param2 % 4 + 1]
end

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
		groups = groups,
		drop = doublecorner_states[1],
		sounds = default.node_sound_defaults(),
		mesecons = {
			conductor = {
				states = doublecorner_states,
				rules = doublecorner_get_rules,
			},
		},
		on_blast = mesecon.on_blastnode,
		on_rotate = rotate,
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
