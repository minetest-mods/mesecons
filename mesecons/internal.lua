-- INTERNAL

-- Receptors
-- Nodes that can power mesecons
function mesecon:is_receptor_node(nodename)
	if  minetest.registered_nodes[nodename]
	and minetest.registered_nodes[nodename].mesecons
	and minetest.registered_nodes[nodename].mesecons.receptor
	and minetest.registered_nodes[nodename].mesecons.receptor.state == mesecon.state.on then
		return true
	end
	for _, receptor in ipairs(mesecon.receptors) do
		if receptor.onstate == nodename then
			return true
		end
	end
	return false
end

function mesecon:is_receptor_node_off(nodename, pos, ownpos)
	if minetest.registered_nodes[nodename]
	and minetest.registered_nodes[nodename].mesecons
	and minetest.registered_nodes[nodename].mesecons.receptor
	and minetest.registered_nodes[nodename].mesecons.receptor.state == mesecon.state.off then
		return true
	end
	for _, receptor in ipairs(mesecon.receptors) do
		if receptor.offstate == nodename then
			return true
		end
	end
	return false
end

function mesecon:receptor_get_rules(node)
	if  minetest.registered_nodes[node.name].mesecons
	and minetest.registered_nodes[node.name].mesecons.receptor then
		local rules = minetest.registered_nodes[node.name].mesecons.receptor.rules
		if type(rules) == 'function' then
			return rules(node)
		elseif rules then
			return rules
		end
	end
	for _, receptor in ipairs(mesecon.receptors) do --TODO
		if receptor.onstate == node.name or receptor.offstate == node.name then
			if receptor.get_rules ~= nil then
				return receptor.get_rules(node.param2)
			elseif mesecon.receptors[i].rules ~=nil then
				return receptor.rules
			else
				return mesecon:get_rules("default")
			end
		end
	end
	return mesecon.rules.default
end

-- Effectors
-- Nodes that can be powered by mesecons
function mesecon:is_effector_on(nodename)
	if   minetest.registered_nodes[nodename]
	and  minetest.registered_nodes[nodename].mesecons
	and  minetest.registered_nodes[nodename].mesecons.effector
	and minetest.registered_nodes[nodename].mesecons.effector.action_off then
		return true
	end
	for _, effector in ipairs(mesecon.effectors) do --TODO
		if effector.onstate == nodename then
			return true
		end
	end
	return false
end

function mesecon:is_effector_off(nodename)
	if   minetest.registered_nodes[nodename]
	and  minetest.registered_nodes[nodename].mesecons
	and  minetest.registered_nodes[nodename].mesecons.effector
	and minetest.registered_nodes[nodename].mesecons.effector.action_on then
		return true
	end
	for _, effector in ipairs(mesecon.effectors) do --TODO
		if effector.offstate == nodename then
			return true
		end
	end
	return false
end

function mesecon:is_effector(nodename)
	if  minetest.registered_nodes[nodename]
	and minetest.registered_nodes[nodename].mesecons
	and minetest.registered_nodes[nodename].mesecons.effector then
		return true
	end
	return mesecon:is_effector_on(nodename) or mesecon:is_effector_off(nodename) --TODO
end

function mesecon:effector_get_input_rules(node)
	if  minetest.registered_nodes[node.name].mesecons
	and minetest.registered_nodes[node.name].mesecons.effector then
		local rules = minetest.registered_nodes[node.name].mesecons.effector.rules
		if type(rules) == 'function' then
			return rules(node)
		elseif rules then
			return rules
		end
	end
	for _, effector in ipairs(mesecon.effectors) do
		if effector.onstate  == node.name 
		or effector.offstate == node.name then
			if effector.get_input_rules ~= nil then
				return effector.get_input_rules(node.param2)
			elseif effector.input_rules ~=nil then
				return effector.input_rules
			else
				return mesecon:get_rules("default")
			end
		end
	end
	return mesecon.rules.default
end

--Signals

function mesecon:activate(pos, node)
	if  minetest.registered_nodes[node.name]
	and minetest.registered_nodes[node.name].mesecons
	and minetest.registered_nodes[node.name].mesecons.effector
	and minetest.registered_nodes[node.name].mesecons.effector.action_on then
		minetest.registered_nodes[node.name].mesecons.effector.action_on (pos, node)
	end
	for _, action in ipairs(mesecon.actions_on) do --TODO
		action(pos, node) 
	end
end

function mesecon:deactivate(pos, node) --TODO
	if  minetest.registered_nodes[node.name]
	and minetest.registered_nodes[node.name].mesecons
	and minetest.registered_nodes[node.name].mesecons.effector
	and minetest.registered_nodes[node.name].mesecons.effector.action_off then
		minetest.registered_nodes[node.name].mesecons.effector.action_off(pos, node)
	end
	for _, action in ipairs(mesecon.actions_off) do
		action(pos, node) 
	end
end

