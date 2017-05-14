local function crossover_get_rules(node)
	return {
		{--first wire
			{x=-1,y=0,z=0},
			{x=1,y=0,z=0},
		},
		{--second wire
			{x=0,y=0,z=-1},
			{x=0,y=0,z=1},
		},
	}
end

local crossover_states = {
	"mesecons_extrawires:crossover_off",
	"mesecons_extrawires:crossover_01",
	"mesecons_extrawires:crossover_10",
	"mesecons_extrawires:crossover_on",
}

minetest.register_node("mesecons_extrawires:crossover_off", {
	description = "Insulated Mesecon Crossover",
	drawtype = "mesh",
	mesh = "mesecons_extrawires_crossover.b3d",
	tiles = {
		"jeija_insulated_wire_ends_off.png",
		"jeija_insulated_wire_sides_off.png",
		"jeija_insulated_wire_sides_off.png",
		"jeija_insulated_wire_ends_off.png"
	},
	paramtype = "light",
	walkable = false,
	stack_max = 99,
	selection_box = {type="fixed", fixed={-16/32-0.0001, -18/32, -16/32-0.001, 16/32+0.001, -5/32, 16/32+0.001}},
	groups = {dig_immediate=3, mesecon=3},
	mesecons = {
		conductor = {
			states = crossover_states,
			rules = crossover_get_rules(),
		}
	},
	-- doc support:
	_doc_items_longdesc = "Insulated crossing are conductors that conduct two signals between the opposing sides,"..
		" the signals are insulated to each other.",
})

minetest.register_node("mesecons_extrawires:crossover_01", {
	description = "You hacker you!",
	drop = "mesecons_extrawires:crossover_off",
	drawtype = "mesh",
	mesh = "mesecons_extrawires_crossover.b3d",
	tiles = {
		"jeija_insulated_wire_ends_on.png",
		"jeija_insulated_wire_sides_on.png",
		"jeija_insulated_wire_sides_off.png",
		"jeija_insulated_wire_ends_off.png"
	},
	paramtype = "light",
	walkable = false,
	stack_max = 99,
	selection_box = {type="fixed", fixed={-16/32-0.0001, -18/32, -16/32-0.001, 16/32+0.001, -5/32, 16/32+0.001}},
	groups = {dig_immediate=3, mesecon=3, not_in_creative_inventory=1},
	mesecons = {
		conductor = {
			states = crossover_states,
			rules = crossover_get_rules(),
		}
	},
	-- doc support:
	_doc_items_create_entry = false,
})

minetest.register_node("mesecons_extrawires:crossover_10", {
	description = "You hacker you!",
	drop = "mesecons_extrawires:crossover_off",
	drawtype = "mesh",
	mesh = "mesecons_extrawires_crossover.b3d",
	tiles = {
		"jeija_insulated_wire_ends_off.png",
		"jeija_insulated_wire_sides_off.png",
		"jeija_insulated_wire_sides_on.png",
		"jeija_insulated_wire_ends_on.png"
	},
	paramtype = "light",
	walkable = false,
	stack_max = 99,
	selection_box = {type="fixed", fixed={-16/32-0.0001, -18/32, -16/32-0.001, 16/32+0.001, -5/32, 16/32+0.001}},
	groups = {dig_immediate=3, mesecon=3, not_in_creative_inventory=1},
	mesecons = {
		conductor = {
			states = crossover_states,
			rules = crossover_get_rules(),
		}
	},
	-- doc support:
	_doc_items_create_entry = false,
})

minetest.register_node("mesecons_extrawires:crossover_on", {
	description = "You hacker you!",
	drop = "mesecons_extrawires:crossover_off",
	drawtype = "mesh",
	mesh = "mesecons_extrawires_crossover.b3d",
	tiles = {
		"jeija_insulated_wire_ends_on.png",
		"jeija_insulated_wire_sides_on.png",
		"jeija_insulated_wire_sides_on.png",
		"jeija_insulated_wire_ends_on.png"
	},
	paramtype = "light",
	walkable = false,
	stack_max = 99,
	selection_box = {type="fixed", fixed={-16/32-0.0001, -18/32, -16/32-0.001, 16/32+0.001, -5/32, 16/32+0.001}},
	groups = {dig_immediate=3, mesecon=3, not_in_creative_inventory=1},
	mesecons = {
		conductor = {
			states = crossover_states,
			rules = crossover_get_rules(),
		}
	},
	-- doc support:
	_doc_items_create_entry = false,
})

-- doc support:
if minetest.get_modpath("doc") and minetest.get_modpath("doc_items") then
	doc.add_entry_alias("nodes", "mesecons_extrawires:crossover_off", "nodes", "mesecons_extrawires:crossover_01")
	doc.add_entry_alias("nodes", "mesecons_extrawires:crossover_off", "nodes", "mesecons_extrawires:crossover_10")
	doc.add_entry_alias("nodes", "mesecons_extrawires:crossover_off", "nodes", "mesecons_extrawires:crossover_on")
end

minetest.register_craft({
	type = "shapeless",
	output = "mesecons_extrawires:crossover_off",
	recipe = {
		"mesecons_insulated:insulated_off",
		"mesecons_insulated:insulated_off",
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "mesecons_insulated:insulated_off 2",
	recipe = {
		"mesecons_extrawires:crossover_off",
	},
})
