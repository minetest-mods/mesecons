-- WALL LEVER
minetest.register_node("mesecons_walllever:wall_lever_off", {
	drawtype = "nodebox",
	tile_images = {
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
	groups = {dig_immediate=2, mesecon = 3, mesecon_needs_receiver = 1},
	description="Lever",
})
minetest.register_node("mesecons_walllever:wall_lever_on", {
	drawtype = "nodebox",
	tile_images = {
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
})

minetest.register_on_punchnode(function(pos, node, puncher)
	if node.name == "mesecons_walllever:wall_lever_off" then
		minetest.env:add_node(pos, {name="mesecons_walllever:wall_lever_on",param2=node.param2})
		mesecon:receptor_on(pos, mesecon.walllever_get_rules(node.param2))
	end
	if node.name == "mesecons_walllever:wall_lever_on" then
		minetest.env:add_node(pos, {name="mesecons_walllever:wall_lever_off",param2=node.param2})
		mesecon:receptor_off(pos, mesecon.walllever_get_rules(node.param2))
	end
end)

minetest.register_craft({
	output = '"mesecons_walllever:wall_lever_off" 2',
	recipe = {
	    {'"group:mesecon_conductor_craftable"'},
		{'"default:stone"'},
		{'"default:stick"'},
	}
})

mesecon:add_rules("walllever", {
{x = 1,  y = 0, z = 0},
{x = 1,  y = 1, z = 0},
{x = 1,  y =-1, z = 0},
{x = 1,  y =-1, z = 1},
{x = 1,  y =-1, z =-1},
{x = 2,  y = 0, z = 0},})


mesecon.walllever_get_rules = function(param2)
	local rules=mesecon:get_rules("walllever")
	if param2 == 2 then
		rules=mesecon:rotate_rules_left(rules)
	end
	if param2 == 3 then
		rules=mesecon:rotate_rules_right(mesecon:rotate_rules_right(rules))
	end
	if param2 == 0 then
		rules=mesecon:rotate_rules_right(rules)
	end
	return rules
end

mesecon:add_receptor_node("mesecons_walllever:wall_lever_on", nil, mesecon.walllever_get_rules)
mesecon:add_receptor_node_off("mesecons_walllever:wall_lever_off", nil, mesecon.walllever_get_rules)
