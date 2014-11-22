minetest.register_node("mesecons_mese_fence:mese_fence", {
	description="Mese Fence",
	is_ground_content = true,
	drawtype = "fencelike",
	tiles = {"electricfence_tile.png"},
	inventory_image = "electricfence.png",
	wield_image = "electricfence.png",
	paramtype = "light",
	selection_box = {
	        type = "fixed",
	        fixed = {-1/7, -1/2, -1/7, 1/7, 1/2, 1/7},
	},
	groups = {snappy=3},
	drop = 'mesecons_mese_fence:mese_fence',
	--sounds = default.node_sound_wood_defaults(),
	walkable = true,
	mesecons = {conductor = {
		state = mesecon.state.off,
		rules = {
			{x = -1, y = 0, z = 0},
			{x = 1, y = 0, z = 0},
			{x = 0, y = -1, z = 0},
			{x = 0, y = 1, z = 0},
			{x = 0, y = 0, z = -1},
			{x = 0, y = 0, z = 1},
		},
		onstate = "mesecons_mese_fence:mese_fence_active",
	}}
})

minetest.register_node("mesecons_mese_fence:mese_fence_active", {
	is_ground_content = true,
	drawtype = "fencelike",
	tiles = {"electricfence_tile.png^electricfence_tile_active.png"},
	paramtype = "light",
	selection_box = {
	        type = "fixed",
	        fixed = {-1/7, -1/2, -1/7, 1/7, 1/2, 1/7},
	},
	groups = {snappy=3},
	drop = 'mesecons_mese_fence:mese_fence',
	--sounds = default.node_sound_wood_defaults(),
	walkable = true,
	mesecons = {conductor = {
		state = mesecon.state.on,
		rules = {
			{x = -1, y = 0, z = 0},
			{x = 1, y = 0, z = 0},
			{x = 0, y = -1, z = 0},
			{x = 0, y = 1, z = 0},
			{x = 0, y = 0, z = -1},
			{x = 0, y = 0, z = 1},
		},
		offstate = "mesecons_mese_fence:mese_fence",
	}}
})

minetest.register_craft({
	output = 'mesecons_mese_fence:mese_fence 4',
	recipe = {
		{"group:stick", "group:stick", "group:stick"},
		{"group:stick", "group:mesecon_conductor_craftable", "group:stick"},
		{"group:stick", "default:steel_ingot", "group:stick"},
	}
})

minetest.register_alias('mese_fence', 'mesecons_mese_fence:mese_fence')
print('[mesecons_mese_fence] loaded.')
