minetest.register_node("mesecons_isolated:isolated_on", {
	description = "isolated mesecons",
	tiles = {"default_stone.png"},
	groups = {dig_immediate = 3, mesecon = 3, mesecon_conductor_craftable=1},
	drop = "mesecons_isolated:isolated_off",
})

minetest.register_node("mesecons_isolated:isolated_off", {
	description = "isolated mesecons",
	tiles = {"default_wood.png"},
	groups = {dig_immediate = 3, mesecon = 3, mesecon_conductor_craftable=1, not_in_creative_inventory = 1},
})

mesecon:add_rules("isolated", {
{x = 1,  y = 0,  z = 0},
{x =-1,  y = 0,  z = 0},})

mesecon:register_conductor("mesecons_isolated:isolated_on", "mesecons_isolated:isolated_off", mesecon:get_rules("isolated"))
