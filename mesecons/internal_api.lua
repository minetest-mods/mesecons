-- INTERNAL API

function mesecon:is_receptor_node(nodename, pos, ownpos) --ownpos must be position of the effector/mesecon NOT of the receptor node; pos is the receptor position
	local i=1
	local j=1
	repeat
		if mesecon.pwr_srcs[i].name==nodename then
			if pos==nil and ownpos==nil then --old usage still possible
				return true
			end
			local rules = mesecon.pwr_srcs[i].rules
			local get_rules = mesecon.pwr_srcs[i].get_rules
			local node = minetest.env:get_node(pos)

			if get_rules~=nil then --get_rules preferred
				rules = get_rules(node.param2)
			end

			j=1
			while rules[j]~=nil do --Check if dest. position is specified in the receptor's rules
				if pos.x+rules[j].x==ownpos.x
				and pos.y+rules[j].y==ownpos.y
				and pos.z+rules[j].z==ownpos.z then
					return true
				end
				j=j+1
			end
		end
		i=i+1
	until mesecon.pwr_srcs[i]==nil
	return false
end

function mesecon:is_receptor_node_off(nodename, pos, ownpos) --ownpos must be position of the effector/mesecon NOT of the receptor node; pos is the receptor position
	local i=1
	local j=1
	repeat
		if mesecon.pwr_srcs_off[i].name==nodename then
			if pos==nil and ownpos==nil then --old usage still possible
				return true
			end
			local rules = mesecon.pwr_srcs_off[i].rules
			local rules = mesecon.pwr_srcs_off[i].get_rules
			local node = minetest.env:get_node(pos)

			if get_rules ~= nil then
				rules = get_rules(node.param2)
			end

			j=1
			while rules[j]~=nil do
				if pos.x+rules[j].x==ownpos.x
				and pos.y+rules[j].y==ownpos.y
				and pos.z+rules[j].z==ownpos.z then
					return true
				end
				j=j+1
			end
		end
		i=i+1
	until mesecon.pwr_srcs_off[i]==nil
	return false
end

--Signals

function mesecon:activate(pos)
	local node = minetest.env:get_node(pos)	
	local i = 1
	repeat
		i=i+1
		if mesecon.actions_on[i]~=nil then mesecon.actions_on[i](pos, node) 
		else break			
		end
	until false
end

function mesecon:deactivate(pos)
	local node = minetest.env:get_node(pos)	
	local i = 1
	repeat
		i=i+1
		if mesecon.actions_off[i]~=nil then mesecon.actions_off[i](pos, node) 
		else break			
		end
	until false
end

function mesecon:changesignal(pos)
	local node = minetest.env:get_node(pos)	
	local i = 1
	repeat
		i=i+1
		if mesecon.actions_change[i]~=nil then mesecon.actions_change[i](pos, node) 
		else break			
		end
	until false
end

--Rules

function mesecon:add_rules(name, rules)
	local i=0
	while mesecon.rules[i]~=nil do
		i=i+1
	end
	mesecon.rules[i]={}
	mesecon.rules[i].name=name
	mesecon.rules[i].rules=rules
end

function mesecon:get_rules(name)
	local i=0
	while mesecon.rules[i]~=nil do
		if mesecon.rules[i].name==name then
			return mesecon.rules[i].rules
		end
		i=i+1
	end
end

--Conductor system stuff

function mesecon:get_conductor_on(offstate)
	local i=0
	while mesecon.conductors[i]~=nil do
		if mesecon.conductors[i].off==offstate then
			return mesecon.conductors[i].on
		end
		i=i+1
	end
	return false
end

function mesecon:get_conductor_off(onstate)
	local i=0
	while mesecon.conductors[i]~=nil do
		if mesecon.conductors[i].on==onstate then
			return mesecon.conductors[i].off
		end
		i=i+1
	end
	return false
end

function mesecon:is_conductor_on(name)
	local i=0
	while mesecon.conductors[i]~=nil do
		if mesecon.conductors[i].on==name then
			return true
		end
		i=i+1
	end
	return false
end

function mesecon:is_conductor_off(name)
	local i=0
	while mesecon.conductors[i]~=nil do
		if mesecon.conductors[i].off==name then
			return true
		end
		i=i+1
	end
	return false
end

--Rules rotation Functions:
function mesecon:rotate_rules_right(rules)
	local i=1
	local nr={};
	while rules[i]~=nil do
		nr[i]={}
		nr[i].z=rules[i].x
		nr[i].x=-rules[i].z
		nr[i].y=rules[i].y
		i=i+1
	end
	return nr
end

function mesecon:rotate_rules_left(rules)
	local i=1
	local nr={};
	while rules[i]~=nil do
		nr[i]={}
		nr[i].z=-rules[i].x
		nr[i].x=rules[i].z
		nr[i].y=rules[i].y
		i=i+1
	end
	return nr
end

function mesecon:rotate_rules_down(rules)
	local i=1
	local nr={};
	while rules[i]~=nil do
		nr[i]={}
		nr[i].y=rules[i].x
		nr[i].x=-rules[i].y
		nr[i].z=rules[i].z
		i=i+1
	end
	return nr
end

function mesecon:rotate_rules_up(rules)
	local i=1
	local nr={};
	while rules[i]~=nil do
		nr[i]={}
		nr[i].y=-rules[i].x
		nr[i].x=rules[i].y
		nr[i].z=rules[i].z
		i=i+1
	end
	return nr
end

