local tjunction_nodebox = {
	type = "fixed",
	fixed = {{ -16/32-0.001, -17/32, -3/32, 16/32+0.001, -13/32, 3/32 },
		 { -3/32, -17/32, -16/32+0.001, 3/32, -13/32, -3/32},}
}

local tjunction_selectionbox = {
		type = "fixed",
		fixed = { -16/32-0.001, -18/32, -16/32, 16/32+0.001, -12/32, 7/32 },
}

minetest.register_node("mesecons_extrawires:tjunction_on", {
	drawtype = "nodebox",
	tiles = {
		"jeija_insulated_wire_sides.png",
		"jeija_insulated_wire_sides.png",
		"jeija_insulated_wire_ends_on.png",
		"jeija_insulated_wire_ends_on.png",
		"jeija_insulated_wire_sides.png",
		"jeija_insulated_wire_ends_on.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,
	sunlight_propagates = true,
	selection_box = tjunction_selectionbox,
	node_box = tjunction_nodebox,
	groups = {dig_immediate = 3, mesecon = 3, mesecon_conductor_craftable=1, not_in_creative_inventory = 1},
	drop = "mesecons_insulated:insulated_off",

})

minetest.register_node("mesecons_extrawires:tjunction_off", {
	drawtype = "nodebox",
	description = "T-junction",
	tiles = {
		"jeija_insulated_wire_sides.png",
		"jeija_insulated_wire_sides.png",
		"jeija_insulated_wire_ends_off.png",
		"jeija_insulated_wire_ends_off.png",
		"jeija_insulated_wire_sides.png",
		"jeija_insulated_wire_ends_off.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,
	sunlight_propagates = true,
	selection_box = tjunction_selectionbox,
	node_box = tjunction_nodebox,
	groups = {dig_immediate = 3, mesecon = 3, mesecon_conductor_craftable=1},
})

minetest.register_craft({
	output = '"mesecons_extrawires:tjunction_off" 3',
	recipe = {
		{"", "", ""},
		{"mesecons_insulated:insulated_off", "mesecons_insulated:insulated_off", "mesecons_insulated:insulated_off"},
		{"", "mesecons_insulated:insulated_off", ""},
	}
})

mesecon:add_rules("tjunction_all", { --all possible rules
{x = 1,  y = 0,  z = 0},
{x =-1,  y = 0,  z = 0},
{x = 0,  y = 0,  z = 1},
{x = 0,  y = 0,  z =-1},})

mesecon:add_rules("tjunction", {
{x = 1,  y = 0,  z =  0},
{x =-1,  y = 0,  z =  0},
{x = 0,  y = 0,  z = -1},})

function tjunction_get_rules(param2)
	local rules = mesecon:get_rules("tjunction")
	if param2 == 1 then
		rules = mesecon:rotate_rules_left(mesecon:get_rules("tjunction"))
	elseif param2 == 2 then
		rules = mesecon:rotate_rules_right(mesecon:rotate_rules_right(mesecon:get_rules("tjunction")))
	elseif param2 == 3 then
		rules = mesecon:rotate_rules_right(mesecon:get_rules("tjunction"))
	end
	return rules
end

mesecon:register_conductor("mesecons_extrawires:tjunction_on", "mesecons_extrawires:tjunction_off", mesecon:get_rules("tjunction_all"), tjunction_get_rules)
