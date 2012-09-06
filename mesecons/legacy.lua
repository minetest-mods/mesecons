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
