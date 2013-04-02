--register stoppers for movestones/pistons

mesecon.mvps_stoppers = {}
mesecon.mvps_unmov = {}

function mesecon:is_mvps_stopper(node, pushdir, stack, stackid)
	local get_stopper = mesecon.mvps_stoppers[node.name]
	if type (get_stopper) == "function" then
		get_stopper = get_stopper(node, pushdir, stack, stackid)
	end
	return get_stopper
end

function mesecon:register_mvps_stopper(nodename, get_stopper)
	if get_stopper == nil then
			get_stopper = true
	end
	mesecon.mvps_stoppers[nodename] = get_stopper
end

-- Objects that cannot be moved (e.g. movestones)
function mesecon:register_mvps_unmov(objectname)
	mesecon.mvps_unmov[objectname] = true;
end

function mesecon:is_mvps_unmov(objectname)
	return mesecon.mvps_unmov[objectname]
end

function mesecon:mvps_process_stack(stack)
	-- update mesecons for placed nodes ( has to be done after all nodes have been added )
	for _, n in ipairs(stack) do
		nodeupdate(n.pos)
		mesecon.on_placenode(n.pos, minetest.env:get_node(n.pos))
		mesecon:update_autoconnect(n.pos)
	end
end

function mesecon:mvps_get_stack(pos, dir, maximum)
	-- determine the number of nodes to be pushed
	local np = {x = pos.x, y = pos.y, z = pos.z}
	local nodes = {}
	while true do
		local nn = minetest.env:get_node_or_nil(np)
		if not nn or #nodes > maximum then
			-- don't push at all, something is in the way (unloaded map or too many nodes)
			return
		end

		if nn.name == "air"
		or minetest.registered_nodes[nn.name].liquidtype ~= "none" then --is liquid
			break
		end

		table.insert (nodes, {node = nn, pos = np})

		np = mesecon:addPosRule(np, dir)
	end
	return nodes
end

function mesecon:mvps_push(pos, dir, maximum) -- pos: pos of mvps; dir: direction of push; maximum: maximum nodes to be pushed
	local nodes = mesecon:mvps_get_stack(pos, dir, maximum)

	-- determine if one of the nodes blocks the push
	for id, n in ipairs(nodes) do
		if mesecon:is_mvps_stopper(n.node, dir, nodes, id) then
			return
		end
	end

	-- remove all nodes
	for _, n in ipairs(nodes) do
		n.meta = minetest.env:get_meta(n.pos):to_table()
		minetest.env:remove_node(n.pos)
	end

	-- update mesecons for removed nodes ( has to be done after all nodes have been removed )
	for _, n in ipairs(nodes) do
		mesecon.on_dignode(n.pos, n.node)
		mesecon:update_autoconnect(n.pos)
	end

	-- add nodes
	for _, n in ipairs(nodes) do
		np = mesecon:addPosRule(n.pos, dir)
		minetest.env:add_node(np, n.node)
		minetest.env:get_meta(np):from_table(n.meta)
	end

	local oldstack = mesecon:tablecopy(nodes)
	for i in ipairs(nodes) do
		nodes[i].pos = mesecon:addPosRule(nodes[i].pos, dir)
	end

	return true, nodes, oldstack
end

function mesecon:mvps_pull_single(pos, dir) -- pos: pos of mvps; direction: direction of pull (matches push direction for sticky pistons)
	np = mesecon:addPosRule(pos, dir)
	nn = minetest.env:get_node(np)

	if minetest.registered_nodes[nn.name].liquidtype == "none"
	and not mesecon:is_mvps_stopper(nn, {x = -dir.x, y = -dir.y, z = -dir.z}, {{pos = np, node = nn}}, 1) then
		local meta = minetest.env:get_meta(np):to_table()
		minetest.env:remove_node(np)
		minetest.env:add_node(pos, nn)
		minetest.env:get_meta(pos):from_table(meta)

		nodeupdate(np)
		nodeupdate(pos)
		mesecon.on_dignode(np, nn)
		mesecon:update_autoconnect(np)
	end
	return {{pos = np, node = {param2 = 0, name = "air"}}, {pos = pos, node = nn}}
end

function mesecon:mvps_pull_all(pos, direction) -- pos: pos of mvps; direction: direction of pull
	local lpos = {x=pos.x-direction.x, y=pos.y-direction.y, z=pos.z-direction.z} -- 1 away
	local lnode = minetest.env:get_node(lpos)
	local lpos2 = {x=pos.x-direction.x*2, y=pos.y-direction.y*2, z=pos.z-direction.z*2} -- 2 away
	local lnode2 = minetest.env:get_node(lpos2)

	if lnode.name ~= "ignore" and lnode.name ~= "air" and minetest.registered_nodes[lnode.name].liquidtype == "none" then return end
	if lnode2.name == "ignore" or lnode2.name == "air" or not(minetest.registered_nodes[lnode2.name].liquidtype == "none") then return end

	local oldpos = {x=lpos2.x+direction.x, y=lpos2.y+direction.y, z=lpos2.z+direction.z}
	repeat
		lnode2 = minetest.env:get_node(lpos2)
		minetest.env:add_node(oldpos, {name=lnode2.name})
		nodeupdate(oldpos)
		oldpos = {x=lpos2.x, y=lpos2.y, z=lpos2.z}
		lpos2.x = lpos2.x-direction.x
		lpos2.y = lpos2.y-direction.y
		lpos2.z = lpos2.z-direction.z
		lnode = minetest.env:get_node(lpos2)
	until lnode.name=="air" or lnode.name=="ignore" or not(minetest.registered_nodes[lnode2.name].liquidtype == "none")
	minetest.env:remove_node(oldpos)
end

function mesecon:mvps_move_objects(pos, dir, nodestack)
	-- Move object at tip of stack
	local pushpos = mesecon:addPosRule(pos, -- get pos at tip of stack
		{x = dir.x * (#nodestack),
		 y = dir.y * (#nodestack),
		 z = dir.z * (#nodestack)})


	local objects = minetest.env:get_objects_inside_radius(pushpos, 1)
	for _, obj in ipairs(objects) do
		local entity = obj:get_luaentity()
		if not entity or not mesecon:is_mvps_unmov(entity.name) then
			obj:setpos(mesecon:addPosRule(obj:getpos(), dir))
		end
	end

	-- Move objects lying/standing on the stack (before it was pushed - oldstack)
	local objects_above = {}
	if tonumber(minetest.setting_get("movement_gravity")) > 0 and dir.y == 0 then
		-- If gravity positive and dir horizontal, push players standing on the stack
		for _, n in ipairs(nodestack) do
			local p_above = mesecon:addPosRule(n.pos, {x=0, y=1, z=0})
			local objects = minetest.env:get_objects_inside_radius(p_above, 1)
			for _, obj in ipairs(objects) do
				table.insert(objects_above, obj)
			end
		end
	end

	for _, obj in ipairs(objects_above) do
		local entity = obj:get_luaentity()
		if not entity or not mesecon:is_mvps_unmov(entity.name) then
			obj:setpos(mesecon:addPosRule(obj:getpos(), dir))
		end
	end
end

mesecon:register_mvps_stopper("default:chest_locked")
mesecon:register_mvps_stopper("default:furnace")