function mesecon:changesignal(pos, node) --TODO
	if  minetest.registered_nodes[node.name]
	and minetest.registered_nodes[node.name].mesecons
	and minetest.registered_nodes[node.name].mesecons.effector
	and minetest.registered_nodes[node.name].mesecons.effector.action_change then
		minetest.registered_nodes[node.name].mesecons.effector.action_change(pos, node)
	end
	for _, action in ipairs(mesecon.actions_change) do
		action(pos, node) 
	end
end

--Rules

function mesecon:add_rules(name, rules)
	mesecon.rules[name] = rules
end

function mesecon:get_rules(name)
	return mesecon.rules[name]
end

-- Conductors

function mesecon:get_conductor_on(offstate)
	if  minetest.registered_nodes[offstate]
	and minetest.registered_nodes[offstate].mesecons
	and minetest.registered_nodes[offstate].mesecons.conductor then
		return minetest.registered_nodes[offstate].mesecons.conductor.onstate
	end
	for _, conductor in ipairs(mesecon.conductors) do --TODO
		if conductor.offstate == offstate then
			return conductor.onstate
		end
	end
	return false
end

function mesecon:get_conductor_off(onstate)
	if  minetest.registered_nodes[onstate]
	and minetest.registered_nodes[onstate].mesecons
	and minetest.registered_nodes[onstate].mesecons.conductor then
		return minetest.registered_nodes[onstate].mesecons.conductor.offstate
	end
	for _, conductor in ipairs(mesecon.conductors) do --TODO
		if conductor.onstate == onstate then
			return conductor.offstate
		end
	end
	return false
end

function mesecon:is_conductor_on(nodename)
	if minetest.registered_nodes[nodename]
	and minetest.registered_nodes[nodename].mesecons
	and minetest.registered_nodes[nodename].mesecons.conductor
	and minetest.registered_nodes[nodename].mesecons.conductor.state == mesecon.state.on then
		return true
	end
	for _, conductor in ipairs(mesecon.conductors) do --TODO
		if conductor.onstate == nodename then
			return true
		end
	end
	return false
end

function mesecon:is_conductor_off(nodename)
	if minetest.registered_nodes[nodename]
	and minetest.registered_nodes[nodename].mesecons
	and minetest.registered_nodes[nodename].mesecons.conductor
	and minetest.registered_nodes[nodename].mesecons.conductor.state == mesecon.state.off then
		return true
	end
	for _, conductor in ipairs(mesecon.conductors) do --TODO
		if conductor.offstate == nodename then
			return true
		end
	end
	return false
end

function mesecon:is_conductor(nodename)
	--TODO
	return mesecon:is_conductor_on(nodename) or mesecon:is_conductor_off(nodename)
end

function mesecon:conductor_get_rules(node)
	if minetest.registered_nodes[node.name]
	and minetest.registered_nodes[node.name].mesecons
	and minetest.registered_nodes[node.name].mesecons.conductor then
		local rules = minetest.registered_nodes[node.name].mesecons.conductor.rules
		if type(rules) == 'function' then
			return rules(node)
		elseif rules then
			return rules
		end
	end
	for _, conductor in ipairs(mesecon.conductors) do --TODO
		if conductor.onstate  == node.name 
		or conductor.offstate == node.name then
			if conductor.get_rules ~= nil then
				return conductor.get_rules(node.param2)
			else
				return conductor.rules
			end
		end
	end
	return mesecon.rules.default
end

--
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
		return true
	end
	return false
end

function mesecon:turnon(pos)
	local node = minetest.env:get_node(pos)

	if mesecon:is_conductor_off(node.name) then
		local rules = mesecon:conductor_get_rules(node)
		minetest.env:add_node(pos, {name = mesecon:get_conductor_on(node.name)})

		for _, rule in ipairs(rules) do
			local np = mesecon:addPosRule(pos, rule)

			if mesecon:rules_link(pos, np) then
				mesecon:turnon(np)
			end
		end
	end

	if mesecon:is_effector(node.name) then
		mesecon:changesignal(pos, node)
		if mesecon:is_effector_off(node.name) then
			mesecon:activate(pos, node)
		end
	end
end

function mesecon:turnoff(pos)
	local node = minetest.env:get_node(pos)

	if mesecon:is_conductor_on(node.name) then
		local rules = mesecon:conductor_get_rules(node)
		minetest.env:add_node(pos, {name = mesecon:get_conductor_off(node.name)})

		for _, rule in ipairs(rules) do
			local np = mesecon:addPosRule(pos, rule)

			if mesecon:rules_link(pos, np) then
				mesecon:turnoff(np)
			end
		end
	end

	if mesecon:is_effector(node.name) then
		mesecon:changesignal(pos, node)
		if mesecon:is_effector_on(node.name)
		and not mesecon:is_powered(pos) then
			mesecon:deactivate(pos, node)
		end
	end
end


