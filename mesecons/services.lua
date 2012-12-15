mesecon.on_placenode = function (pos, node)
	if mesecon:is_receptor_on(node.name) then
		mesecon:receptor_on(pos, mesecon:receptor_get_rules(node))
	elseif mesecon:is_powered(pos) then
		if mesecon:is_conductor_off(node.name) then
			mesecon:turnon(pos, node)
		else
			mesecon:changesignal(pos, node)
			mesecon:activate(pos, node)
		end
	end
end

mesecon.on_dignode = function (pos, node)
	if mesecon:is_conductor_on(node.name) then
		mesecon:receptor_off(pos)
	elseif mesecon:is_receptor_on(node.name) then
		mesecon:receptor_off(pos, mesecon:receptor_get_rules(node))
	end
end

minetest.register_on_placenode(mesecon.on_placenode)
minetest.register_on_dignode(mesecon.on_dignode)
