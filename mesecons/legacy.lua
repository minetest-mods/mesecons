--very old:

function mesecon:add_receptor_node(name, rules, get_rules)
	if get_rules==nil and rules==nil then
		rules=mesecon:get_rules("default")
	end
	table.insert(mesecon.receptors, {onstate = name, rules = rules, get_rules = get_rules})
end

function mesecon:add_receptor_node_off(name, rules, get_rules)
	if get_rules==nil and rules==nil then
		rules=mesecon:get_rules("default")
	end
	table.insert(mesecon.receptors, {offstate = name, rules = rules, get_rules = get_rules})
end

--old:

function mesecon:register_receptor(onstate, offstate, rules, get_rules)
	if get_rules == nil and rules == nil then
		rules=mesecon:get_rules("default")
	end
	table.insert(mesecon.receptors, 
		{onstate = onstate, 
		 offstate = offstate, 
		 rules = input_rules, 
		 get_rules = get_rules})
end

function mesecon:register_effector(onstate, offstate, input_rules, get_input_rules)
	if get_input_rules==nil and input_rules==nil then
		rules=mesecon:get_rules("default")
	end
	table.insert(mesecon.effectors, 
		{onstate = onstate, 
		 offstate = offstate, 
		 input_rules = input_rules, 
		 get_input_rules = get_input_rules})
end

function mesecon:register_on_signal_on(action)
	table.insert(mesecon.actions_on, action)
end

function mesecon:register_on_signal_off(action)
	table.insert(mesecon.actions_off, action)
end

function mesecon:register_on_signal_change(action)
	table.insert(mesecon.actions_change, action)
end

function mesecon:register_conductor (onstate, offstate, rules, get_rules)
	if rules == nil then
		rules = mesecon:get_rules("default")
	end
	table.insert(mesecon.conductors, {onstate = onstate, offstate = offstate, rules = rules, get_rules = get_rules})
end

mesecon:add_rules("default", mesecon.rules.default)
