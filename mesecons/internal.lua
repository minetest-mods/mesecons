-- INTERNAL

--Receptors
function mesecon:is_receptor_node(nodename)
	local i = 1
	for i, receptor in ipairs(mesecon.receptors) do
		if receptor.onstate == nodename then
			return true
		end
		i = i + 1
	end
	return false
end

function mesecon:is_receptor_node_off(nodename, pos, ownpos)
	local i = 1
	for i, receptor in ipairs(mesecon.receptors) do
		if receptor.offstate == nodename then
			return true
		end
		i = i + 1
	end
	return false
end

function mesecon:receptor_get_rules(node)
	for i, receptor in ipairs(mesecon.receptors) do
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
	return nil
end

-- Effectors
function mesecon:is_effector_on(nodename)
	for i, effector in ipairs(mesecon.effectors) do
		if effector.onstate == nodename then
			return true
		end
	end
	return false
end

function mesecon:is_effector_off(nodename)
	for i, effector in ipairs(mesecon.effectors) do
		if effector.offstate == nodename then
			return true
		end
	end
	return false
end

function mesecon:is_effector(nodename)
	return mesecon:is_effector_on(nodename) or mesecon:is_effector_off(nodename)
end

function mesecon:effector_get_input_rules(node)
	for i, effector in ipairs(mesecon.effectors) do
		if effector.onstate  == node.name 
		or effector.offstate == node.name then
			if effector.get_input_rules ~= nil then
				return effector.get_input_rules(node.param2)
			elseif mesecon.effectors[i].input_rules ~=nil then
				return effector.input_rules
			else
				return mesecon:get_rules("default")
			end
		end
	end
end

--Signals

function mesecon:activate(pos)
	local node = minetest.env:get_node(pos)	
	for i, action in ipairs(mesecon.actions_on) do
		action(pos, node) 
	end
end

function mesecon:deactivate(pos)
	local node = minetest.env:get_node(pos)	
	local i = 1
	for i, action in ipairs(mesecon.actions_off) do
		action(pos, node) 
	end
end

function mesecon:changesignal(pos)
	local node = minetest.env:get_node(pos)	
	local i = 1
	for i, action in ipairs(mesecon.actions_change) do
		action(pos, node) 
	end
end

--Rules

function mesecon:add_rules(name, rules)
	table.insert(mesecon.rules, {name = name, rules = rules})
end

function mesecon:get_rules(name)
	for i, rule in ipairs(mesecon.rules) do
		if rule.name==name then
			return rule.rules
		end
	end
end

--Conductor system stuff

function mesecon:get_conductor_on(offstate)
	for i, conductor in ipairs(mesecon.conductors) do
		if conductor.offstate == offstate then
			return conductor.onstate
		end
	end
	return false
end

function mesecon:get_conductor_off(onstate)
	for i, conductor in ipairs(mesecon.conductors) do
		if conductor.onstate == onstate then
			return conductor.offstate
		end
	end
	return false
end

function mesecon:is_conductor_on(name)
	for i, conductor in ipairs(mesecon.conductors) do
		if conductor.onstate == name then
			return true
		end
	end
	return false
end

function mesecon:is_conductor_off(name)
	for i, conductor in ipairs(mesecon.conductors) do
		if conductor.offstate == name then
			return true
		end
	end
	return false
end

function mesecon:is_conductor(name)
	return mesecon:is_conductor_on(name) or mesecon:is_conductor_off(name)
end

function mesecon:conductor_get_rules(node)
	for i, conductor in ipairs(mesecon.conductors) do
		if conductor.onstate  == node.name 
		or conductor.offstate == node.name then
			if conductor.get_rules ~= nil then
				return conductor.get_rules(node.param2)
			else
				return conductor.rules
			end
		end
	end
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
	local i = 1

	if mesecon:is_conductor_off(node.name) then
		local rules = mesecon:conductor_get_rules(node)
		minetest.env:add_node(pos, {name=mesecon:get_conductor_on(node.name), param2 = node.param2})

		for i, rule in ipairs(rules) do
			local np = {}
			np.x = pos.x + rule.x
			np.y = pos.y + rule.y
			np.z = pos.z + rule.z

			if mesecon:rules_link(pos, np) then
				mesecon:turnon(np)
			end
		end
	end

	if mesecon:is_effector(node.name) then
		mesecon:changesignal(pos)
		if mesecon:is_effector_off(node.name) then mesecon:activate(pos) end
	end
end

function mesecon:turnoff(pos) --receptor rules used because output could have been dug
	local node = minetest.env:get_node(pos)
	local i = 1
	local rules

	if mesecon:is_conductor_on(node.name) then
		rules = mesecon:conductor_get_rules(node)

		minetest.env:add_node(pos, {name=mesecon:get_conductor_off(node.name), param2 = node.param2})

		for i, rule in ipairs(rules) do
			local np = {
			x = pos.x + rule.x,
			y = pos.y + rule.y,
			z = pos.z + rule.z,}

			if mesecon:rules_link(pos, np) then
				mesecon:turnoff(np)
			end
		end
	end

	if mesecon:is_effector(node.name) then
		mesecon:changesignal(pos)
		if mesecon:is_effector_on(node.name) and not mesecon:is_powered(pos) then mesecon:deactivate(pos) end
	end
end


function mesecon:connected_to_pw_src(pos, checked)
	local c = 1
	if checked == nil then checked = {} end
	while checked[c] ~= nil do --find out if node has already been checked (to prevent from endless loop)
		if  compare_pos(checked[c], pos) then 
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

	local i = 1
	for i, rule in ipairs(rules) do
		local np = {}
		np.x = pos.x + rule.x
		np.y = pos.y + rule.y
		np.z = pos.z + rule.z
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
	local k = 1
	local l = 1

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


	for k, outputrule in ipairs(outputrules) do
		if  outputrule.x + output.x == input.x
		and outputrule.y + output.y == input.y
		and outputrule.z + output.z == input.z then -- Check if output sends to input
			l = 1
			for k, inputrule in ipairs(inputrules) do
				if  inputrule.x + input.x == output.x
				and inputrule.y + input.y == output.y
				and inputrule.z + input.z == output.z then --Check if input accepts from output
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

	for i, rule in ipairs(rules) do
		local con_pos = {
		x = pos.x + rule.x,
		y = pos.y + rule.y,
		z = pos.z + rule.z}

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

	for i, rule in ipairs(rules) do
		local rcpt_pos = {
		x = pos.x + rule.x,
		y = pos.y + rule.y,
		z = pos.z + rule.z}

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

function compare_pos(pos1, pos2)
	return pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z
end

--Rules rotation Functions:
function mesecon:rotate_rules_right(rules)
	local i=1
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
	local i=1
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
	local i=1
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
	local i=1
	local nr={};
	for i, rule in ipairs(rules) do
		nr[i]={}
		nr[i].y=-rule.x
		nr[i].x=rule.y
		nr[i].z=rule.z
	end
	return nr
end
