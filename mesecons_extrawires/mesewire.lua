local mesewire_rules =
{
	{x = 1, y = 0, z = 0},
	{x =-1, y = 0, z = 0},
	{x = 0, y = 1, z = 0},
	{x = 0, y =-1, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z =-1},
}

-- The sweet taste of a default override
minetest.override_item("default:mese", {
	mesecons = {conductor = {
		state = mesecon.state.off,
		onstate = "mesecons_extrawires:mese_powered",
		rules = mesewire_rules
	}}
})

-- Now I got my own sweet Mese pixels, let's use those
minetest.register_node("mesecons_extrawires:mese_powered", {
	description = "Meseblock On",
	tiles = {"mesecons_meseblock_on.png"},
	light_source = 6,
	drop = "default:mese",
	is_ground_content = false,
	groups = {cracky = 3, level = 2},
	mesecons = {conductor = {
		state = mesecon.state.on,
		offstate = "default:mese",
		rules = mesewire_rules
	}}

})

--  And now for some insanity
--  Lets add an Off state CobbleCon here
minetest.register_node("mesecons_extrawires:mese_cobble_off", {
	description = "Mese Cobble Off",
	tiles = {"mesecons_cobblecon_off.png"},
	is_ground_content = false,
	groups = {cracky = 3, level = 2},
	mesecons = {conductor = {
		state = mesecon.state.off,
		onstate = "mesecons_extrawires:mese_cobble_on",
		rules = mesewire_rules
	}}
})

-- Finishing strange with an On state Cobblecon here
minetest.register_node("mesecons_extrawires:mese_cobble_on", {
	description = "Mese Cobble On",
	tiles = {"mesecons_cobblecon_on.png"},
	light_source = 4,
	drop = "mesecons_extrawires:mese_cobble_off",
	is_ground_content = false,
	groups = {cracky = 3, level = 2},
	mesecons = {conductor = {
		state = mesecon.state.on,
		offstate = "mesecons_extrawires:mese_cobble_off",
		rules = mesewire_rules
	}}
})

--  Ok ok, get out of the kitchen you, here's the recipe
minetest.register_craft({
	output = 'mesecons_extrawires:mese_cobble_off 5',
	recipe = {
		{'default:cobble', 'mesecons:wire_00000000_off', 'default:cobble'},
		{'mesecons:wire_00000000_off', 'default:cobble', 'mesecons:wire_00000000_off'},
		{'default:cobble', 'mesecons:wire_00000000_off', 'default:cobble'},
	}
})
