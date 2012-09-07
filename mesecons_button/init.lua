-- WALL BUTTON
minetest.register_node("mesecons_button:button_off", {
    drawtype = "nodebox",
    tiles = {
	"jeija_wall_button_sides.png",	
	"jeija_wall_button_sides.png",
	"jeija_wall_button_sides.png",
	"jeija_wall_button_sides.png",
	"jeija_wall_button_sides.png",
	"jeija_wall_button_off.png"
	},
    paramtype = "light",
    paramtype2 = "facedir",
    legacy_wallmounted = true,
    walkable = false,
    sunlight_propagates = true,
    selection_box = {
        type = "fixed",
	fixed = { -6/16, -6/16, 5/16, 6/16, 6/16, 8/16 }
    },
    node_box = {
        type = "fixed",	
	fixed = {
		{ -6/16, -6/16, 6/16, 6/16, 6/16, 8/16 },	-- the thin plate behind the button
		{ -4/16, -2/16, 4/16, 4/16, 2/16, 6/16 }	-- the button itself
	}
    },
    groups = {dig_immediate=2, mesecon = 3, mesecon_needs_receiver = 1},
    description = "Button",
})
minetest.register_node("mesecons_button:button_on", {
	drawtype = "nodebox",
	tiles = {
		"jeija_wall_button_sides.png",
		"jeija_wall_button_sides.png",
		"jeija_wall_button_sides.png",
		"jeija_wall_button_sides.png",
		"jeija_wall_button_sides.png",
		"jeija_wall_button_on.png"
		},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_wallmounted = true,
	walkable = false,
	light_source = LIGHT_MAX-7,
	sunlight_propagates = true,
    selection_box = {
        type = "fixed",
	fixed = { -6/16, -6/16, 5/16, 6/16, 6/16, 8/16 }
    },
    node_box = {
        type = "fixed",
	fixed = {
		{ -6/16, -6/16,  6/16, 6/16, 6/16, 8/16 },
		{ -4/16, -2/16, 11/32, 4/16, 2/16, 6/16 }
	}
    },
	groups = {dig_immediate=2, not_in_creative_inventory=1, mesecon = 3, mesecon_needs_receiver = 1},
	drop = 'mesecons_button:button_off',
	description = "Button",
})

minetest.register_on_punchnode(function(pos, node, puncher)
	if node.name == "mesecons_button:button_off" then
		minetest.env:add_node(pos, {name="mesecons_button:button_on",param2=node.param2})
		local rules=mesecon.button_get_rules(node.param2)
        	mesecon:receptor_on(pos, rules)
		minetest.after(1, mesecon.button_turnoff, {pos=pos, param2=node.param2})
	end
end)

mesecon.button_turnoff = function (params)
	if minetest.env:get_node(params.pos).name=="mesecons_button:button_on" then
		minetest.env:add_node(params.pos, {name="mesecons_button:button_off", param2=params.param2})
		local rules=mesecon.button_get_rules(params.param2)
		mesecon:receptor_off(params.pos, rules)
	end
end

mesecon.button_get_rules = function(param2)
	local rules=mesecon:get_rules("button")
	if param2 == 2 then
		rules=mesecon:rotate_rules_left(rules)
	end
	if param2 == 3 then
		rules=mesecon:rotate_rules_right(mesecon:rotate_rules_right(rules))
	end
	if param2 == 0 then
		rules=mesecon:rotate_rules_right(rules)
	end
	return rules
end

minetest.register_craft({
	output = '"mesecons_button:button_off" 2',
	recipe = {
		{'"group:mesecon_conductor_craftable"','"default:stone"'},
	}
})

mesecon:add_rules("button", {
{x = 1,  y = 0, z = 0},
{x = 1,  y = 1, z = 0},
{x = 1,  y =-1, z = 0},
{x = 1,  y =-1, z = 1},
{x = 1,  y =-1, z =-1},
{x = 2,  y = 0, z = 0},})

mesecon:add_receptor_node_off("mesecons_button:button_off", nil, mesecon.button_get_rules)
mesecon:add_receptor_node("mesecons_button:button_on", nil, mesecon.button_get_rules)

