--register stoppers for movestones/pistons

mesecon.mvps_stoppers = {}
mesecon.on_mvps_move = {}

function mesecon.is_mvps_stopper(node, pushdir, stack, stackid)
	local get_stopper = mesecon.mvps_stoppers[node.name]
	if type (get_stopper) == "function" then
		get_stopper = get_stopper(node, pushdir, stack, stackid)
	end
	if (get_stopper) then print(node.name) end
	return get_stopper
end

function mesecon.register_mvps_stopper(nodename, get_stopper)
	if get_stopper == nil then
			get_stopper = true
	end
	mesecon.mvps_stoppers[nodename] = get_stopper
end

-- Functions to be called on mvps movement
function mesecon.register_on_mvps_move(callback)
	mesecon.on_mvps_move[#mesecon.on_mvps_move+1] = callback
end

local function on_mvps_move(moved_nodes)
	for _, callback in ipairs(mesecon.on_mvps_move) do
		callback(moved_nodes)
	end
end

function mesecon.mvps_process_stack(stack)
	-- update mesecons for placed nodes ( has to be done after all nodes have been added )
	for _, n in ipairs(stack) do
		mesecon.on_placenode(n.pos, minetest.get_node(n.pos))
	end
end

function mesecon.mvps_get_stack(pos, dir, maximum)
	-- determine the number of nodes to be pushed
	local np = {x = pos.x, y = pos.y, z = pos.z}
	local nodes = {}
	while true do
		local nn = minetest.get_node_or_nil(np)
		if not nn or #nodes > maximum then
			-- don't push at all, something is in the way (unloaded map or too many nodes)
			return nil
		end

		if nn.name == "air"
		or (minetest.registered_nodes[nn.name]
		and minetest.registered_nodes[nn.name].liquidtype ~= "none") then --is liquid
			break
		end

		table.insert (nodes, {node = nn, pos = np})

		np = mesecon.addPosRule(np, dir)
	end
	return nodes
end

function mesecon.mvps_push(pos, dir, maximum)
	return mesecon.mvps_push_or_pull(pos, dir, dir, maximum)
end

function mesecon.mvps_pull_all(pos, dir, maximum)
	return mesecon.mvps_push_or_pull(pos, vector.multiply(dir, -1), dir, maximum)
end

function mesecon.mvps_push_or_pull(pos, stackdir, movedir, maximum) -- pos: pos of mvps; stackdir: direction of building the stack; movedir: direction of actual movement; maximum: maximum nodes to be pushed
	local nodes = mesecon.mvps_get_stack(pos, stackdir, maximum)

	if not nodes then return end
	-- determine if one of the nodes blocks the push / pull
	for id, n in ipairs(nodes) do
		if mesecon.is_mvps_stopper(n.node, movedir, nodes, id) then
			return
		end
	end

	-- remove all nodes
	for _, n in ipairs(nodes) do
		n.meta = minetest.get_meta(n.pos):to_table()
		minetest.remove_node(n.pos)
	end

	-- update mesecons for removed nodes ( has to be done after all nodes have been removed )
	for _, n in ipairs(nodes) do
		mesecon.on_dignode(n.pos, n.node)
	end

	-- add nodes
	for _, n in ipairs(nodes) do
		local np = mesecon.addPosRule(n.pos, movedir)

		minetest.add_node(np, n.node)
		minetest.get_meta(np):from_table(n.meta)
	end

	local moved_nodes = {}
	local oldstack = mesecon.tablecopy(nodes)
	for i in ipairs(nodes) do
		moved_nodes[i] = {}
		moved_nodes[i].oldpos = nodes[i].pos
		nodes[i].pos = mesecon.addPosRule(nodes[i].pos, movedir)
		moved_nodes[i].pos = nodes[i].pos
		moved_nodes[i].node = nodes[i].node
		moved_nodes[i].meta = nodes[i].meta
	end

	on_mvps_move(moved_nodes)

	return true, nodes, oldstack
end

mesecon.register_on_mvps_move(function(moved_nodes)
	for _, n in ipairs(moved_nodes) do
		mesecon.on_placenode(n.pos, n.node)
		mesecon.update_autoconnect(n.pos)
	end
end)

function mesecon.mvps_pull_single(pos, dir) -- pos: pos of mvps; direction: direction of pull (matches push direction for sticky pistons)
	local np = mesecon.addPosRule(pos, dir)
	local nn = minetest.get_node(np)

	if ((not minetest.registered_nodes[nn.name]) --unregistered node
	or minetest.registered_nodes[nn.name].liquidtype == "none") --non-liquid node
	and not mesecon.is_mvps_stopper(nn, dir, {{pos = np, node = nn}}, 1) then --non-stopper node
		local meta = minetest.get_meta(np):to_table()
		minetest.remove_node(np)
		minetest.add_node(pos, nn)
		minetest.get_meta(pos):from_table(meta)

		nodeupdate(np)
		nodeupdate(pos)
		mesecon.on_dignode(np, nn)
		mesecon.update_autoconnect(np)
		on_mvps_move({{pos = pos, oldpos = np, node = nn, meta = meta}})
	end
	return {{pos = np, node = {param2 = 0, name = "air"}}, {pos = pos, node = nn}}
end

function mesecon.mvps_move_objects(pos, dir, nodestack)
	local objects_to_move = {}

	-- Move object at tip of stack
	local pushpos = mesecon.addPosRule(pos, -- get pos at tip of stack
		{x = dir.x * #nodestack,
		 y = dir.y * #nodestack,
		 z = dir.z * #nodestack})


	local objects = minetest.get_objects_inside_radius(pushpos, 1)
	for _, obj in ipairs(objects) do
		table.insert(objects_to_move, obj)
	end

	-- Move objects lying/standing on the stack (before it was pushed - oldstack)
	if tonumber(minetest.setting_get("movement_gravity")) > 0 and dir.y == 0 then
		-- If gravity positive and dir horizontal, push players standing on the stack
		for _, n in ipairs(nodestack) do
			local p_above = mesecon.addPosRule(n.pos, {x=0, y=1, z=0})
			local objects = minetest.get_objects_inside_radius(p_above, 1)
			for _, obj in ipairs(objects) do
				table.insert(objects_to_move, obj)
			end
		end
	end

	for _, obj in ipairs(objects_to_move) do
		local entity = obj:get_luaentity()
		if not entity then
			local np = mesecon.addPosRule(obj:getpos(), dir)

			--move only if destination is not solid
			local nn = minetest.get_node(np)
			if not ((not minetest.registered_nodes[nn.name])
			or minetest.registered_nodes[nn.name].walkable) then
				obj:setpos(np)
			end
		end
	end
end

mesecon.register_mvps_stopper("doors:door_steel_b_1")
mesecon.register_mvps_stopper("doors:door_steel_t_1")
mesecon.register_mvps_stopper("doors:door_steel_b_2")
mesecon.register_mvps_stopper("doors:door_steel_t_2")
mesecon.register_mvps_stopper("default:chest_locked")
