 -- The POWER_PLANT

minetest.register_node("mesecons_powerplant:power_plant", {
	drawtype = "plantlike",
	visual_scale = 1,
	tile_images = {"jeija_power_plant.png"},
	inventory_image = "jeija_power_plant.png",
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3, mesecon = 2},
	light_source = LIGHT_MAX-9,
    	description="Power Plant",
	after_place_node = function(pos)
		mesecon:receptor_on(pos)
	end,
	after_dig_node = function(pos)
		mesecon:receptor_off(pos)
	end,
	selection_box = {
		type = "fixed",
		fixed = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
	},
})

minetest.register_craft({
	output = '"mesecons_powerplant:power_plant" 1',
	recipe = {
		{'"mesecons:mesecon_off"'},
		{'"mesecons:mesecon_off"'},
		{'"default:junglegrass"'},
	}
})

mesecon:add_receptor_node("mesecons_powerplant:power_plant")
