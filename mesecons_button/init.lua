-- WALL BUTTON
-- A button that when pressed emits power for 1 second
-- and then turns off again

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
	groups = {dig_immediate=2, mesecon_needs_receiver = 1},
	description = "Button",
	on_punch = function (pos, node)
		mesecon:swap_node(pos, "mesecons_button:button_on")
		local rules=mesecon.button_get_rules(node)
      	 	mesecon:receptor_on(pos, rules)
		minetest.after(1, mesecon.button_turnoff, {pos=pos, param2=node.param2})
	end,
	mesecons = {receptor = {
		state = mesecon.state.off,
		rules = button_get_rules
	}}
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
	groups = {dig_immediate=2, not_in_creative_inventory=1, mesecon_needs_receiver = 1},
	drop = 'mesecons_button:button_off',
	description = "Button",
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = button_get_rules
	}}
})

mesecon.button_turnoff = function (params)
	if minetest.env:get_node(params.pos).name=="mesecons_button:button_on" then
		mesecon:swap_node(params.pos, "mesecons_button:button_off")
		local rules=mesecon.button_get_rules(params)
		mesecon:receptor_off(params.pos, rules)
	end
end

mesecon.button_get_rules = function(node)
	local rules = mesecon.rules.buttonlike
	if node.param2 == 2 then
		rules=mesecon:rotate_rules_left(rules)
	elseif node.param2 == 3 then
		rules=mesecon:rotate_rules_right(mesecon:rotate_rules_right(rules))
	elseif node.param2 == 0 then
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
