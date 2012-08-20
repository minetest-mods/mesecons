--MESECON TORCHES

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
    groups = {dig_immediate=3,not_in_creative_inventory=1, mesecon = 2},
    drop = '"mesecons_torch:mesecon_torch_on" 1',
    description="Mesecon Torch",
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
	groups = {dig_immediate=3, mesecon = 2},
	light_source = LIGHT_MAX-5,
	description="Mesecon Torch",
})

minetest.register_abm({
    nodenames = {"mesecons_torch:mesecon_torch_off","mesecons_torch:mesecon_torch_on"},
    interval = 1,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
	local rules=mesecon.torch_get_rules(minetest.env:get_node(pos).param2)
	local pa = mesecon.torch_get_input_rules(node.param2)

        local postc = {x=pos.x-pa.x, y=pos.y-pa.y, z=pos.z-pa.z}
        if mesecon:is_power_on(postc) then
            if node.name ~= "mesecons_torch:mesecon_torch_off" then
                minetest.env:add_node(pos, {name="mesecons_torch:mesecon_torch_off",param2=node.param2})
                mesecon:receptor_off(pos, rules_string)
            end
        else
            if node.name ~= "mesecons_torch:mesecon_torch_on" then
                minetest.env:add_node(pos, {name="mesecons_torch:mesecon_torch_on",param2=node.param2})
                mesecon:receptor_on(pos, rules_string)
            end
        end
    end
})

mesecon.torch_get_rules = function(param2)
	local rules=mesecon:get_rules("mesecontorch")
	if param2 == 5 then
		rules=mesecon:rotate_rules_right(rules)
	elseif param2 == 2 then
		rules=mesecon:rotate_rules_right(mesecon:rotate_rules_right(rules)) --180 degrees
	elseif param2 == 4 then
		rules=mesecon:rotate_rules_left(rules)
	elseif param2 == 1 then
		rules=mesecon:rotate_rules_down(rules)
	elseif param2 == 0 then
		rules=mesecon:rotate_rules_up(rules)
	end
	return rules
end

mesecon.torch_get_input_rules = function(param2)
        local rules = {x=0, y=0, z=0}

	if param2 == 4 then
		rules.z = -2
	elseif param2 == 2 then
		rules.x = -2
	elseif param2 == 5 then
		rules.z = 2
	elseif param2 == 3 then
		 rules.x = 2
	elseif param2 == 1 then
		rules.y = 2
	elseif param2 == 0 then
		rules.y = -2
        end
	return rules
end

mesecon:add_rules("mesecontorch", 
{{x=1,  y=0,  z=0},
{x=0,  y=0,  z=1},
{x=0,  y=0,  z=-1},
{x=0,  y=1,  z=0},
{x=0,  y=-1,  z=0}})

mesecon:add_receptor_node("mesecons_torch:mesecon_torch_on", nil, mesecon.torch_get_rules)
mesecon:add_receptor_node_off("mesecons_torch:mesecon_torch_off", nil, mesecon.torch_get_rules)
mesecon:register_effector("mesecons_torch:mesecon_torch_on","mesecons_torch:mesecon_torch_off", nil, mesecon.torch_get_input_rules)

-- Param2 Table (Block Attached To)
-- 5 = z-1
-- 3 = x-1
-- 4 = z+1
-- 2 = x+1
-- 0 = y+1
-- 1 = y-1
