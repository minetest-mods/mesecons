-- Solar Panel
minetest.register_node("mesecons_solarpanel:solar_panel", {
	drawtype = "nodebox",
	tile_images = {
		"jeija_solar_panel.png",
		"jeija_solar_panel_sides.png"
		},
	inventory_image = "jeija_solar_panel.png",
	wield_image = "jeija_solar_panel.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	is_ground_content = true,
	node_box = {
		type = "wallmounted",
		wall_bottom = { -7/16, -8/16, -7/16,  7/16, -7/16, 7/16 },
		wall_top    = { -7/16,  7/16, -7/16,  7/16,  8/16, 7/16 },
		wall_side   = { -8/16, -7/16, -7/16, -7/16,  7/16, 7/16 },
	},
	selection_box = {
		type = "wallmounted",
		wall_bottom = { -7/16, -8/16, -7/16,  7/16, -7/16, 7/16 },
		wall_top    = { -7/16,  7/16, -7/16,  7/16,  8/16, 7/16 },
		wall_side   = { -8/16, -7/16, -7/16, -7/16,  7/16, 7/16 },
	},
	furnace_burntime = 5,
	groups = {dig_immediate=3, mesecon = 2},
    	description="Solar Panel",
	after_dig_node = function(pos, node, digger)
		mesecon:receptor_off(pos)
	end,
})

minetest.register_craft({
	output = '"mesecons_solarpanel:solar_panel" 1',
	recipe = {
		{'"mesecons_materials:silicon"', '"mesecons_materials:silicon"'},
		{'"mesecons_materials:silicon"', '"mesecons_materials:silicon"'},
	}
})

minetest.register_abm(
	{nodenames = {"mesecons_solarpanel:solar_panel"},
	interval = 0.1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local light = minetest.env:get_node_light(pos, nil)
		if light == nil then light = 0 end
		if light >= 12 then
			mesecon:receptor_on(pos)
		else
			mesecon:receptor_off(pos)
		end
	end,
})