function mesecon:is_power_on(pos)
	local node = minetest.env:get_node(pos)
	if mesecon:is_conductor_on(node.name) or mesecon:is_receptor_node(node.name) then
		return true
	end
	return false
end

function mesecon:is_power_off(pos)
	local node = minetest.env:get_node(pos)
	if mesecon:is_conductor_off(node.name) or mesecon:is_receptor_node_off(node.name) then
		return 1
	end
	return 0
end

function mesecon:turnon(pos)
	local node = minetest.env:get_node(pos)

	if mesecon:is_conductor_off(node.name) then
		minetest.env:add_node(pos, {name=mesecon:get_conductor_on(node.name)})
		nodeupdate(pos)

		rules = mesecon:get_rules("default") --TODO: Use rules of conductor
		local i=1
		while rules[i]~=nil do
			local np = {}
			np.x = pos.x + rules[i].x
			np.y = pos.y + rules[i].y
			np.z = pos.z + rules[i].z
			mesecon:turnon(np)
			i=i+1
		end
	end

	mesecon:changesignal(pos)
	if minetest.get_item_group(node.name, "mesecon_effector_off") == 1 then
		mesecon:activate(pos)
	end
end

function mesecon:turnoff(pos)
	local node = minetest.env:get_node(pos)

	if mesecon:is_conductor_on(node.name) then
		minetest.env:add_node(pos, {name=mesecon:get_conductor_off(node.name)})
		nodeupdate(pos)

		rules = mesecon:get_rules("default") --TODO: Use ruels of conductor
		local i = 1
		while rules[i]~=nil do
			local np = {}
			np.x = pos.x + rules[i].x
			np.y = pos.y + rules[i].y
			np.z = pos.z + rules[i].z
			mesecon:turnoff(np)
			i=i+1
		end
	end

	mesecon:changesignal(pos) --Changesignal is always thrown because nodes can be both receptors and effectors
	if minetest.get_item_group(node.name, "mesecon_effector_on") == 1 and
	not mesecon:is_powered(pos) then --Check if the signal comes from another source
		--Send Signals to effectors:
		mesecon:deactivate(pos)
	end
end


function mesecon:connected_to_pw_src(pos, checked)
	local i = 1
	while checked[i] ~= nil do --find out if node has already been checked
		if  checked[i].x == pos.x and checked[i].y == pos.y and checked[i].z == pos.z then 
			return false
		end
		i = i + 1
	end
	checked[i] = {x=pos.x, y=pos.y, z=pos.z} --add current node to checked

	local node = minetest.env:get_node_or_nil(pos)
	if node == nil then return false end

	if mesecon:is_conductor_on(node.name) or mesecon:is_conductor_off(node.name) then
		if mesecon:is_powered_from_receptor(pos) then --return if conductor is powered
			return true
		end

		local rules = mesecon:get_rules("default") --TODO: Use conductor specific rules
		local i = 1
		while rules[i] ~= nil do
			local np = {}
			np.x = pos.x + rules[i].x
			np.y = pos.y + rules[i].y
			np.z = pos.z + rules[i].z
			if mesecon:connected_to_pw_src(np, checked) == true then 
				return true 
			end
			i=i+1
		end
	end
	return false
end

function mesecon:is_powered_from_receptor(pos)
	local rcpt
	local rcpt_pos = {}
	local rcpt_checked = {} --using a checked array speeds this up
	local i = 1
	local j = 1
	local k = 1
	local pos_checked = false

	while mesecon.rules[i]~=nil do
		j=1
		while mesecon.rules[i].rules[j]~=nil do
			rcpt_pos = {
			x = pos.x-mesecon.rules[i].rules[j].x, 
			y = pos.y-mesecon.rules[i].rules[j].y, 
			z = pos.z-mesecon.rules[i].rules[j].z}

			k = 1
			pos_checked = false
			while rcpt_checked[k] ~= nil do
				if compare_pos(rcpt_checked[k], rcpt_pos) then
					pos_checked = true
				end
				k = k + 1
			end

			if not pos_checked then
				table.insert(rcpt_checked, rcpt_pos)
				rcpt = minetest.env:get_node(rcpt_pos)
				if mesecon:is_receptor_node(rcpt.name, rcpt_pos, pos) then 
					return true 
				end
			end
			j=j+1
		end
		i=i+1
	end
	return false
end

function mesecon:is_powered_from_conductor(pos)
	local k=1

	rules=mesecon:get_rules("default") --TODO: use conductor specific rules
	while rules[k]~=nil do
		if mesecon:is_conductor_on(minetest.env:get_node({x=pos.x+rules[k].x, y=pos.y+rules[k].y, z=pos.z+rules[k].z}).name) then
			return true
		end
		k=k+1
	end
	return false
end

function mesecon:is_powered(pos)
	return mesecon:is_powered_from_conductor(pos) or mesecon:is_powered_from_receptor(pos)
end

function mesecon:updatenode(pos)
    if mesecon:connected_to_pw_src(pos, {}) then
        mesecon:turnon(pos)
    else
	mesecon:turnoff(pos)
    end
end

minetest.register_on_placenode(function(pos, newnode, placer)
	if mesecon:is_powered(pos) then
		if mesecon:is_conductor_off(newnode.name) then
			mesecon:turnon(pos)		
		else
			mesecon:changesignal(pos)
			mesecon:activate(pos)
		end
	end
end)

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if mesecon:is_conductor_on(oldnode.name) then
			local i = 1
			mesecon:receptor_off(pos)
		end	
	end
)

function compare_pos(pos1, pos2)
	return pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z
end
