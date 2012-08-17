minetest.register_node("mesecons_isolated:isolated_on", {
	drawtype = "nodebox",
	description = "isolated mesecons",
	tiles = {
		"jeija_isolated_wire_sides.png",
		"jeija_isolated_wire_sides.png",
		"jeija_isolated_wire_ends_on.png",
		"jeija_isolated_wire_ends_on.png",
		"jeija_isolated_wire_sides.png",
		"jeija_isolated_wire_sides.png"
	},
	paramtype = "light",
	walkable = false,
	stack_max = 99,
	selection_box = {
		type = "fixed",
		fixed = { -16/32-0.001, -19/32, -5/32, 16/32+0.001, -11/32, 5/32 }
	},
	node_box = {
		type = "fixed",
		fixed = { -16/32-0.001, -17/32, -3/32, 16/32+0.001, -13/32, 3/32 }
	},
	groups = {dig_immediate = 3, mesecon = 3, mesecon_conductor_craftable=1},
	drop = "mesecons_isolated:isolated_off",

})

minetest.register_node("mesecons_isolated:isolated_off", {
	drawtype = "nodebox",
	description = "isolated mesecons",
	tiles = {
		"jeija_isolated_wire_sides.png",
		"jeija_isolated_wire_sides.png",
		"jeija_isolated_wire_ends_off.png",
		"jeija_isolated_wire_ends_off.png",
		"jeija_isolated_wire_sides.png",
		"jeija_isolated_wire_sides.png"
	},
	paramtype = "light",
	walkable = false,
	stack_max = 99,
	selection_box = {
		type = "fixed",
		fixed = { -16/32-0.001, -19/32, -5/32, 16/32+0.001, -11/32, 5/32 }
	},
	node_box = {
		type = "fixed",
		fixed = { -16/32-0.001, -17/32, -3/32, 16/32+0.001, -13/32, 3/32 }
	},
	groups = {dig_immediate = 3, mesecon = 3, mesecon_conductor_craftable=1, not_in_creative_inventory = 1},
})

mesecon:add_rules("isolated", {
{x = 1,  y = 0,  z = 0},
{x =-1,  y = 0,  z = 0},})

mesecon:register_conductor("mesecons_isolated:isolated_on", "mesecons_isolated:isolated_off", mesecon:get_rules("isolated"))
