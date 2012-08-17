minetest.register_node("mesecons_insulated:insulated_on", {
	drawtype = "nodebox",
	description = "insulated mesecons",
	tiles = {
		"jeija_insulated_wire_sides.png",
		"jeija_insulated_wire_sides.png",
		"jeija_insulated_wire_ends_on.png",
		"jeija_insulated_wire_ends_on.png",
		"jeija_insulated_wire_sides.png",
		"jeija_insulated_wire_sides.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,
	stack_max = 99,
	selection_box = {
		type = "fixed",
		fixed = { -16/32-0.001, -18/32, -7/32, 16/32+0.001, -12/32, 7/32 }
	},
	node_box = {
		type = "fixed",
		fixed = { -16/32-0.001, -17/32, -3/32, 16/32+0.001, -13/32, 3/32 }
	},
	groups = {dig_immediate = 3, mesecon = 3, mesecon_conductor_craftable=1, not_in_creative_inventory = 1},
	drop = "mesecons_insulated:insulated_off",

})

minetest.register_node("mesecons_insulated:insulated_off", {
	drawtype = "nodebox",
	description = "insulated mesecons",
	tiles = {
		"jeija_insulated_wire_sides.png",
		"jeija_insulated_wire_sides.png",
		"jeija_insulated_wire_ends_off.png",
		"jeija_insulated_wire_ends_off.png",
		"jeija_insulated_wire_sides.png",
		"jeija_insulated_wire_sides.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,
	stack_max = 99,
	selection_box = {
		type = "fixed",
		fixed = { -16/32-0.001, -18/32, -7/32, 16/32+0.001, -12/32, 7/32 }
	},
	node_box = {
		type = "fixed",
		fixed = { -16/32-0.001, -17/32, -3/32, 16/32+0.001, -13/32, 3/32 }
	},
	groups = {dig_immediate = 3, mesecon = 3, mesecon_conductor_craftable=1},
})

mesecon:add_rules("insulated_all", { --all possible rules
{x = 1,  y = 0,  z = 0},
{x =-1,  y = 0,  z = 0},
{x = 0,  y = 0,  z = 1},
{x = 0,  y = 0,  z =-1},})

mesecon:add_rules("insulated", {
{x = 1,  y = 0,  z = 0},
{x =-1,  y = 0,  z = 0},})

function insulated_wire_get_rules(param2)
	if param2 == 1 or param2 == 3 then
		return mesecon:rotate_rules_right(mesecon:get_rules("insulated"))
	end
	return mesecon:get_rules("insulated")
end

mesecon:register_conductor("mesecons_insulated:insulated_on", "mesecons_insulated:insulated_off", mesecon:get_rules("insulated_all"), insulated_wire_get_rules)
