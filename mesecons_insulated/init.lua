local S = minetest.get_translator(minetest.get_current_modname())

local insulated_wire_get_rules = mesecon.horiz_rules_getter({
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
})

minetest.register_node("mesecons_insulated:insulated_on", {
	drawtype = "nodebox",
	description = S("Straight Insulated Mesecon"),
	tiles = {
		"jeija_insulated_wire_sides_on.png",
		"jeija_insulated_wire_sides_on.png",
		"jeija_insulated_wire_ends_on.png",
		"jeija_insulated_wire_ends_on.png",
		"jeija_insulated_wire_sides_on.png",
		"jeija_insulated_wire_sides_on.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	walkable = false,
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = { -16/32, -16/32, -7/32, 16/32, -12/32, 7/32 }
	},
	node_box = {
		type = "fixed",
		-- ±0.001 is to prevent z-fighting
		fixed = { -16/32-0.001, -17/32, -3/32, 16/32+0.001, -13/32, 3/32 }
	},
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	drop = "mesecons_insulated:insulated_off",
	sounds = mesecon.node_sound.default,
	mesecons = {conductor = {
		state = mesecon.state.on,
		offstate = "mesecons_insulated:insulated_off",
		rule_node_nocopy = true,
		rules = insulated_wire_get_rules
	}},
	on_blast = mesecon.on_blastnode,
	on_rotate = mesecon.on_rotate_horiz,
})

minetest.register_node("mesecons_insulated:insulated_off", {
	drawtype = "nodebox",
	description = S("Straight Insulated Mesecon"),
	tiles = {
		"jeija_insulated_wire_sides_off.png",
		"jeija_insulated_wire_sides_off.png",
		"jeija_insulated_wire_ends_off.png",
		"jeija_insulated_wire_ends_off.png",
		"jeija_insulated_wire_sides_off.png",
		"jeija_insulated_wire_sides_off.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	walkable = false,
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = { -16/32, -16/32, -7/32, 16/32, -12/32, 7/32 }
	},
	node_box = {
		type = "fixed",
		-- ±0.001 is to prevent z-fighting
		fixed = { -16/32-0.001, -17/32, -3/32, 16/32+0.001, -13/32, 3/32 }
	},
	groups = {dig_immediate = 3},
	sounds = mesecon.node_sound.default,
	mesecons = {conductor = {
		state = mesecon.state.off,
		onstate = "mesecons_insulated:insulated_on",
		rule_node_nocopy = true,
		rules = insulated_wire_get_rules
	}},
	on_blast = mesecon.on_blastnode,
	on_rotate = mesecon.on_rotate_horiz,
})

minetest.register_craft({
	output = "mesecons_insulated:insulated_off 3",
	recipe = {
		{"mesecons_materials:fiber", "mesecons_materials:fiber", "mesecons_materials:fiber"},
		{"group:mesecon_conductor_craftable", "group:mesecon_conductor_craftable", "group:mesecon_conductor_craftable"},
		{"mesecons_materials:fiber", "mesecons_materials:fiber", "mesecons_materials:fiber"},
	}
})
