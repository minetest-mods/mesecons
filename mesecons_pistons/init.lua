--PISTONS
--registration normal one:
minetest.register_node("mesecons_pistons:piston_normal", {
	description = "Piston",
	tiles = {"jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_side.png"},
	groups = {cracky=3},
	paramtype2 = "facedir",
	after_dig_node = function(pos, oldnode)
		local dir = mesecon:piston_get_direction(oldnode)
		pos.x, pos.y, pos.z = pos.x + dir.x, pos.y + dir.y, pos.z + dir.z --move to first node to check

		--ensure piston is extended
		local checknode = minetest.env:get_node(pos)
		if checknode.name == "mesecons_pistons:piston_pusher_normal" then
			if checknode.param2 == oldnode.param2 then --pusher is facing the same direction as the piston
				minetest.env:remove_node(pos) --remove the pusher
			end
		end
	end,
})

--registration sticky one:
minetest.register_node("mesecons_pistons:piston_sticky", {
	description = "Sticky Piston",
	tiles = {"jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_sticky_side.png"},
	groups = {cracky=3},
	paramtype2 = "facedir",
	after_dig_node = function(pos, oldnode)
		local dir = mesecon:piston_get_direction(oldnode)
		pos.x, pos.y, pos.z = pos.x + dir.x, pos.y + dir.y, pos.z + dir.z --move to first node to check

		--ensure piston is extended
		local checknode = minetest.env:get_node(pos)
		if checknode.name == "mesecons_pistons:piston_pusher_sticky" then
			if checknode.param2 == oldnode.param2 then --pusher is facing the same direction as the piston
				minetest.env:remove_node(pos) --remove the pusher
			end
		end
	end,
})

minetest.register_craft({
	output = '"mesecons_pistons:piston_normal" 2',
	recipe = {
		{"default:wood", "default:wood", "default:wood"},
		{"default:cobble", "default:steel_ingot", "default:cobble"},
		{"default:cobble", "mesecons:mesecon_off", "default:cobble"},
	}
})

minetest.register_craft({
	output = "mesecons_pistons:piston_sticky",
	recipe = {
		{"mesecons_materials:glue"},
		{"mesecons_pistons:piston_normal"},
	}
})

minetest.register_node("mesecons_pistons:piston_pusher_normal", {
	drawtype = "nodebox",
	tiles = {"jeija_piston_pusher_normal.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	diggable = false,
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.2, -0.2, -0.3, 0.2, 0.2, 0.5},
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.3},
		},
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.2, -0.2, -0.3, 0.2, 0.2, 0.5},
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.3},
		},
	},
})

mesecon:register_mvps_stopper("mesecons_pistons:piston_pusher_normal")
mesecon:register_mvps_stopper("mesecons_pistons:piston_pusher_sticky")

minetest.register_node("mesecons_pistons:piston_pusher_sticky", {
	drawtype = "nodebox",
	tiles = {
		"jeija_piston_pusher_normal.png",
		"jeija_piston_pusher_normal.png",
		"jeija_piston_pusher_normal.png",
		"jeija_piston_pusher_normal.png",
		"jeija_piston_pusher_normal.png",
		"jeija_piston_pusher_sticky.png"
		},
	paramtype = "light",
	paramtype2 = "facedir",
	diggable = false,
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.2, -0.2, -0.3, 0.2, 0.2, 0.5},
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.3},
		},
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.2, -0.2, -0.3, 0.2, 0.2, 0.5},
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.3},
		},
	},
})

-- Push action
mesecon:register_on_signal_on(function(pos, node)
	if node.name ~= "mesecons_pistons:piston_normal" and node.name ~= "mesecons_pistons:piston_sticky" then
		return
	end

	local dir = mesecon:piston_get_direction(node)
	pos.x, pos.y, pos.z = pos.x + dir.x, pos.y + dir.y, pos.z + dir.z --move to first node being pushed

	--determine the number of nodes that need to be pushed
	local count = 0
	local checkpos = {x=pos.x, y=pos.y, z=pos.z} --first node being pushed
	while true do
		local checknode = minetest.env:get_node(checkpos)

		--check for collision with stopper
		if mesecon:is_mvps_stopper(checknode.name) then 
			return
		end

		--check for column end
		if checknode.name == "air"
		or checknode.name == "ignore"
		or checknode.name == "default:water_source"
		or checknode.name == "default:water_flowing"
		or checknode.name == "default:lava_source"
		or checknode.name == "default:lava_flowing" then
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
	minetest.env:dig_node(pos) --remove the first node

	--add pusher
	if node.name == "mesecons_pistons:piston_normal" then
		minetest.env:add_node(pos, {name="mesecons_pistons:piston_pusher_normal", param2=node.param2})
	else
		minetest.env:add_node(pos, {name="mesecons_pistons:piston_pusher_sticky", param2=node.param2})
	end

	--move nodes forward
	for i = 1, count do
		pos.x, pos.y, pos.z = pos.x + dir.x, pos.y + dir.y, pos.z + dir.z --move to the next node

		--move the node forward
		local nextnode = minetest.env:get_node(pos)
		minetest.env:dig_node(pos)
		minetest.env:place_node(pos, checknode)
		checknode = nextnode
	end
end)

--Pull action
mesecon:register_on_signal_off(function(pos, node)
	if node.name ~= "mesecons_pistons:piston_normal" and node.name ~= "mesecons_pistons:piston_sticky" then
		return
	end

	local dir = mesecon:piston_get_direction(node)
	pos.x, pos.y, pos.z = pos.x + dir.x, pos.y + dir.y, pos.z + dir.z --move to the node to be replaced

	--ensure piston is extended
	local checknode = minetest.env:get_node(pos)
	if checknode.name ~= "mesecons_pistons:piston_pusher_normal" and checknode.name ~= "mesecons_pistons:piston_pusher_sticky" then
		return
	end
	if checknode.param2 ~= node.param2 then --pusher is not facing the same direction as the piston
		return --piston is not extended
	end

	--retract piston
	minetest.env:remove_node(pos) --remove pusher
	if node.name ~= "mesecons_pistons:piston_sticky" then
	    nodeupdate(pos)
	end
	if node.name == "mesecons_pistons:piston_sticky" then --retract block
		local checkpos = {x=pos.x + dir.x, y=pos.y + dir.y, z=pos.z + dir.z} --move to the node to be retracted
		checknode = minetest.env:get_node(checkpos)
		if checknode.name ~= "air"
		and checknode.name ~= "ignore"
		and checknode.name ~= "default:water_source"
		and checknode.name ~= "default:water_flowing"
		and checknode.name ~= "default:lava_source"
		and checknode.name ~= "default:lava_flowing"
		and not mesecon:is_mvps_stopper(checknode.name) then
			minetest.env:place_node(pos, checknode)
			minetest.env:dig_node(checkpos)
		end
	end
	if node.name == "mesecons_pistons:piston_sticky" then
	    nodeupdate(pos)
	end
end)

-- get push direction
function mesecon:piston_get_direction(node)
	if node.param2 == 3 then
		return {x=1, y=0, z=0}
	elseif node.param2 == 2 then
		return {x=0, y=0, z=1}
	elseif node.param2 == 1 then
		return {x=-1, y=0, z=0}
	else --node.param2 == 0
		return {x=0, y=0, z=-1}
	end
end
