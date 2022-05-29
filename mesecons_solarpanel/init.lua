-- Solar Panel
mesecon.register_node("mesecons_solarpanel:solar_panel", {
	description = "Solar Panel",
	drawtype = "nodebox",
	tiles = {"mesecons_solarpanel.png"},
	inventory_image = "mesecons_solarpanel.png",
	wield_image = "mesecons_solarpanel.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	is_ground_content = false,
	node_box = {
		type = "wallmounted",
		wall_bottom = {-7/16, -8/16, -7/16,  7/16, -7/16, 7/16},
		wall_top    = {-7/16,  7/16, -7/16,  7/16,  8/16, 7/16},
		wall_side   = {-8/16, -7/16, -7/16, -7/16,  7/16, 7/16},
	},
	sounds = mesecon.node_sound.glass,
	on_blast = mesecon.on_blastnode,
},{
	groups = {dig_immediate = 3},
	mesecons = {receptor = {
		state = mesecon.state.off,
		rule_node_nocopy = true,
		rules = mesecon.rules.wallmounted_get
	}}
},{
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	mesecons = {receptor = {
		state = mesecon.state.on,
		rule_node_nocopy = true,
		rules = mesecon.rules.wallmounted_get
	}},
})

minetest.register_craft({
	output = "mesecons_solarpanel:solar_panel_off",
	recipe = {
		{"mesecons_materials:silicon", "mesecons_materials:silicon"},
		{"mesecons_materials:silicon", "mesecons_materials:silicon"},
	}
})

minetest.register_abm({
	label = "Solar Panel On/Off",
	nodenames = {
		"mesecons_solarpanel:solar_panel_off",
		"mesecons_solarpanel:solar_panel_on"
	},
	interval = 1,
	chance = 1,
	catch_up = false,
	action = function(pos, node)
		local light = minetest.get_node_light(pos)
		if light >= 12 and node.name == "mesecons_solarpanel:solar_panel_off" then
			node.name = "mesecons_solarpanel:solar_panel_on"
			minetest.swap_node(pos, node)
			mesecon.receptor_on(pos, mesecon.rules.wallmounted_get(node))
		elseif light < 12 and node.name == "mesecons_solarpanel:solar_panel_on" then
			node.name = "mesecons_solarpanel:solar_panel_off"
			minetest.swap_node(pos, node)
			mesecon.receptor_off(pos, mesecon.rules.wallmounted_get(node))
		end
	end,
})
