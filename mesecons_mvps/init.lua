--register stoppers for movestones/pistons

mesecon.mvps_stoppers = {}
mesecon.on_mvps_move = {}
mesecon.mvps_unmov = {}

--- Objects (entities) that cannot be moved
function mesecon.register_mvps_unmov(objectname)
	mesecon.mvps_unmov[objectname] = true;
end

function mesecon.is_mvps_unmov(objectname)
	return mesecon.mvps_unmov[objectname]
end

-- Nodes that cannot be pushed / pulled by movestones, pistons
function mesecon.is_mvps_stopper(node, pushdir, stack, stackid)
	-- unknown nodes are always stoppers
	if not minetest.registered_nodes[node.name] then
		return true
	end

	local get_stopper = mesecon.mvps_stoppers[node.name]
	if type (get_stopper) == "function" then
		get_stopper = get_stopper(node, pushdir, stack, stackid)
	end

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

-- tests if the node can be pushed into, e.g. air, water, grass
local function node_replaceable(name)
	if name == "ignore" then return true end

	if minetest.registered_nodes[name] then
		return minetest.registered_nodes[name].buildable_to or false
	end

	return false
end

function mesecon.mvps_get_stack(pos, dir, maximum, all_pull_sticky)
	-- determine the number of nodes to be pushed
	local nodes = {}
	local frontiers = {pos}

	while #frontiers > 0 do
		local np = frontiers[1]
		local nn = minetest.get_node(np)

		if not node_replaceable(nn.name) then
			table.insert(nodes, {node = nn, pos = np})
			if #nodes > maximum then return nil end

			-- add connected nodes to frontiers, connected is a vector list
			-- the vectors must be absolute positions
			local connected = {}
			if minetest.registered_nodes[nn.name]
			and minetest.registered_nodes[nn.name].mvps_sticky then
				connected = minetest.registered_nodes[nn.name].mvps_sticky(np, nn)
			end

			table.insert(connected, vector.add(np, dir))

			-- If adjacent node is sticky block and connects add that
			-- position to the connected table
			for _, r in ipairs(mesecon.rules.alldirs) do
				local adjpos = vector.add(np, r)
				local adjnode = minetest.get_node(adjpos)
				if minetest.registered_nodes[adjnode.name]
				and minetest.registered_nodes[adjnode.name].mvps_sticky then
					local sticksto = minetest.registered_nodes[adjnode.name]
						.mvps_sticky(adjpos, adjnode)

					-- connects to this position?
					for _, link in ipairs(sticksto) do
						if vector.equals(link, np) then
							table.insert(connected, adjpos)
						end
					end
				end
			end

			if all_pull_sticky then
				table.insert(connected, vector.subtract(np, dir))
			end

			-- Make sure there are no duplicates in frontiers / nodes before
			-- adding nodes in "connected" to frontiers
			for _, cp in ipairs(connected) do
				local duplicate = false
				for _, rp in ipairs(nodes) do
					if vector.equals(cp, rp.pos) then
						duplicate = true
					end
				end
				for _, fp in ipairs(frontiers) do
					if vector.equals(cp, fp) then
						duplicate = true
					end
				end
				if not duplicate then
					table.insert(frontiers, cp)
				end
			end
		end
		table.remove(frontiers, 1)
	end

	return nodes
end

function mesecon.mvps_push(from, pos, dir, maximum)
	return mesecon.mvps_push_or_pull(from, false, pos, dir, dir, maximum)
end

function mesecon.mvps_pull_all(from, pos, dir, maximum)
	return mesecon.mvps_push_or_pull(from, true, pos, vector.multiply(dir, -1), dir, maximum, true)
end

function mesecon.mvps_pull_single(from, pos, dir, maximum)
	return mesecon.mvps_push_or_pull(from, true, pos, vector.multiply(dir, -1), dir, maximum)
end

-- pos: pos of mvps; stackdir: direction of building the stack
-- movedir: direction of actual movement
-- maximum: maximum nodes to be pushed
-- all_pull_sticky: All nodes are sticky in the direction that they are pulled from
function mesecon.mvps_push_or_pull(from, ispulling, pos, stackdir, movedir, maximum, all_pull_sticky)
	local has_meta = minetest.get_meta(from):to_table()
	local owner = minetest.get_meta(from):get_string("owner")
	local tnodes = mesecon.mvps_get_stack(pos, movedir, maximum, all_pull_sticky)
	if not tnodes then return end
	-- determine if one of the nodes blocks the push / pull
	local nodes = {}
	for id, n in ipairs(tnodes) do
		if not has_meta or minetest.is_protected(n.pos, owner) then
			if ispulling then
				break
			else
				return
			end
		end
		if mesecon.is_mvps_stopper(n.node, movedir, nodes, id) then
			if ispulling then
				break
			else
				return
			end
		end
		nodes[id] = n
	end

	-- check nodes
	for _, n in ipairs(nodes) do
		local np = vector.add(n.pos, movedir)

		if not has_meta or minetest.is_protected(np, owner) then
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
		local np = vector.add(n.pos, movedir)

		minetest.set_node(np, n.node)
		minetest.get_meta(np):from_table(n.meta)
	end

	local moved_nodes = {}
	local oldstack = mesecon.tablecopy(nodes)
	for i in ipairs(nodes) do
		moved_nodes[i] = {}
		moved_nodes[i].oldpos = nodes[i].pos
		nodes[i].pos = vector.add(nodes[i].pos, movedir)
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
	end
end)

function mesecon.mvps_move_objects(pos, dir, nodestack)
	local objects_to_move = {}

	-- Move object at tip of stack, pushpos is position at tip of stack
	local pushpos = vector.add(pos, vector.multiply(dir, #nodestack))

	local objects = minetest.get_objects_inside_radius(pushpos, 1)
	for _, obj in ipairs(objects) do
		table.insert(objects_to_move, obj)
	end

	-- Move objects lying/standing on the stack (before it was pushed - oldstack)
	if tonumber(minetest.setting_get("movement_gravity")) > 0 and dir.y == 0 then
		-- If gravity positive and dir horizontal, push players standing on the stack
		for _, n in ipairs(nodestack) do
			local p_above = vector.add(n.pos, {x=0, y=1, z=0})
			local objects = minetest.get_objects_inside_radius(p_above, 1)
			for _, obj in ipairs(objects) do
				table.insert(objects_to_move, obj)
			end
		end
	end

	for _, obj in ipairs(objects_to_move) do
		local entity = obj:get_luaentity()
		if not entity or not mesecon.is_mvps_unmov(entity.name) then
			local np = vector.add(obj:getpos(), dir)

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