function mesecon:connected_to_pw_src(pos, checked)
	local c = 1
	checked = checked or {}
	while checked[c] ~= nil do --find out if node has already been checked (to prevent from endless loop)
		if mesecon:cmpPos(checked[c], pos) then
			return false, checked
		end
		c = c + 1
	end
	checked[c] = {x=pos.x, y=pos.y, z=pos.z} --add current node to checked

	local node = minetest.env:get_node_or_nil(pos)
	if node == nil then return false, checked end
	if not mesecon:is_conductor(node.name) then return false, checked end
	if mesecon:is_powered_by_receptor(pos) then --return if conductor is powered
		return true, checked
	end

	--Check if conductors around are connected
	local connected
	local rules = mesecon:conductor_get_rules(node)

	for _, rule in ipairs(rules) do
		local np = mesecon:addPosRule(pos, rule)
		if mesecon:rules_link(pos, np) then
			connected, checked = mesecon:connected_to_pw_src(np, checked)
			if connected then 
				return true
			end
		end
	end
	return false, checked
end

function mesecon:rules_link(output, input, dug_outputrules) --output/input are positions (outputrules optional, used if node has been dug)
	local outputnode = minetest.env:get_node(output)
	local inputnode = minetest.env:get_node(input)
	local outputrules = dug_outputrules
	local inputrules

	if outputrules == nil then
		if mesecon:is_conductor(outputnode.name) then
			outputrules = mesecon:conductor_get_rules(outputnode)
		elseif mesecon:is_receptor_node(outputnode.name) or mesecon:is_receptor_node_off(outputnode.name) then
			outputrules = mesecon:receptor_get_rules(outputnode)
		else
			return false
		end
	end

	if mesecon:is_conductor(inputnode.name) then
		inputrules = mesecon:conductor_get_rules(inputnode)
	elseif mesecon:is_effector(inputnode.name) then
		inputrules = mesecon:effector_get_input_rules(inputnode)
	else
		return false
	end


	for _, outputrule in ipairs(outputrules) do
		if mesecon:cmpPos(mesecon:addPosRule(output, outputrule), input) then -- Check if output sends to input
			for _, inputrule in ipairs(inputrules) do
				if  mesecon:cmpPos(mesecon:addPosRule(input, inputrule), output) then --Check if input accepts from output
					return true
				end
			end
		end
	end
	return false
end

function mesecon:rules_link_bothdir(pos1, pos2)
	return mesecon:rules_link(pos1, pos2) or mesecon:rules_link(pos2, pos1)
end

function mesecon:is_powered_by_conductor(pos)
	local j = 1
	local k = 1

	local rules
	local con_pos = {}
	local con_rules = {}
	local con_node

	local node = minetest.env:get_node(pos)
	if mesecon:is_conductor(node.name) then
		rules = mesecon:conductor_get_rules(node)
	elseif mesecon:is_effector(node.name) then
		rules = mesecon:effector_get_input_rules(node)
	else
		return false
	end

	for _, rule in ipairs(rules) do
		local con_pos = mesecon:addPosRule(pos, rule)

		con_node = minetest.env:get_node(con_pos)

		if mesecon:is_conductor_on(con_node.name) and mesecon:rules_link(con_pos, pos) then 
			return true
		end
	end
	
	return false
end

function mesecon:is_powered_by_receptor(pos)
	local j = 1
	local k = 1

	local rules
	local rcpt_pos = {}
	local rcpt_rules = {}
	local rcpt_node

	local node = minetest.env:get_node(pos)
	if mesecon:is_conductor(node.name) then
		rules = mesecon:conductor_get_rules(node)
	elseif mesecon:is_effector(node.name) then
		rules = mesecon:effector_get_input_rules(node)
	else
		return false
	end

	for _, rule in ipairs(rules) do
		local rcpt_pos = mesecon:addPosRule(pos, rule)

		rcpt_node = minetest.env:get_node(rcpt_pos)

		if mesecon:is_receptor_node(rcpt_node.name) and mesecon:rules_link(rcpt_pos, pos) then
			return true
		end
	end
	
	return false
end

function mesecon:is_powered(pos)
	return mesecon:is_powered_by_conductor(pos) or mesecon:is_powered_by_receptor(pos)
end

function mesecon:updatenode(pos)
    if mesecon:connected_to_pw_src(pos) then
        mesecon:turnon(pos)
    else
	mesecon:turnoff(pos)
    end
end

--Rules rotation Functions:
function mesecon:rotate_rules_right(rules)
	local nr={};
	for i, rule in ipairs(rules) do
		nr[i]={}
		nr[i].z=rule.x
		nr[i].x=-rule.z
		nr[i].y=rule.y
	end
	return nr
end

function mesecon:rotate_rules_left(rules)
	local nr={};
	for i, rule in ipairs(rules) do
		nr[i]={}
		nr[i].z=-rules[i].x
		nr[i].x=rules[i].z
		nr[i].y=rules[i].y
	end
	return nr
end

function mesecon:rotate_rules_down(rules)
	local nr={};
	for i, rule in ipairs(rules) do
		nr[i]={}
		nr[i].y=rule.x
		nr[i].x=-rule.y
		nr[i].z=rule.z
	end
	return nr
end

function mesecon:rotate_rules_up(rules)
	local nr={};
	for i, rule in ipairs(rules) do
		nr[i]={}
		nr[i].y=-rule.x
		nr[i].x=rule.y
		nr[i].z=rule.z
	end
	return nr
end
