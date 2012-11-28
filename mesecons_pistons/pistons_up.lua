--PISTONS
--registration normal one:
minetest.register_node("mesecons_pistons:piston_up_normal", {
	description = "Piston UP",
	tiles = {"jeija_piston_side.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png"},
	groups = {cracky=3, mesecon = 2},
	after_dig_node = function(pos, oldnode)
		local dir = {x=0, y=1, z=0}
		pos.x, pos.y, pos.z = pos.x + dir.x, pos.y + dir.y, pos.z + dir.z --move to first node to check

		--ensure piston is extended
		local checknode = minetest.env:get_node(pos)
		if checknode.name == "mesecons_pistons:piston_up_pusher_normal" then
			if checknode.param2 == oldnode.param2 then --pusher is facing the same direction as the piston
				minetest.env:remove_node(pos) --remove the pusher
			end
		end
	end,
})

mesecon:register_effector("mesecons_pistons:piston_up_normal", "mesecons_pistons:piston_up_normal")

--registration sticky one:
minetest.register_node("mesecons_pistons:piston_up_sticky", {
	description = "Sticky Piston UP",
	tiles = {"jeija_piston_sticky_side.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png"},
	groups = {cracky=3, mesecon = 2},
	after_dig_node = function(pos, oldnode)
		local dir = {x=0, y=1, z=0}
		pos.x, pos.y, pos.z = pos.x + dir.x, pos.y + dir.y, pos.z + dir.z --move to first node to check

		--ensure piston is extended
		local checknode = minetest.env:get_node(pos)
		if checknode.name == "mesecons_pistons:piston_up_pusher_sticky" then
			if checknode.param2 == oldnode.param2 then --pusher is facing the same direction as the piston
				minetest.env:remove_node(pos) --remove the pusher
			end
		end
	end,
})

mesecon:register_effector("mesecons_pistons:piston_up_sticky", "mesecons_pistons:piston_up_sticky")

minetest.register_craft({
	output = "mesecons_pistons:piston_up_normal",
	recipe = {
		{"mesecons_pistons:piston_normal"},
	}
})
minetest.register_craft({
	output = "mesecons_pistons:piston_up_sticky",
	recipe = {
		{"mesecons_pistons:piston_sticky"},
	}
})

minetest.register_node("mesecons_pistons:piston_up_pusher_normal", {
	drawtype = "nodebox",
	tiles = {"jeija_piston_pusher_normal.png"},
	paramtype = "light",
	diggable = false,
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.2, -0.5, -0.2, 0.2, 0.3, 0.2},
			{-0.5, 0.3, -0.5, 0.5, 0.5, 0.5},
		},
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.2, -0.5, -0.2, 0.2, 0.3, 0.2},
			{-0.5, 0.3, -0.5, 0.5, 0.5, 0.5},
		},
	},
})

mesecon:register_mvps_stopper("mesecons_pistons:piston_up_pusher_normal")
mesecon:register_mvps_stopper("mesecons_pistons:piston_up_pusher_sticky")

minetest.register_node("mesecons_pistons:piston_up_pusher_sticky", {
	drawtype = "nodebox",
	tiles = {
		"jeija_piston_pusher_normal.png",
		"jeija_piston_pusher_sticky.png",
		"jeija_piston_pusher_normal.png",
		"jeija_piston_pusher_normal.png",
		"jeija_piston_pusher_normal.png",
		"jeija_piston_pusher_normal.png"
		},
	paramtype = "light",
	diggable = false,
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.2, -0.5, -0.2, 0.2, 0.3, 0.2},
			{-0.5, 0.3, -0.5, 0.5, 0.5, 0.5},
		},
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.2, -0.5, -0.2, 0.2, 0.3, 0.2},
			{-0.5, 0.3, -0.5, 0.5, 0.5, 0.5},
		},
	},
})

-- Push action
mesecon:register_on_signal_on(function(pos, node)
	if node.name ~= "mesecons_pistons:piston_up_normal" and node.name ~= "mesecons_pistons:piston_up_sticky" then
		return
	end

	local dir = {x=0, y=1, z=0}
	pos.x, pos.y, pos.z = pos.x + dir.x, pos.y + dir.y, pos.z + dir.z --move to first node being pushed

	--determine the number of nodes that need to be pushed
	local count = 0
	local checkpos = {x=pos.x, y=pos.y, z=pos.z} --first node being pushed
	while true do
		local checknode = minetest.env:get_node(checkpos)

		--check for collision with stopper or bounds
		if mesecon:is_mvps_stopper(checknode.name) or checknode.name == "ignore" then
			return
		end

		--check for column end
		if checknode.name == "air"
		or not(minetest.registered_nodes[checknode.name].liquidtype == "none") then
			break
		end

		--limit piston pushing capacity
		count = count + 1
		if count > 15 then
			return
		end

		checkpos.x, checkpos.y, checkpos.z = checkpos.x + dir.x, checkpos.y + dir.y, checkpos.z + dir.z
	end

	local checknode = minetest.env:get_node(pos)
	minetest.env:remove_node(pos) --remove the first node
	mesecon:updatenode(pos)

	--add pusher
	if node.name == "mesecons_pistons:piston_up_normal" then
		minetest.env:add_node(pos, {name="mesecons_pistons:piston_up_pusher_normal", param2=node.param2})
	else
		minetest.env:add_node(pos, {name="mesecons_pistons:piston_up_pusher_sticky", param2=node.param2})
	end

	--move nodes forward
	for i = 1, count do
		pos.x, pos.y, pos.z = pos.x + dir.x, pos.y + dir.y, pos.z + dir.z --move to the next node

		--move the node forward
		local nextnode = minetest.env:get_node(pos)
		--minetest.env:dig_node(pos)
		minetest.env:set_node(pos, checknode)
		mesecon:updatenode(pos)
		checknode = nextnode
	end
end)

--Pull action
mesecon:register_on_signal_off(function(pos, node)
	if node.name ~= "mesecons_pistons:piston_up_normal" and node.name ~= "mesecons_pistons:piston_up_sticky" then
		return
	end

	local dir = {x=0, y=1, z=0}
	pos.x, pos.y, pos.z = pos.x + dir.x, pos.y + dir.y, pos.z + dir.z --move to the node to be replaced

	--ensure piston is extended
	local checknode = minetest.env:get_node(pos)
	if checknode.name ~= "mesecons_pistons:piston_up_pusher_normal" and checknode.name ~= "mesecons_pistons:piston_up_pusher_sticky" then
		return
	end
	if checknode.param2 ~= node.param2 then --pusher is not facing the same direction as the piston
		return --piston is not extended
	end

	--retract piston
	minetest.env:remove_node(pos) --remove pusher
	if node.name == "mesecons_pistons:piston_up_sticky" then --retract block
		local checkpos = {x=pos.x + dir.x, y=pos.y + dir.y, z=pos.z + dir.z} --move to the node to be retracted
		checknode = minetest.env:get_node(checkpos)
		if checknode.name ~= "air"
		and checknode.name ~= "ignore"
		and minetest.registered_nodes[checknode.name].liquidtype == "none"
		and not mesecon:is_mvps_stopper(checknode.name) then
			minetest.env:remove_node(checkpos)
			mesecon:updatenode(checkpos)
			minetest.env:set_node(pos, checknode)
			mesecon:updatenode(pos)
		end
	end
	nodeupdate(pos)
end)
