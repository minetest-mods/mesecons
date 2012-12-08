-- WALL LEVER
local walllever_get_rules = function(node)
	local rules = {
		{x = 1,  y = 0, z = 0},
		{x = 1,  y = 1, z = 0},
		{x = 1,  y =-1, z = 0},
		{x = 1,  y =-1, z = 1},
		{x = 1,  y =-1, z =-1},
		{x = 2,  y = 0, z = 0}}
	if node.param2 == 2 then
		rules=mesecon:rotate_rules_left(rules)
	elseif node.param2 == 3 then
		rules=mesecon:rotate_rules_right(mesecon:rotate_rules_right(rules))
	elseif node.param2 == 0 then
		rules=mesecon:rotate_rules_right(rules)
	end
	return rules
end

minetest.register_node("mesecons_walllever:wall_lever_off", {
	drawtype = "nodebox",
	tiles = {
		"jeija_wall_lever_tb.png",
		"jeija_wall_lever_bottom.png",
		"jeija_wall_lever_sides.png",
		"jeija_wall_lever_sides.png",
		"jeija_wall_lever_back.png",
		"jeija_wall_lever_off.png",
	},
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
	node_box = {
		type = "fixed",
		fixed = {{ -6/16, -6/16, 6/16, 6/16,  6/16, 8/16 },	-- the base "slab"
			 { -5/16, -3/16, 5/16, 5/16,  3/16, 6/16 },	-- the lighted ring area
			 { -4/16, -2/16, 4/16, 4/16,  2/16, 5/16 },	-- the raised bit that the lever "sits" on
			 { -2/16, -1/16, 3/16, 2/16,  1/16, 4/16 },	-- the lever "hinge"
			 { -1/16, -8/16, 4/16, 1/16,  0,    6/16 }}	-- the lever itself.
	},
	groups = {dig_immediate=2, mesecon_needs_receiver = 1},
	description="Lever",
	on_punch = function (pos, node)
		mesecon:swap_node(pos, "mesecons_walllever:wall_lever_on")
		mesecon:receptor_on(pos, walllever_get_rules(node))
	end,
	mesecon = {receptor = {
		rules = walllever_get_rules,
		state = mesecon.state.off
	}}
})
minetest.register_node("mesecons_walllever:wall_lever_on", {
	drawtype = "nodebox",
	tiles = {
		"jeija_wall_lever_top.png",
		"jeija_wall_lever_tb.png",
		"jeija_wall_lever_sides.png",
		"jeija_wall_lever_sides.png",
		"jeija_wall_lever_back.png",
		"jeija_wall_lever_on.png",
	},
	inventory_image = "jeija_wall_lever_on.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	light_source = LIGHT_MAX-7,
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, 3/16, 8/16, 8/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = {{ -6/16, -6/16,  6/16, 6/16, 6/16,  8/16 },	-- the base "slab"
			 { -5/16, -3/16,  5/16, 5/16, 3/16,  6/16 },	-- the lighted ring area
			 { -4/16, -2/16,  4/16, 4/16, 2/16,  5/16 },	-- the raised bit that the lever "sits" on
			 { -2/16, -1/16,  3/16, 2/16, 1/16,  4/16 },	-- the lever "hinge"
			 { -1/16,  0,     4/16, 1/16, 8/16,  6/16 }}	-- the lever itself.
	},
	groups = {dig_immediate=2,not_in_creative_inventory=1, mesecon = 3, mesecon_needs_receiver = 1},
	drop = '"mesecons_walllever:wall_lever_off" 1',
	description="Lever",
	on_punch = function (pos, node)
		mesecon:swap_node(pos, "mesecons_walllever:wall_lever_off")
		mesecon:receptor_off(pos, walllever_get_rules(node))
	end,
	mesecon = {receptor = {
		rules = walllever_get_rules,
		state = mesecon.state.on
	}}
})

minetest.register_craft({
	output = '"mesecons_walllever:wall_lever_off" 2',
	recipe = {
	    {'"group:mesecon_conductor_craftable"'},
		{'"default:stone"'},
		{'"default:stick"'},
	}
})
