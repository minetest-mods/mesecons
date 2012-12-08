minetest.after(0, 
function ()
	if minetest.registered_nodes["doors:door_wood_b_1"] then
		mesecon:register_effector("doors:door_wood_b_1", "doors:door_wood_b_2")
		mesecon:register_on_signal_change(function(pos, node)
			if node.name == "doors:door_wood_b_2" or node.name == "doors:door_wood_b_1" then
				minetest.registered_nodes[node.name].on_punch(pos, node)
			end
		end)
	end
end)
