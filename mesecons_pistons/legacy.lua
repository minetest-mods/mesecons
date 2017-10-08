local ground_dir = {
	[0] = {x =  0, y = -1, z =  0},
	      {x =  0, y =  0, z = -1},
	      {x =  0, y =  0, z =  1},
	      {x = -1, y =  0, z =  0},
	      {x =  1, y =  0, z =  0},
	      {x =  0, y =  1, z =  0},
}

minetest.register_lbm({
	label = "Upgrade legacy pistons pointing up",
	name = "mesecons_pistons:replace_legacy_piston_up",
	nodenames = {
		"mesecons_pistons:piston_up_normal_off",
		"mesecons_pistons:piston_up_normal_on",
		"mesecons_pistons:piston_up_pusher_normal",
		"mesecons_pistons:piston_up_sticky_off",
		"mesecons_pistons:piston_up_sticky_on",
		"mesecons_pistons:piston_up_pusher_sticky",
	},
	run_at_every_load = false,
	action = function(pos, node)
		local dir = ground_dir[math.floor(node.param2/4)]
		node.param2 = minetest.dir_to_facedir(dir, true)
		node.name = node.name:sub(1, 24)..node.name:sub(28)
		minetest.swap_node(pos, node)
	end,
})

minetest.register_lbm({
	label = "Upgrade legacy pistons pointing down",
	name = "mesecons_pistons:replace_legacy_piston_down",
	nodenames = {
		"mesecons_pistons:piston_down_normal_off",
		"mesecons_pistons:piston_down_normal_on",
		"mesecons_pistons:piston_down_pusher_normal",
		"mesecons_pistons:piston_down_sticky_off",
		"mesecons_pistons:piston_down_sticky_on",
		"mesecons_pistons:piston_down_pusher_sticky",
	},
	run_at_every_load = false,
	action = function(pos, node)
		local dir = vector.multiply(ground_dir[math.floor(node.param2/4)], -1)
		node.param2 = minetest.dir_to_facedir(dir, true)
		node.name = node.name:sub(1, 24)..node.name:sub(30)
		minetest.swap_node(pos, node)
	end,
})
