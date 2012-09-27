-- REMOVESTONE

minetest.register_node("mesecons_random:removestone", {
	tiles = {"jeija_removestone.png"},
	inventory_image = minetest.inventorycube("jeija_removestone_inv.png"),
	groups = {cracky=3, mesecon=2},
	description="Removestone",
})

mesecon:register_effector(nil, "mesecons_random:removestone")

minetest.register_craft({
	output = 'mesecons_random:removestone 4',
	recipe = {
		{"", "default:cobble", ""},
		{"default:cobble", "group:mesecon_conductor_craftable", "default:cobble"},
		{"", "default:cobble", ""},
	}
})

mesecon:register_on_signal_on(function(pos, node)
	if node.name == "mesecons_random:removestone" then
		minetest.env:remove_node(pos)
	end
end)

-- GHOSTSTONE

minetest.register_node("mesecons_random:ghoststone", {
	description="ghoststone",
	tiles = {"jeija_ghoststone.png"},
	is_ground_content = true,
	inventory_image = minetest.inventorycube("jeija_ghoststone_inv.png"),
	groups = {cracky=3, mesecon=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mesecons_random:ghoststone_active", {
	drawtype = "airlike",
	pointable = false,
	walkable = false,
	diggable = false,
	sunlight_propagates = true,
	groups = {mesecon=2},
})

mesecon:register_effector("mesecons_random:ghoststone_active", "mesecons_random:ghoststone")

minetest.register_craft({
	output = 'mesecons_random:ghoststone 4',
	recipe = {
		{"default:steel_ingot", "default:cobble", "default:steel_ingot"},
		{"default:cobble", "group:mesecon_conductor_craftable", "default:cobble"},
		{"default:steel_ingot", "default:cobble", "default:steel_ingot"},
	}
})

mesecon:register_on_signal_on(function(pos, node)
	if node.name == "mesecons_random:ghoststone" then
		minetest.env:add_node(pos, {name="mesecons_random:ghoststone_active"})
		nodeupdate(pos)
	end
end)

mesecon:register_on_signal_off(function(pos, node)
	if node.name == "mesecons_random:ghoststone_active" then
		minetest.env:add_node(pos, {name="mesecons_random:ghoststone"})
		nodeupdate(pos)
	end
end)