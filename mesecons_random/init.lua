local S = minetest.get_translator(minetest.get_current_modname())

-- REMOVESTONE

minetest.register_node("mesecons_random:removestone", {
	tiles = {"jeija_removestone.png"},
	is_ground_content = false,
	inventory_image = minetest.inventorycube("jeija_removestone_inv.png"),
	groups = {cracky=3},
	description = S("Removestone"),
	sounds = mesecon.node_sound.stone,
	mesecons = {effector = {
		action_on = function (pos, node)
			minetest.remove_node(pos)
			mesecon.on_dignode(pos, node)
			minetest.check_for_falling(vector.add(pos, vector.new(0, 1, 0)))
		end
	}},
	on_blast = mesecon.on_blastnode,
})

minetest.register_craft({
	output = 'mesecons_random:removestone 4',
	recipe = {
		{"", "mesecons_gamecompat:cobble", ""},
		{"mesecons_gamecompat:cobble", "group:mesecon_conductor_craftable", "mesecons_gamecompat:cobble"},
		{"", "mesecons_gamecompat:cobble", ""},
	}
})

-- GHOSTSTONE

minetest.register_node("mesecons_random:ghoststone", {
	description = S("Ghoststone"),
	tiles = {"jeija_ghoststone.png"},
	is_ground_content = false,
	inventory_image = minetest.inventorycube("jeija_ghoststone_inv.png"),
	groups = {cracky=3},
	sounds = mesecon.node_sound.stone,
	mesecons = {conductor = {
		state = mesecon.state.off,
		rules = mesecon.rules.alldirs,
		onstate = "mesecons_random:ghoststone_active"
	}},
	on_blast = mesecon.on_blastnode,
})

minetest.register_node("mesecons_random:ghoststone_active", {
	drawtype = "airlike",
	pointable = false,
	walkable = false,
	diggable = false,
	is_ground_content = false,
	sunlight_propagates = true,
	paramtype = "light",
	drop = "mesecons_random:ghoststone",
	mesecons = {conductor = {
		state = mesecon.state.on,
		rules = mesecon.rules.alldirs,
		offstate = "mesecons_random:ghoststone"
	}},
	on_construct = function(pos)
		-- remove shadow
		local shadowpos = vector.add(pos, vector.new(0, 1, 0))
		if (minetest.get_node(shadowpos).name == "air") then
			minetest.dig_node(shadowpos)
		end
	end,
	on_blast = mesecon.on_blastnode,
})


minetest.register_craft({
	output = 'mesecons_random:ghoststone 4',
	recipe = {
		{"mesecons_gamecompat:steel_ingot", "mesecons_gamecompat:cobble", "mesecons_gamecompat:steel_ingot"},
		{"mesecons_gamecompat:cobble", "group:mesecon_conductor_craftable", "mesecons_gamecompat:cobble"},
		{"mesecons_gamecompat:steel_ingot", "mesecons_gamecompat:cobble", "mesecons_gamecompat:steel_ingot"},
	}
})
