-- CODE NOT ACTIVE

local crossing_get_rules = function(node)
	--TODO: calculate the real port states and use rules to link to them only if 
end

minetest.register_node("mesecons_extrawires:crossing_on", {
	drawtype = "nodebox",
	tiles = {"jeija_insulated_wire_sides.png"},
	paramtype = "light",
	walkable = false,
	stack_max = 99,
	selection_box = {type="fixed", fixed={-16/32-0.0001, -18/32, -16/32-0.001, 16/32+0.001, -5/32, 16/32+0.001}},
	node_box = {
		type = "fixed",
		fixed = {
			{ -16/32-0.001, -17/32, -3/32, 16/32+0.001, -13/32, 3/32 },
			{ -3/32, -17/32, -16/32-0.001, 3/32, -13/32, -6/32 },
			{ -3/32, -13/32, -9/32, 3/32, -6/32, -6/32 },
			{ -3/32, -9/32, -9/32, 3/32, -6/32, 9/32 },
			{ -3/32, -13/32, 6/32, 3/32, -6/32, 9/32 },
			{ -3/32, -17/32, 6/32, 3/32, -13/32, 16/32+0.001 },
		},
	},
	groups = {dig_immediate=3, mesecon=3, mesecon_conductor_craftable=1, not_in_creative_inventory=1},
	mesecons = {
		receptor = {
			state = mesecon.state.on,
			rules = crossing_get_rules,
		}
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "mesecons_extrawires:crossing",
	recipe = {
		"mesecons_insulated:insulated_off",
		"mesecons_insulated:insulated_off",
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "mesecons_insulated:insulated_off 2",
	recipe = {
		"mesecons_extrawires:crossing",
	},
})
