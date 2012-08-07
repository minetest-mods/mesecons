-- WALL LEVER
minetest.register_node("mesecons_walllever:wall_lever_off", {
	drawtype = "nodebox",
	tiles = {
		"jeija_wall_lever_tb_off.png",
		"jeija_wall_lever_tb_off.png",
		"jeija_wall_lever_sides_off.png",
		"jeija_wall_lever_sides_off.png",
		"jeija_wall_lever_back.png",
		"jeija_wall_lever_off.png"
		},
	inventory_image = "jeija_wall_lever_off.png",
	wield_image = "jeija_wall_lever_off.png",
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=2},
	description="Lever",
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -8/16, 11/32, 6/16, 8/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = {
			{ -6/16, -6/16, 7/16, 6/16, 6/16, 8/16 },
			{ -5/16, -3/16, 13/32, 5/16, 3/16, 7/16 },
			{ -4/16, -2/16, 12/32, 4/16, 2/16, 13/32 },
			{ -2/16, -1/16, 11/32, 2/16, 1/16, 12/32 },
			{ -1/16, -8/16, 13/32, 1/16, -3/16, 7/16 },
			{ -1/16, -8/16, 12/32, 1/16, -2/16, 13/32 },
			{ -1/16, -8/16, 11/32, 1/16, -1/16, 12/32 },
		},
	},
})

minetest.register_node("mesecons_walllever:wall_lever_on", {
	drawtype = "nodebox",
	tiles = {
		"jeija_wall_lever_tb_on.png",
		"jeija_wall_lever_tb_on.png",
		"jeija_wall_lever_sides_on.png",
		"jeija_wall_lever_sides_on.png",
		"jeija_wall_lever_back.png",
		"jeija_wall_lever_on.png"
		},
	inventory_image = "jeija_wall_lever_on.png",
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=2,not_in_creative_inventory=1},
	drop = '"mesecons_walllever:wall_lever_off" 1',
	description="Lever",
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -8/16, 11/32, 6/16, 8/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = {
			{ -6/16, -6/16, 7/16, 6/16, 6/16, 8/16 },
			{ -5/16, -3/16, 13/32, 5/16, 3/16, 7/16 },
			{ -4/16, -2/16, 12/32, 4/16, 2/16, 13/32 },
			{ -2/16, -1/16, 11/32, 2/16, 1/16, 12/32 },
			{ -1/16, 3/16, 13/32, 1/16, 8/16, 7/16 },
			{ -1/16, 2/16, 12/32, 1/16, 8/16, 13/32 },
			{ -1/16, 1/16, 11/32, 1/16, 8/16, 12/32 },
		},
	},
	after_dig_node = function(pos, oldnode)
		mesecon:receptor_off(pos, mesecon.button_get_rules(oldnode.param2))
	end
})

minetest.register_on_punchnode(function(pos, node, puncher)
	if node.name == "mesecons_walllever:wall_lever_off" then
		minetest.env:add_node(pos, {name="mesecons_walllever:wall_lever_on",param2=node.param2})
		mesecon:receptor_on(pos, mesecon.button_get_rules(node.param2))
	end
	if node.name == "mesecons_walllever:wall_lever_on" then
		minetest.env:add_node(pos, {name="mesecons_walllever:wall_lever_off",param2=node.param2})
		mesecon:receptor_off(pos, mesecon.button_get_rules(node.param2))
	end
end)

minetest.register_craft({
	output = '"mesecons_walllever:wall_lever_off" 2',
	recipe = {
	    {'"mesecons:mesecon_off"'},
		{'"default:stone"'},
		{'"default:stick"'},
	}
})
mesecon:add_receptor_node("mesecons_walllever:wall_lever", nil, mesecon.button_get_rules)
mesecon:add_receptor_node_off("mesecons_walllever:wall_lever_off", nil, mesecon.button_get_rules)
