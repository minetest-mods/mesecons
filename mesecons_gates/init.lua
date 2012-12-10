local outrules = {
	{x=1, y=0, z=0},
}

local oneinput = {
	{x=-1, y=0, z=0},
	{x=1, y=0, z=0},
}

local twoinputs = {
	{x=0, y=0, z=1},
	{x=0, y=0, z=-1},
	{x=1, y=0, z=0},
}

function get_gate_rules(param2, onlyout, singleinput)
	if not param2 then return end
	if onlyout then
		rules = outrules
	else
		if singleinput then
			rules = oneinput
		else
			rules = twoinputs
		end
	end
	for rotations = 0, param2 - 1 do
		rules = mesecon:rotate_rules_left(rules)
	end
	return rules
end

function get_gate_rules_one(node)
	print("gettin"..dump(node).." | PARAM2: "..node.param2)
	return get_gate_rules(node.param2, false, true)
end

function get_gate_rules_two(node)
	return get_gate_rules(node.param2, false, false)
end

function get_gate_rules_out(node)
	return get_gate_rules(node.param2, true)
end

gates = {"diode", "not", "nand", "and", "xor"}
for g in ipairs(gates) do gate = gates[g]
	if g < 3 then
		get_rules = get_gate_rules_one
	else
		get_rules = get_gate_rules_two
	end
	for on=0,1 do
		nodename = "mesecons_gates:"..gate
		if on == 1 then
			onoff = "on"
			drop = nodename.."_off"
			nodename = nodename.."_"..onoff
			description = "You hacker you!"
			groups = {dig_immediate=2, not_in_creative_inventory=1}
		else
			onoff = "off"
			nodename = nodename.."_"..onoff
			description = gate.." Gate"
			groups = {dig_immediate=2}
		end

		tiles = "jeija_microcontroller_bottom.png^"..
			"jeija_gate_"..onoff..".png^"..
			"jeija_gate_"..gate..".png"

		node_box = {
			type = "fixed",
			fixed = {
				{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
			},
		}

		local mesecon_state
		if on == 1 then
			mesecon_state = mesecon.state.on
		else
			mesecon_state = mesecon.state.off
		end

		minetest.register_node(nodename, {
			description = description,
			paramtype = "light",
			paramtype2 = "facedir",
			drawtype = "nodebox",
			tiles = {tiles},
			inventory_image = tiles,
			selection_box = node_box,
			node_box = node_box,
			walkable = true,
			on_construct = function(pos)
				local meta = minetest.env:get_meta(pos)
				meta:set_int("heat", 0)
				update_gate(pos)
			end,
			groups = groups,
			drop = drop,
			mesecons =
			{
				receptor =
				{
					state = mesecon_state,
					rules = get_gate_rules_out
				},
				effector =
				{
					rules = get_rules,
					action_change = function (pos, node)
						update_gate(pos)
					end
				}
			}
		})
	end
end

function get_gate(pos)
	return
	string.gsub( 
	string.gsub(
	string.gsub(
	minetest.env:get_node(pos).name
	, "mesecons_gates:", "") --gate
	,"_on", "")
	,"_off", "")
end

function gate_state(pos)
	name = minetest.env:get_node(pos).name
	return string.find(name, "_on") ~= nil
end

function pop_gate(pos)
	gate = get_gate(pos)
	minetest.env:remove_node(pos)
	minetest.after(0.2, yc_overheat_off, pos)
	minetest.env:add_item(pos, "mesecons_gates:"..gate.."_off")
end

function set_gate(pos, on)
	gate = get_gate(pos)
	local meta = minetest.env:get_meta(pos)
	if on ~= gate_state(pos) then
		yc_heat(meta)
		minetest.after(0.5, yc_cool, meta)
		if yc_overheat(meta) then
			pop_gate(pos)
		else
			if on then
				mesecon:swap_node(pos, "mesecons_gates:"..gate.."_on")
				mesecon:receptor_on(pos, get_gate_rules(param2, true))
			else
				mesecon:swap_node(pos, "mesecons_gates:"..gate.."_off")
				mesecon:receptor_off(pos, all_rules)
			end
		end
	end
end

function rotate_ports(L, param2)
	for rotations=0, param2-1 do
		port = L.a
		L.a = L.b
		L.b = L.c
		L.c = L.d
		L.d = port
	end
	return L
end

function update_gate(pos)
	gate = get_gate(pos)
	L = rotate_ports(
		yc_get_real_portstates(pos),
		minetest.env:get_node(pos).param2
	)
	if gate == "diode" then
		set_gate(pos, L.a)	
	elseif gate == "not" then
		set_gate(pos, not L.a)
	elseif gate == "nand" then
		set_gate(pos, not(L.b and L.d))
	elseif gate == "and" then
		set_gate(pos, L.b and L.d)
	elseif gate == "xor" then
		set_gate(pos, (L.b and not L.d) or (not L.b and L.d))
	end
end

minetest.register_craft({
	output = 'mesecons_gates:diode_off',
	recipe = {
		{'', '', ''},
		{'mesecons:mesecon', 'mesecons_torch:mesecon_torch_on', 'mesecons_torch:mesecon_torch_on'},
		{'', '', ''},
	},
})

minetest.register_craft({
	output = 'mesecons_gates:not_off',
	recipe = {
		{'', '', ''},
		{'mesecons:mesecon', 'mesecons_torch:mesecon_torch_on', 'mesecons:mesecon'},
		{'', '', ''},
	},
})

minetest.register_craft({
	output = 'mesecons_gates:and_off',
	recipe = {
		{'mesecons:mesecon', '', ''},
		{'', 'mesecons_materials:silicon', 'mesecons:mesecon'},
		{'mesecons:mesecon', '', ''},
	},
})

minetest.register_craft({
	output = 'mesecons_gates:nand_off',
	recipe = {
		{'mesecons:mesecon', '', ''},
		{'', 'mesecons_materials:silicon', 'mesecons_torch:mesecon_torch_on'},
		{'mesecons:mesecon', '', ''},
	},
})

minetest.register_craft({
	output = 'mesecons_gates:xor_off',
	recipe = {
		{'mesecons:mesecon', '', ''},
		{'', 'mesecons_materials:silicon', 'mesecons_materials:silicon'},
		{'mesecons:mesecon', '', ''},
	},
})

