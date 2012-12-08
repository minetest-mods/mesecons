--MESECON TORCHES

local torch_get_rules = function(node)
	local rules = {
		{x=1,  y=0,  z=0},
		{x=0,  y=0,  z=1},
		{x=0,  y=0,  z=-1},
		{x=0,  y=1,  z=0},
		{x=0,  y=-1,  z=0}}
	if node.param2 == 5 then
		rules=mesecon:rotate_rules_right(rules)
	elseif node.param2 == 2 then
		rules=mesecon:rotate_rules_right(mesecon:rotate_rules_right(rules)) --180 degrees
	elseif node.param2 == 4 then
		rules=mesecon:rotate_rules_left(rules)
	elseif node.param2 == 1 then
		rules=mesecon:rotate_rules_down(rules)
	elseif node.param2 == 0 then
		rules=mesecon:rotate_rules_up(rules)
	end
	return rules
end

local torch_get_input_rules = function(node)
        local rules = {x=0, y=0, z=0}

	if node.param2 == 4 then
		rules.z = -2
	elseif node.param2 == 2 then
		rules.x = -2
	elseif node.param2 == 5 then
		rules.z = 2
	elseif node.param2 == 3 then
		 rules.x = 2
	elseif node.param2 == 1 then
		rules.y = 2
	elseif node.param2 == 0 then
		rules.y = -2
        end
	return rules
end

minetest.register_craft({
	output = '"mesecons_torch:mesecon_torch_on" 4',
	recipe = {
		{"group:mesecon_conductor_craftable"},
	{"default:stick"},
	}
})

minetest.register_node("mesecons_torch:mesecon_torch_off", {
	drawtype = "torchlike",
	tiles = {"jeija_torches_off.png", "jeija_torches_off_ceiling.png", "jeija_torches_off_side.png"},
	inventory_image = "jeija_torches_off.png",
	paramtype = "light",
	walkable = false,
	paramtype2 = "wallmounted",
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
		wall_side = {-0.5, -0.1, -0.1, -0.5+0.6, 0.1, 0.1},
	},
	legacy_wallmounted = true,
	groups = {dig_immediate=3,not_in_creative_inventory=1},
	drop = '"mesecons_torch:mesecon_torch_on" 1',
	description="Mesecon Torch",
	mesecons = {receptor = {
		state = mesecon.state.off,
		rules = torch_get_rules
	}}
})

minetest.register_node("mesecons_torch:mesecon_torch_on", {
	drawtype = "torchlike",
	tiles = {"jeija_torches_on.png", "jeija_torches_on_ceiling.png", "jeija_torches_on_side.png"},
	inventory_image = "jeija_torches_on.png",
	wield_image = "jeija_torches_on.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	paramtype2 = "wallmounted",
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
		wall_side = {-0.5, -0.1, -0.1, -0.5+0.6, 0.1, 0.1},
	},
	legacy_wallmounted = true,
	groups = {dig_immediate=3},
	light_source = LIGHT_MAX-5,
	description="Mesecon Torch",
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = torch_get_rules
	}}
})

minetest.register_abm({
    nodenames = {"mesecons_torch:mesecon_torch_off","mesecons_torch:mesecon_torch_on"},
    interval = 1,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
	local node = minetest.env:get_node(pos)
	local pa = torch_get_input_rules(node)

        local postc = {x=pos.x-pa.x, y=pos.y-pa.y, z=pos.z-pa.z}
        if mesecon:is_power_on(postc) then
            if node.name ~= "mesecons_torch:mesecon_torch_off" then
                minetest.env:add_node(pos, {name="mesecons_torch:mesecon_torch_off",param2=node.param2})
                mesecon:receptor_off(pos, torch_get_rules(node))
            end
        else
            if node.name ~= "mesecons_torch:mesecon_torch_on" then
                minetest.env:add_node(pos, {name="mesecons_torch:mesecon_torch_on",param2=node.param2})
                mesecon:receptor_on(pos, torch_get_rules(node))
            end
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
