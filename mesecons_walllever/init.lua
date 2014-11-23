-- WALL LEVER
-- Basically a switch that can be attached to a wall
-- Powers the block 2 nodes behind (using a receiver)
mesecon.register_node("mesecons_walllever:wall_lever", {
	description="Lever",
	drawtype = "nodebox",
	inventory_image = "jeija_wall_lever_off.png",
	wield_image = "jeija_wall_lever_off.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, 3/16, 8/16, 8/16, 8/16 },
	},
	sounds = default.node_sound_wood_defaults(),
	on_punch = function (pos, node)
		if(mesecon.flipstate(pos, node) == "on") then
			mesecon.receptor_on(pos, mesecon.rules.buttonlike_get(node))
		else
			mesecon.receptor_off(pos, mesecon.rules.buttonlike_get(node))
		end
		minetest.sound_play("mesecons_lever", {pos=pos})
	end
},{
	tiles = { "jeija_wall_lever_tb.png", "jeija_wall_lever_bottom.png",
		"jeija_wall_lever_sides.png", "jeija_wall_lever_sides.png",
		"jeija_wall_lever_back.png", "jeija_wall_lever_off.png",
	},
	node_box = {
		type = "fixed",
		fixed = {{ -6/16, -6/16, 6/16, 6/16,  6/16, 8/16 },	-- the base "slab"
			 { -5/16, -3/16, 5/16, 5/16,  3/16, 6/16 },	-- the lighted ring area
			 { -4/16, -2/16, 4/16, 4/16,  2/16, 5/16 },	-- the raised bit
			 { -2/16, -1/16, 3/16, 2/16,  1/16, 4/16 },	-- the lever "hinge"
			 { -1/16, -8/16, 4/16, 1/16,  0,    6/16 }}	-- the lever itself.
	},
	mesecons = {receptor = {
		rules = mesecon.rules.buttonlike_get,
		state = mesecon.state.off
	}},
	groups = {dig_immediate = 2, mesecon_needs_receiver = 1}
},{
	tiles = {
		"jeija_wall_lever_top.png",
		"jeija_wall_lever_tb.png",
		"jeija_wall_lever_sides.png",
		"jeija_wall_lever_sides.png",
		"jeija_wall_lever_back.png",
		"jeija_wall_lever_on.png",
	},
	node_box = {
		type = "fixed",
		fixed = {{ -6/16, -6/16,  6/16, 6/16, 6/16,  8/16 },	-- the base "slab"
			 { -5/16, -3/16,  5/16, 5/16, 3/16,  6/16 },	-- the lighted ring area
			 { -4/16, -2/16,  4/16, 4/16, 2/16,  5/16 },	-- the raised bit
			 { -2/16, -1/16,  3/16, 2/16, 1/16,  4/16 },	-- the lever "hinge"
			 { -1/16,  0,     4/16, 1/16, 8/16,  6/16 }}	-- the lever itself.
	},
	mesecons = {receptor = {
		rules = mesecon.rules.buttonlike_get,
		state = mesecon.state.on
	}},
	groups = {dig_immediate = 2, mesecon_needs_receiver = 1, not_in_creative_inventory = 1}
})

minetest.register_craft({
	output = "mesecons_walllever:wall_lever_off 2",
	recipe = {
	    {"group:mesecon_conductor_craftable"},
		{"default:stone"},
		{"default:stick"},
	}
})
