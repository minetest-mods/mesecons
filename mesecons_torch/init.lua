--MESECON TORCHES

local rotate_torch_rules = function (rules, param2)
	if param2 == 5 then
		return mesecon.rotate_rules_right(rules)
	elseif param2 == 2 then
		return mesecon.rotate_rules_right(mesecon.rotate_rules_right(rules)) --180 degrees
	elseif param2 == 4 then
		return mesecon.rotate_rules_left(rules)
	elseif param2 == 1 then
		return mesecon.rotate_rules_down(rules)
	elseif param2 == 0 then
		return mesecon.rotate_rules_up(rules)
	else
		return rules
	end
end

local torch_get_output_rules = function(node)
	local rules = {
		{x = 1,  y = 0, z = 0},
		{x = 0,  y = 0, z = 1},
		{x = 0,  y = 0, z =-1},
		{x = 0,  y = 1, z = 0},
		{x = 0,  y =-1, z = 0}}

	return rotate_torch_rules(rules, node.param2)
end

local torch_input_rules_unrotated_horizontal = {vector.new(-2, 0, 0), vector.new(-1, 1, 0)}
local torch_input_rules_unrotated_vertical   = {vector.new(-2, 0, 0)}

local torch_get_input_rules = function(node)
	local rules = (node.param2 == 0 or node.param2 == 1)
		and torch_input_rules_unrotated_vertical
		or  torch_input_rules_unrotated_horizontal

	return rotate_torch_rules(rules, node.param2)
end

minetest.register_craft({
	output = "mesecons_torch:mesecon_torch_on 4",
	recipe = {
	{"group:mesecon_conductor_craftable"},
	{"default:stick"},}
})

local torch_selectionbox =
{
	type = "wallmounted",
	wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
	wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
	wall_side = {-0.5, -0.1, -0.1, -0.5+0.6, 0.1, 0.1},
}

minetest.register_node("mesecons_torch:mesecon_torch_off", {
	drawtype = "torchlike",
	tiles = {"jeija_torches_off.png", "jeija_torches_off_ceiling.png", "jeija_torches_off_side.png"},
	inventory_image = "jeija_torches_off.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	paramtype2 = "wallmounted",
	selection_box = torch_selectionbox,
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	drop = "mesecons_torch:mesecon_torch_on",
	sounds = default.node_sound_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.off,
		rules = torch_get_output_rules
	}},
	on_blast = mesecon.on_blastnode,
})

minetest.register_node("mesecons_torch:mesecon_torch_on", {
	drawtype = "torchlike",
	tiles = {"jeija_torches_on.png", "jeija_torches_on_ceiling.png", "jeija_torches_on_side.png"},
	inventory_image = "jeija_torches_on.png",
	wield_image = "jeija_torches_on.png",
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	paramtype2 = "wallmounted",
	selection_box = torch_selectionbox,
	groups = {dig_immediate=3},
	light_source = minetest.LIGHT_MAX-5,
	description="Mesecon Torch",
	sounds = default.node_sound_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = torch_get_output_rules
	}},
	on_blast = mesecon.on_blastnode,
})

minetest.register_abm({
	nodenames = {"mesecons_torch:mesecon_torch_off","mesecons_torch:mesecon_torch_on"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		local is_powered = false
		for _, rule in ipairs(torch_get_input_rules(node)) do
			local src = vector.add(pos, rule)
			if mesecon.is_power_on(src) then
				is_powered = true
			end
		end

		if is_powered then
			if node.name == "mesecons_torch:mesecon_torch_on" then
				minetest.swap_node(pos, {name = "mesecons_torch:mesecon_torch_off", param2 = node.param2})
				mesecon.receptor_off(pos, torch_get_output_rules(node))
			end
		elseif node.name == "mesecons_torch:mesecon_torch_off" then
			minetest.swap_node(pos, {name = "mesecons_torch:mesecon_torch_on", param2 = node.param2})
			mesecon.receptor_on(pos, torch_get_output_rules(node))
		end
	end
})

-- Param2 Table (Block Attached To)
-- 5 = z-1
-- 3 = x-1
-- 4 = z+1
-- 2 = x+1
-- 0 = y+1
-- 1 = y-1
