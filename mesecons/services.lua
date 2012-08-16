minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if mesecon:is_conductor_on(oldnode.name) then
			mesecon:receptor_off(pos)
		end

		if mesecon:is_receptor_node(oldnode.name) then
			mesecon:receptor_off(pos, mesecon:receptor_get_rules(oldnode))
		end
	end
)

minetest.register_on_placenode(
	function (pos, node)
		if mesecon:is_receptor_node(node.name) then
			mesecon:receptor_on(pos, mesecon:receptor_get_rules(node))
		end

		if mesecon:is_powered(pos) then
			if mesecon:is_conductor_off(node.name) then
				mesecon:turnon(pos)
			else
				mesecon:changesignal(pos)
				mesecon:activate(pos)
			end
		end
	end
)
