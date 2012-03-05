-- MESELAMPS
minetest.register_node("mesecons_lamp:lamp_on", {
	drawtype = "torchlike",
	tile_images = {"jeija_meselamp_on_ceiling_on.png", "jeija_meselamp_on_floor_on.png", "jeija_meselamp_on.png"},
	inventory_image = "jeija_meselamp_on_floor_on.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	legacy_wallmounted = true,
	paramtype2 = "wallmounted",
	light_source = LIGHT_MAX,
	selection_box = {
		--type = "wallmounted",
		--type = "fixed",
		fixed = {-0.38, -0.5, -0.1, 0.38, -0.2, 0.1},
	},
	material = minetest.digprop_constanttime(0.1),
	drop='"mesecons_lamp:lamp_off" 1',
    	description="Meselamp",
})

minetest.register_node("mesecons_lamp:lamp_off", {
	drawtype = "torchlike",
	tile_images = {"jeija_meselamp_on_ceiling_off.png", "jeija_meselamp_on_floor_off.png", "jeija_meselamp_off.png"},
	inventory_image = "jeija_meselamp_on_floor_off.png",
	wield_image = "jeija_meselamp_on_ceiling_off.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	wall_mounted = false,
	selection_box = {
		--type = "fixed",
		fixed = {-0.38, -0.5, -0.1, 0.38, -0.2, 0.1},
	},
	material = minetest.digprop_constanttime(0.1),
    	description="Meselamp",
})

minetest.register_craft({
	output = '"mesecons_lamp:lamp_off" 1',
	recipe = {
		{'', '"default:glass"', ''},
		{'"mesecons:mesecon_off"', '"default:steel_ingot"', '"mesecons:mesecon_off"'},
		{'', '"default:glass"', ''},
	}
})
