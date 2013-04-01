--register stoppers for movestones/pistons

mesecon.mvps_stoppers={}

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

function mesecon:mvps_process_stack(stack)
	-- update mesecons for placed nodes ( has to be done after all nodes have been added )
	for _, n in ipairs(stack) do
		nodeupdate(n.pos)
		mesecon.on_placenode(n.pos, minetest.env:get_node(n.pos))
		mesecon:update_autoconnect(n.pos)
	end
end

function mesecon:piston_object_get(npos,dir,push)
	--get nodes inside radius
	for _,object in ipairs(minetest.env:get_objects_inside_radius(npos, 2)) do
		local pos = object:getpos()
		--check if it's an upright piston
		if dir.y == 1 or dir.y == -1 then
			--if the thing isn't on the piston don't push it
			if npos.x ~= math.floor(0.5+(pos.x)) or npos.z ~= math.floor(0.5+(pos.z)) then
				return
			end
			--for sticky pistons to be able to pull objects
			if push == true then
				local x = pos.x+dir.x
				local y = pos.y+dir.y
				local z = pos.z+dir.z
				object:setpos({x=x,y=y,z=z})
			elseif push == false then
				local x = pos.x-dir.x
				local y = pos.y-dir.y
				local z = pos.z-dir.z
				object:setpos({x=x,y=y,z=z})
			end
		else
			--if the thing isn't on the piston don't push it
			if not npos.x == math.floor(0.5+(pos.x-dir.x)) or not npos.z == math.floor(0.5+(pos.z-dir.z)) or pos.y < npos.y-0.6 then
				return
			end
			--for sticky pistons to be able to pull objects
			if push == true then
				local x = pos.x+dir.x
				local y = pos.y+dir.y
				local z = pos.z+dir.z
				object:setpos({x=x,y=y,z=z})
			elseif push == false then
				local x = pos.x-dir.x
				local y = pos.y-dir.y
				local z = pos.z-dir.z
				object:setpos({x=x,y=y,z=z})
			end
		end
	end
end

function mesecon:mvps_push(pos, dir, maximum) -- pos: pos of mvps; dir: direction of push; maximum: maximum nodes to be pushed
	np = {x = pos.x, y = pos.y, z = pos.z}

	-- determine the number of nodes to be pushed
	local nodes = {}
	while true do
		nn = minetest.env:get_node_or_nil(np)
		if not nn or #nodes > maximum then
			-- don't push at all, something is in the way (unloaded map or too many nodes)
			return
		end

		if nn.name == "air"
		or minetest.registered_nodes[nn.name].liquidtype ~= "none" then --is liquid
			mesecon:piston_object_get(pos,dir,true)
			break
		end

		table.insert (nodes, {node = nn, pos = np})

		np = mesecon:addPosRule(np, dir)
	end

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
		mesecon:piston_object_get(n.pos,dir,true)
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

	for i in ipairs(nodes) do
		nodes[i].pos = mesecon:addPosRule(nodes[i].pos, dir)
	end

	return true, nodes
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
		mesecon:piston_object_get(pos,dir,false)
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

mesecon:register_mvps_stopper("default:chest_locked")
mesecon:register_mvps_stopper("default:furnace")
