-- REMOVESTONE

minetest.register_node("mesecons_random:removestone", {
	tiles = {"jeija_removestone.png"},
	inventory_image = minetest.inventorycube("jeija_removestone_inv.png"),
	groups = {cracky=3},
	description="Removestone",
	sounds = default.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_on = function (pos, node)
			minetest.remove_node(pos)
			mesecon:update_autoconnect(pos)
		end
	}}
})

minetest.register_craft({
	output = 'mesecons_random:removestone 4',
	recipe = {
		{"", "default:cobble", ""},
		{"default:cobble", "group:mesecon_conductor_craftable", "default:cobble"},
		{"", "default:cobble", ""},
	}
})

-- CONDUCTING FENCE
minetest.register_node("mesecons_random:conductingfence", {
	description="A fence that conducts electricity",
	is_ground_content = true,
	drawtype = "fencelike",
	tiles = {"electricfence.png"},
	inventory_image = "electricfence.png",
	wield_image = "electricfence.png",
	paramtype = "light",
	selection_box = {
	        type = "fixed",
	        fixed = {-1/7, -1/2, -1/7, 1/7, 1/2, 1/7},
	},
	groups = {snappy=3},
	sounds = default.node_sound_wood_defaults(),
	walkable = true,
	mesecons = {conductor = {
		state = mesecon.state.off,
		rules = { --axes
			{x = -1, y = 0, z = 0},
			{x = 1, y = 0, z = 0},
			{x = 0, y = -1, z = 0},
			{x = 0, y = 1, z = 0},
			{x = 0, y = 0, z = -1},
			{x = 0, y = 0, z = 1},
		},
		onstate = "mesecons_random:conductingfence_active"
	}}
})

minetest.register_node("mesecons_random:conductingfence_active", {
	description="A fence that conducts electricity",
	is_ground_content = true,
	drawtype = "fencelike",
	tiles = {"electricfence_active.png"},
	paramtype = "light",
	selection_box = {
	        type = "fixed",
	        fixed = {-1/7, -1/2, -1/7, 1/7, 1/2, 1/7},
	},
	groups = {snappy=3},
	sounds = default.node_sound_wood_defaults(),
	walkable = true,
	mesecons = {conductor = {
		state = mesecon.state.on,
		rules = { --axes
			{x = -1, y = 0, z = 0},
			{x = 1, y = 0, z = 0},
			{x = 0, y = -1, z = 0},
			{x = 0, y = 1, z = 0},
			{x = 0, y = 0, z = -1},
			{x = 0, y = 0, z = 1},
		},
		offstate = "mesecons_random:conductingfence"
	}}
})

minetest.register_craft({
	output = 'mesecons_random:conductingfence 4',
	recipe = {
		{"default:stick", "default:stick", "default:stick"},
		{"default:stick", "group:mesecon_conductor_craftable", "default:stick"},
		{"default:stick", "default:steel_ingot", "default:default:stick"},
	}
})

-- GHOSTSTONE

minetest.register_node("mesecons_random:ghoststone", {
	description="ghoststone",
	tiles = {"jeija_ghoststone.png"},
	is_ground_content = true,
	inventory_image = minetest.inventorycube("jeija_ghoststone_inv.png"),
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	mesecons = {conductor = {
		state = mesecon.state.off,
		rules = { --axes
			{x = -1, y = 0, z = 0},
			{x = 1, y = 0, z = 0},
			{x = 0, y = -1, z = 0},
			{x = 0, y = 1, z = 0},
			{x = 0, y = 0, z = -1},
			{x = 0, y = 0, z = 1},
		},
		onstate = "mesecons_random:ghoststone_active"
	}}
})

minetest.register_node("mesecons_random:ghoststone_active", {
	drawtype = "airlike",
	pointable = false,
	walkable = false,
	diggable = false,
	sunlight_propagates = true,
	paramtype = "light",
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
		offstate = "mesecons_random:ghoststone"
	}},
	on_construct = function(pos)
		--remove shadow
		pos2 = {x = pos.x, y = pos.y + 1, z = pos.z}
		if ( minetest.get_node(pos2).name == "air" ) then
			minetest.dig_node(pos2)
		end
	end
})


minetest.register_craft({
	output = 'mesecons_random:ghoststone 4',
	recipe = {
		{"default:steel_ingot", "default:cobble", "default:steel_ingot"},
		{"default:cobble", "group:mesecon_conductor_craftable", "default:cobble"},
		{"default:steel_ingot", "default:cobble", "default:steel_ingot"},
	}
})
