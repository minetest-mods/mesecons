gates = {"diode", "not", "nand", "and", "xor"}
out = {x=1, y=0, z=0}
inonerules = {{x=-1, y=0, z=0}}
intworules = {{x=0, y=0, z=1},{x=0, y=0, z=-1}}
onerules = inonerules
table.insert(onerules, out)
tworules = intworules
table.insert(tworules, out)
outrules = {}
outrules = table.insert(outrules, out)
for g in ipairs(gates) do gate = gates[g]
	if g < 3 then
		inrules = inonerules
		rules = onerules
	else
		inrules = intworules
		rules = tworules
	end
	for on=0,1 do
		if on == 1 then
			onoff = "on"
			groups = {dig_immediate=2, not_in_creative_inventory=1, mesecon = 3}
			drop = "mesecons_gates:"..gate.."_off"
		else
			onoff = "off"
			groups = {dig_immediate=2, mesecon = 3}
			drop = nodename
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
			drop = drop,

		})

		mesecon:register_effector(nodename, nodename, inrules)
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

function set_gate(pos, on)
	gate = get_gate(pos)
	local rules = {{x=1, y=0, z=0}}
	if on then
		if not gate_state(pos) then
			minetest.env:add_node(pos, {name="mesecons_gates:"..gate.."_on"})
		mesecon:receptor_on(pos, rules)
		end
	else
		if gate_state(pos) then
			minetest.env:add_node(pos, {name="mesecons_gates:"..gate.."_off"})
			mesecon:receptor_off(pos, rules)
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

