outrules = {
	{x=1, y=0, z=0},
}
gates = {"diode", "not", "nand", "and", "xor"}
for g in ipairs(gates) do gate = gates[g]
	if g < 3 then
		rules = {
			{x=-1, y=0, z=0},
			{x=1, y=0, z=0},
		}
	else
		rules = {
			{x=0, y=0, z=1},
			{x=0, y=0, z=-1},
			{x=1, y=0, z=0},
		}
	end
	for on=0,1 do
		nodename = "mesecons_gates:"..gate
		if on == 1 then
			onoff = "on"
			drop = nodename.."_off"
			groups = {dig_immediate=2, not_in_creative_inventory=1, mesecon = 3}
			description = "You hacker you!"
			nodename = nodename.."_"..onoff
			mesecon:add_receptor_node(nodename, outrules)
		else
			onoff = "off"
			groups = {dig_immediate=2, mesecon = 3}
			description = gate.." Gate"
			nodename = nodename.."_"..onoff
			--mesecon:add_receptor_node_off(nodename, rules)
		end

		node_box = {
			type = "fixed",
			fixed = { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
		}

		minetest.register_node(nodename, {
			description = description,
			paramtype = "light",
			drawtype = "nodebox",
			tiles = {
				"jeija_microcontroller_bottom.png^"..
				"jeija_gate_"..onoff..".png^"..
				"jeija_gate_"..gate..".png",
			},
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

		})

		mesecon:register_effector(nodename, nodename, rules)
	end
end

function get_gate(pos)
	string = minetest.env:get_node(pos).name
	string = string.gsub(string, "mesecons_gates:", "")
	--gate
	string = string.gsub(string, "_on", "")
	string = string.gsub(string, "_off", "")
	return string
end

function gate_state(pos)
	name = minetest.env:get_node(pos).name
	return string.find(name, "off") == nil
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
	local rules = {{x=1, y=0, z=0}}
	if on ~= gate_state(pos) then
		yc_heat(meta)
		minetest.after(0.5, yc_cool, meta)
		if yc_overheat(meta) then
			pop_gate(pos)
		else
			heat = meta:get_int("heat")
			if on then
				onoff = "_on"
			else
				onoff = "_off"
			end
			minetest.env:add_node(pos, {name="mesecons_gates:"..gate..onoff})
			local meta2 = minetest.env:get_meta(pos)
			meta2:set_int("heat", heat)
			if on then
				mesecon:receptor_on(pos, rules)
			else
				mesecon:receptor_off(pos, rules)
			end
		end
	end
end

function update_gate(pos)
	gate = get_gate(pos)
	L = yc_get_real_portstates(pos)
	if gate == "diode" then
		set_gate(pos, L.a)	
	elseif gate == "not" then
		set_gate(pos, not L.a)
	elseif gate == "nand" then
		set_gate(pos, not(L.b and L.d))
	elseif gate == "and" then
		set_gate(pos, L.b and L.d)
	else--if gate == "xor" then
		set_gate(pos, (L.b and not L.d) or (not L.b and L.d))
	end
end

mesecon:register_on_signal_change(function(pos,node)
	if string.find(node.name, "mesecons_gates:")~=nil then
		update_gate(pos)
	end
end)

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

