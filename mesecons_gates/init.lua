local selection_box = {
	type = "fixed",
	fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 }
}

local nodebox = {
	type = "fixed",
	fixed = {
		{ -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 }, -- bottom slab
		{ -6/16, -7/16, -6/16, 6/16, -6/16, 6/16 }
	},
}

local gate_get_output_rules = mesecon.horiz_rules_getter({{x = 1, y = 0, z = 0}})

local gate_get_input_rules_oneinput = mesecon.horiz_rules_getter({{x =-1, y = 0, z = 0}})

local gate_get_input_rules_twoinputs = mesecon.horiz_rules_getter({
	{x = 0, y = 0, z = 1, name = "input1"},
	{x = 0, y = 0, z = -1, name = "input2"},
})

local function set_gate(pos, node, state)
	local gate = minetest.registered_nodes[node.name]

	local new_nodename = state and gate.onstate or gate.offstate
	minetest.swap_node(pos, {name = new_nodename, param2 = node.param2})
	if new_nodename ~= node.name then
		if mesecon.do_overheat(pos) then
			minetest.remove_node(pos)
			mesecon.receptor_off(pos, gate_get_output_rules(node))
			minetest.add_item(pos, gate.drop)
		elseif state then
			mesecon.receptor_on(pos, gate_get_output_rules(node))
		else
			mesecon.receptor_off(pos, gate_get_output_rules(node))
		end
	end
end

local function update_gate(pos, node, link, newstate)
	local gate = minetest.registered_nodes[node.name]

	if gate.inputnumber == 1 then
		set_gate(pos, node, gate.assess(newstate == "on"))
	elseif gate.inputnumber == 2 then
		-- Inputs are stored in param2. Bit 5 is always set.
		-- input1 is bit 6 and input2 is bit 7.
		local val1, val2
		if node.param2 >= 32 then
			-- Bit 5 is set, so param2 is in the proper format.
			if link.name == "input1" then
				val1 = newstate == "on"
				val2 = node.param2 >= 128
			else
				val1 = node.param2 % 128 >= 64
				val2 = newstate == "on"
			end
		else
			-- Migrate old gates where the inputs are stored as metadata.
			-- This also triggers for newly placed gates.
			local meta = minetest.get_meta(pos)
			if link.name == "input1" then
				val1 = newstate == "on"
				val2 = meta:get_int("input2") == 1
			else
				val1 = meta:get_int("input1") == 1
				val2 = newstate == "on"
			end
			-- Set bit 5 so this won't happen again.
			node.param2 = node.param2 + 32
			-- Clear the metadata.
			meta:set_string("input1", "")
			meta:set_string("input2", "")
		end
		node.param2 = node.param2 % 64 + (val1 and 64 or 0) + (val2 and 128 or 0)
		set_gate(pos, node, gate.assess(val1, val2))
	end
end

local function register_gate(name, inputnumber, assess, recipe, description)
	local get_inputrules = inputnumber == 2 and gate_get_input_rules_twoinputs or
		gate_get_input_rules_oneinput

	local basename = "mesecons_gates:"..name
	mesecon.register_node(basename, {
		description = description,
		inventory_image = "jeija_gate_off.png^jeija_gate_"..name..".png",
		paramtype = "light",
		paramtype2 = "4dir",
		is_ground_content = false,
		drawtype = "nodebox",
		drop = basename.."_off",
		selection_box = selection_box,
		node_box = nodebox,
		walkable = true,
		sounds = mesecon.node_sound.stone,
		assess = assess,
		onstate = basename.."_on",
		offstate = basename.."_off",
		inputnumber = inputnumber,
		after_dig_node = mesecon.do_cooldown,
		on_rotate = mesecon.on_rotate,
	},{
		tiles = {
			"jeija_microcontroller_bottom.png^".."jeija_gate_off.png^"..
			"jeija_gate_output_off.png^".."jeija_gate_"..name..".png",
			"jeija_microcontroller_bottom.png^".."jeija_gate_output_off.png^"..
			"[transformFY",
			"jeija_gate_side.png^".."jeija_gate_side_output_off.png",
			"jeija_gate_side.png",
			"jeija_gate_side.png",
			"jeija_gate_side.png"
		},
		groups = {dig_immediate = 2, overheat = 1},
		mesecons = { receptor = {
			state = "off",
			rules = gate_get_output_rules
		}, effector = {
			rules = get_inputrules,
			action_change = update_gate
		}}
	},{
		tiles = {
			"jeija_microcontroller_bottom.png^".."jeija_gate_on.png^"..
			"jeija_gate_output_on.png^".."jeija_gate_"..name..".png",
			"jeija_microcontroller_bottom.png^".."jeija_gate_output_on.png^"..
			"[transformFY",
			"jeija_gate_side.png^".."jeija_gate_side_output_on.png",
			"jeija_gate_side.png",
			"jeija_gate_side.png",
			"jeija_gate_side.png"
		},
		groups = {dig_immediate = 2, not_in_creative_inventory = 1, overheat = 1},
		mesecons = { receptor = {
			state = "on",
			rules = gate_get_output_rules
		}, effector = {
			rules = get_inputrules,
			action_change = update_gate
		}}
	})

	minetest.register_craft({output = basename.."_off", recipe = recipe})
end

register_gate("diode", 1, function (input) return input end,
	{{"mesecons:mesecon", "mesecons_torch:mesecon_torch_on", "mesecons_torch:mesecon_torch_on"}},
	"Diode")

register_gate("not", 1, function (input) return not input end,
	{{"mesecons:mesecon", "mesecons_torch:mesecon_torch_on", "mesecons:mesecon"}},
	"NOT Gate")

register_gate("and", 2, function (val1, val2) return val1 and val2 end,
	{{"mesecons:mesecon", "", ""},
	 {"", "mesecons_materials:silicon", "mesecons:mesecon"},
	 {"mesecons:mesecon", "", ""}},
	"AND Gate")

register_gate("nand", 2, function (val1, val2) return not (val1 and val2) end,
	{{"mesecons:mesecon", "", ""},
	 {"", "mesecons_materials:silicon", "mesecons_torch:mesecon_torch_on"},
	 {"mesecons:mesecon", "", ""}},
	"NAND Gate")

register_gate("xor", 2, function (val1, val2) return (val1 or val2) and not (val1 and val2) end,
	{{"mesecons:mesecon", "", ""},
	 {"", "mesecons_materials:silicon", "mesecons_materials:silicon"},
	 {"mesecons:mesecon", "", ""}},
	"XOR Gate")

register_gate("nor", 2, function (val1, val2) return not (val1 or val2) end,
	{{"mesecons:mesecon", "", ""},
	 {"", "mesecons:mesecon", "mesecons_torch:mesecon_torch_on"},
	 {"mesecons:mesecon", "", ""}},
	"NOR Gate")

register_gate("or", 2, function (val1, val2) return (val1 or val2) end,
	{{"mesecons:mesecon", "", ""},
	 {"", "mesecons:mesecon", "mesecons:mesecon"},
	 {"mesecons:mesecon", "", ""}},
	"OR Gate")
