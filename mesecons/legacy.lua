local rules = {
	a = {x = -1, y = 0, z =  0, name="A"},
	b = {x =  0, y = 0, z =  1, name="B"},
	c = {x =  1, y = 0, z =  0, name="C"},
	d = {x =  0, y = 0, z = -1, name="D"},
}

function mesecon.legacy_update_ports(pos)
	local meta = minetest.get_meta(pos)
	local ports = {
		a = mesecon:is_power_on(mesecon:addPosRule(pos, rules.a),
			mesecon:invertRule(rules.a)) and
			mesecon:rules_link(mesecon:addPosRule(pos, rules.a), pos),
		b = mesecon:is_power_on(mesecon:addPosRule(pos, rules.b),
			mesecon:invertRule(rules.b)) and
			mesecon:rules_link(mesecon:addPosRule(pos, rules.b), pos),
		c = mesecon:is_power_on(mesecon:addPosRule(pos, rules.c),
			mesecon:invertRule(rules.c)) and
			mesecon:rules_link(mesecon:addPosRule(pos, rules.c), pos),
		d = mesecon:is_power_on(mesecon:addPosRule(pos, rules.d),
			mesecon:invertRule(rules.d)) and
			mesecon:rules_link(mesecon:addPosRule(pos, rules.d), pos),
	}
	local n =
		(ports.a and 1 or 0) +
		(ports.b and 2 or 0) +
		(ports.c and 4 or 0) +
		(ports.d and 8 or 0) + 1
	meta:set_int("real_portstates", n)
	return ports
end

