minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if mesecon:is_conductor_on(oldnode.name) then
			local i = 1
			mesecon:receptor_off(pos)
		end	

		if mesecon:is_receptor_node(oldnode.name) then
			mesecon:receptor_off(pos)
		end
	end
)
