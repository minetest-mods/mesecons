local vbox = {
	type = "fixed",
	fixed = {-1/16, -.5, -1/16, 1/16, .5, 1/16}
}

local tbox = {
	type = "fixed",
	fixed = {{-.5, -.5, -.5, .5, -.5 + 1/16, .5}}
}

local bbox = {
	type = "fixed",
	fixed = {{  -.5, -.5     ,   -.5,   .5, -.5+1/16,   .5},
		 {-1/16, -.5+1/16, -1/16, 1/16,  .5     , 1/16}}
}

local vrules =
{{x = 0, y = 1, z = 0},
 {x = 0, y =-1, z = 0}}

local trules = 
{{x = 1, y = 0, z = 0},
 {x =-1, y = 0, z = 0},
 {x = 0, y = 0, z = 1},
 {x = 0, y = 0, z =-1},
 {x = 0, y =-1, z = 0}}

local brules = 
{{x = 1, y = 0, z = 0},
 {x =-1, y = 0, z = 0},
 {x = 0, y = 0, z = 1},
 {x = 0, y = 0, z =-1},
 {x = 0, y = 1, z = 0}}

local vertical_updatepos = function (pos)
	local node = minetest.env:get_node(pos)
	if minetest.registered_nodes[node.name].is_vertical_conductor then
		local node_above = minetest.env:get_node(mesecon:addPosRule(pos, vrules[1]))
		local node_below = minetest.env:get_node(mesecon:addPosRule(pos, vrules[2]))
		local namestate = minetest.registered_nodes[node.name].vertical_conductor_state

		-- above and below: vertical mesecon
		if 	minetest.registered_nodes[node_above.name].is_vertical_conductor
		and	minetest.registered_nodes[node_below.name].is_vertical_conductor then
			minetest.env:add_node (pos, 
			{name = "mesecons_extrawires:vertical_"..namestate})

		-- above only: bottom
		elseif 		minetest.registered_nodes[node_above.name].is_vertical_conductor
		and 	not 	minetest.registered_nodes[node_below.name].is_vertical_conductor then
			minetest.env:add_node (pos, 
			{name = "mesecons_extrawires:vertical_bottom_"..namestate})

		-- below only: top
		elseif 	not 	minetest.registered_nodes[node_above.name].is_vertical_conductor
		and		minetest.registered_nodes[node_below.name].is_vertical_conductor then
			minetest.env:add_node (pos, 
			{name = "mesecons_extrawires:vertical_top_"..namestate})
		else -- no vertical wire above, no vertical wire below: use default wire
			minetest.env:add_node (pos, 
			{name = "mesecons_extrawires:vertical_"..namestate})
		end
	end
end

local vertical_update = function (pos, node)
	vertical_updatepos(pos) -- this one
	vertical_updatepos(mesecon:addPosRule(pos, vrules[1])) -- above
	vertical_updatepos(mesecon:addPosRule(pos, vrules[2])) -- below
end

-- Vertical wire
minetest.register_node("mesecons_extrawires:vertical_on", {
	description = "Vertical mesecon",
	drawtype = "nodebox",
	tiles = {"wires_vertical_on.png"},
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	selection_box = vbox,
	node_box = vbox,
	is_vertical_conductor = true,
	vertical_conductor_state = "on",
	mesecons = {conductor = {
		state = mesecon.state.on,
		offstate = "mesecons_extrawires:vertical_off",
		rules = vrules
	}},
	drop = {"mesecons_extrawires:vertical_off"},
	after_place_node	= vertical_update,
	after_dig_node 		= vertical_update
})

minetest.register_node("mesecons_extrawires:vertical_off", {
	description = "Vertical mesecon",
	drawtype = "nodebox",
	tiles = {"wires_vertical_off.png"},
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {dig_immediate = 3},
	selection_box = vbox,
	node_box = vbox,
	is_vertical_conductor = true,
	vertical_conductor_state = "off",
	mesecons = {conductor = {
		state = mesecon.state.off,
		onstate = "mesecons_extrawires:vertical_on",
		rules = vrules
	}},
	after_place_node	= vertical_update,
	after_dig_node 		= vertical_update
})

-- Vertical wire top
minetest.register_node("mesecons_extrawires:vertical_top_on", {
	description = "Vertical mesecon",
	drawtype = "nodebox",
	tiles = {"wires_full_on.png","wires_full_on.png","wires_vertical_on.png"},
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	selection_box = tbox,
	node_box = tbox,
	is_vertical_conductor = true,
	vertical_conductor_state = "on",
	mesecons = {conductor = {
		state = mesecon.state.on,
		offstate = "mesecons_extrawires:vertical_top_off",
		rules = trules
	}},
	drop = {"mesecons_extrawires:vertical_off"},
	after_place_node	= vertical_update,
	after_dig_node 		= vertical_update
})

minetest.register_node("mesecons_extrawires:vertical_top_off", {
	description = "Vertical mesecon",
	drawtype = "nodebox",
	tiles = {"wires_full_off.png","wires_full_off.png","wires_vertical_off.png"},
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	selection_box = tbox,
	node_box = tbox,
	is_vertical_conductor = true,
	vertical_conductor_state = "off",
	mesecons = {conductor = {
		state = mesecon.state.off,
		onstate = "mesecons_extrawires:vertical_top_on",
		rules = trules
	}},
	drop = {"mesecons_extrawires:vertical_off"},
	after_place_node	= vertical_update,
	after_dig_node 		= vertical_update
})

-- Vertical wire bottom
minetest.register_node("mesecons_extrawires:vertical_bottom_on", {
	description = "Vertical mesecon",
	drawtype = "nodebox",
	tiles = {"wires_full_on.png","wires_full_on.png","wires_vertical_on.png"},
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	vertical_conductor_state = "on",
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	selection_box = bbox,
	node_box = bbox,
	mesecons = {conductor = {
		state = mesecon.state.on,
		offstate = "mesecons_extrawires:vertical_bottom_off",
		rules = brules
	}},
	drop = {"mesecons_extrawires:vertical_off"},
	after_place_node	= vertical_update,
	after_dig_node 		= vertical_update
})

minetest.register_node("mesecons_extrawires:vertical_bottom_off", {
	description = "Vertical mesecon",
	drawtype = "nodebox",
	tiles = {"wires_full_off.png","wires_full_off.png","wires_vertical_off.png"},
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	selection_box = bbox,
	node_box = bbox,
	is_vertical_conductor = true,
	vertical_conductor_state = "off",
	mesecons = {conductor = {
		state = mesecon.state.off,
		onstate = "mesecons_extrawires:vertical_bottom_on",
		rules = brules
	}},
	drop = {"mesecons_extrawires:vertical_off"},
	after_place_node	= vertical_update,
	after_dig_node 		= vertical_update
})

minetest.register_craft({
	output = "mesecons_extrawires:vertical_off 3",
	recipe = {
		{"mesecons:wire_00000000_off"},
		{"mesecons:wire_00000000_off"},
		{"mesecons:wire_00000000_off"}
	}
})

minetest.register_craft({
	output = "mesecons:wire_00000000_off",
	recipe = {{"mesecons_extrawires:vertical_off"}}
})
