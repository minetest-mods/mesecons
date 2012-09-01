gates = {"diode", "not", "nand", "and", "xor"}
for g in ipairs(gates) do gate = gates[g]

	inrules = {}
	outrules = {}
	rules = {}
	table.insert(outrules, {x=1, y=0, z=0})
	table.insert(rules, {x=1, y=0, z=0})
	if g < 3 then
		table.insert(inrules, {x=-1, y=0, z=0})
		table.insert(rules, {x=-1, y=0, z=0})
	else
		table.insert(inrules, {x=0, y=0, z=1})
		table.insert(rules, {x=0, y=0, z=1})
		table.insert(inrules, {x=0, y=0, z=-1})
		table.insert(rules, {x=0, y=0, z=-1})
	end
	--table.insert(rules, inrules)
	--table.insert(rules, outrules)

	for on=0,1 do
		if on == 1 then
			onoff = "on"
		else
			onoff = "off"
		end
		if on == 1 then
			groups = {dig_immediate=2, not_in_creative_inventory=1, mesecon = 3}
		else
			groups = {dig_immediate=2, mesecon = 3}
		end

		nodename = "mesecons_gates:"..gate.."_"..onoff

		minetest.register_node(nodename, {
			description = gate.." Gate",
			drawtype = "normal",
			tiles = {
				"jeija_gate_"..onoff..".png^"..
				"jeija_gate_"..gate..".png",
			},
			walkable = true,
			on_construct = function(pos)
				update_gate(pos)
			end,
			groups = groups,

		})

		mesecon:add_rules(gate,outrules)
		mesecon:register_effector(nodename, nodename, rules)
		--if on then
		--	mesecon:add_receptor_node(nodename, outrules)
		--end
		--mesecon:add_receptor_node("mesecons_gates:and_off", 
		--mesecon:add_receptor_node("mesecons_gates:and_on", 
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
	if string.find(name, "off")~=nil then
		return false
	else
		return true
	end
end
--[[
function gate_on(pos)
	if !gate_state(pos) then
		minetest.env:add_node("mesecons_gates:"..get_gate(pos).."_on")
	end
end

function gate_off(pos)
	if gate_state(pos) then
		minetest.env:add_node("mesecons_gates:"..get_gate(pos).."_off")
	end
end
--]]
function set_gate(pos, open)
	if open then
		if not gate_state(pos) then
			minetest.env:add_node(pos, {name="mesecons_gates:"..get_gate(pos).."_on"})
		end
	else
		if gate_state(pos) then
			minetest.env:add_node(pos, {name="mesecons_gates:"..get_gate(pos).."_off"})
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


