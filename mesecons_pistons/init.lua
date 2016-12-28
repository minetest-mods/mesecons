local piston_get_rules = function (node)
	local all_rules ={
		{x=0,  y=0,  z=1},
		{x=0,  y=0,  z=-1},
		{x=1,  y=0,  z=0},
		{x=-1, y=0,  z=0},
		{x=1,  y=1,  z=0},
		{x=1,  y=-1, z=0},
		{x=-1, y=1,  z=0},
		{x=-1, y=-1, z=0},
		{x=0,  y=1,  z=1},
		{x=0,  y=-1, z=1},
		{x=0,  y=1,  z=-1},
		{x=0,  y=-1, z=-1}}
	local pusher_dir = vector.multiply(minetest.facedir_to_dir(node.param2), -1)
	for k,v in ipairs(all_rules) do
		if vector.equals(v, pusher_dir) then
			table.remove(all_rules, k)
		end
	end
	return all_rules
end

local piston_facedir_direction = function (node)
	local rules = {{x = 0, y = 0, z = -1}}
	for i = 1, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules[1]
end

local piston_remove_pusher = function(pos, node)
	local pistonspec = minetest.registered_nodes[node.name].mesecons_piston
	local dir = vector.multiply(minetest.facedir_to_dir(node.param2), -1)
	local pusherpos = vector.add(pos, dir)
	local pushername = minetest.get_node(pusherpos).name

	-- make sure there actually is a pusher (for compatibility reasons mainly)
	if pushername ~= pistonspec.pusher then
		return
	end

	minetest.remove_node(pusherpos)
	minetest.sound_play("piston_retract", {
		pos = pos,
		max_hear_distance = 20,
		gain = 0.3,
	})
	nodeupdate(pusherpos)
end

local piston_on = function(pos, node)
	local pistonspec = minetest.registered_nodes[node.name].mesecons_piston
	local dir = vector.multiply(minetest.facedir_to_dir(node.param2), -1)
	local np = vector.add(pos, dir)
	local maxpush = mesecon.setting("piston_max_push", 15)
	local success, stack, oldstack = mesecon.mvps_push(np, dir, maxpush)
	if success then
		minetest.set_node(pos, {param2 = node.param2, name = pistonspec.onname})
		minetest.set_node(np,  {param2 = node.param2, name = pistonspec.pusher})
		minetest.sound_play("piston_extend", {
			pos = pos,
			max_hear_distance = 20,
			gain = 0.3,
		})
		mesecon.mvps_process_stack(stack)
		mesecon.mvps_move_objects(np, dir, oldstack)
	end
end

local piston_off = function(pos, node)
	local pistonspec = minetest.registered_nodes[node.name].mesecons_piston
	minetest.set_node(pos, {param2 = node.param2, name = pistonspec.offname})
	piston_remove_pusher(pos, node)
	if pistonspec.sticky then
		local maxpull = mesecon.setting("piston_max_pull", 15)
		local dir = vector.multiply(minetest.facedir_to_dir(node.param2), -1)
		local pullpos = vector.add(pos, vector.multiply(dir, 2))
		local stack = mesecon.mvps_pull_single(pullpos, vector.multiply(dir, -1), maxpull)
		mesecon.mvps_process_stack(pos, dir, stack)
	end
end

local piston_onrotate = function(pos, node, _, _, newparam2)
	local node_copy = minetest.get_node(pos)
	minetest.after(0, mesecon.on_dignode, pos, node)
	node_copy.param2 = newparam2
	minetest.after(0, mesecon.on_placenode, pos, node_copy)
end

local pt = 3/16 -- pusher thickness

local piston_pusher_box = {
	type = "fixed",
	fixed = {
		{-2/16, -2/16, -.5 + pt, 2/16, 2/16,  .5 + pt},
		{-.5  , -.5  , -.5     , .5  , .5  , -.5 + pt},
	}
}

local piston_on_box = {
	type = "fixed",
	fixed = {
		{-.5, -.5, -.5 + pt, .5, .5, .5}
	}
}


-- Normal (non-sticky) ones:

local pistonspec_normal = {
	offname = "mesecons_pistons:piston_normal_off",
	onname = "mesecons_pistons:piston_normal_on",
	dir = piston_facedir_direction,
	pusher = "mesecons_pistons:piston_pusher_normal",
}

-- offstate
minetest.register_node("mesecons_pistons:piston_normal_off", {
	description = "Piston",
	tiles = {
		"mesecons_piston_top.png",
		"mesecons_piston_bottom.png",
		"mesecons_piston_left.png",
		"mesecons_piston_right.png",
		"mesecons_piston_back.png",
		"mesecons_piston_pusher_front.png"
		},
	groups = {cracky = 3},
	paramtype2 = "facedir",
	mesecons_piston = pistonspec_normal,
	on_rotate = piston_onrotate,
	sounds = default.node_sound_wood_defaults(),
	mesecons = {effector={
		action_on = piston_on,
		rules = piston_get_rules
	}}
})

-- onstate
minetest.register_node("mesecons_pistons:piston_normal_on", {
	drawtype = "nodebox",
	tiles = {
		"mesecons_piston_top.png",
		"mesecons_piston_bottom.png",
		"mesecons_piston_left.png",
		"mesecons_piston_right.png",
		"mesecons_piston_back.png",
		"mesecons_piston_on_front.png"
		},
	inventory_image = "mesecons_piston_top.png",
	wield_image = "mesecons_piston_top.png",
	groups = {cracky = 3, not_in_creative_inventory = 1},
	paramtype = "light",
	paramtype2 = "facedir",
	drop = "mesecons_pistons:piston_normal_off",
	after_dig_node = piston_remove_pusher,
	node_box = piston_on_box,
	selection_box = piston_on_box,
	mesecons_piston = pistonspec_normal,
	on_rotate = false,
	sounds = default.node_sound_wood_defaults(),
	mesecons = {effector={
		action_off = piston_off,
		rules = piston_get_rules
	}}
})

-- pusher
minetest.register_node("mesecons_pistons:piston_pusher_normal", {
	drawtype = "nodebox",
	tiles = {
		"mesecons_piston_pusher_top.png",
		"mesecons_piston_pusher_bottom.png",
		"mesecons_piston_pusher_left.png",
		"mesecons_piston_pusher_right.png",
		"mesecons_piston_pusher_back.png",
		"mesecons_piston_pusher_front.png"
		},
	paramtype = "light",
	paramtype2 = "facedir",
	diggable = false,
	on_rotate = false,
	corresponding_piston = "mesecons_pistons:piston_normal_on",
	selection_box = piston_pusher_box,
	node_box = piston_pusher_box,
})

-- Sticky ones

local pistonspec_sticky = {
	offname = "mesecons_pistons:piston_sticky_off",
	onname = "mesecons_pistons:piston_sticky_on",
	dir = piston_facedir_direction,
	pusher = "mesecons_pistons:piston_pusher_sticky",
	sticky = true,
}

-- offstate
minetest.register_node("mesecons_pistons:piston_sticky_off", {
	description = "Sticky Piston",
	tiles = {
		"mesecons_piston_top.png",
		"mesecons_piston_bottom.png",
		"mesecons_piston_left.png",
		"mesecons_piston_right.png",
		"mesecons_piston_back.png",
		"mesecons_piston_pusher_front_sticky.png"
		},
	groups = {cracky = 3},
	paramtype2 = "facedir",
	on_rotate = piston_onrotate,
	mesecons_piston = pistonspec_sticky,
	sounds = default.node_sound_wood_defaults(),
	mesecons = {effector={
		action_on = piston_on,
		rules = piston_get_rules
	}}
})

-- onstate
minetest.register_node("mesecons_pistons:piston_sticky_on", {
	drawtype = "nodebox",
	tiles = {
		"mesecons_piston_top.png",
		"mesecons_piston_bottom.png",
		"mesecons_piston_left.png",
		"mesecons_piston_right.png",
		"mesecons_piston_back.png",
		"mesecons_piston_on_front.png"
		},
	inventory_image = "mesecons_piston_top.png",
	wield_image = "mesecons_piston_top.png",
	groups = {cracky = 3, not_in_creative_inventory = 1},
	paramtype = "light",
	paramtype2 = "facedir",
	drop = "mesecons_pistons:piston_sticky_off",
	after_dig_node = piston_remove_pusher,
	node_box = piston_on_box,
	selection_box = piston_on_box,
	mesecons_piston = pistonspec_sticky,
	on_rotate = false,
	sounds = default.node_sound_wood_defaults(),
	mesecons = {effector={
		action_off = piston_off,
		rules = piston_get_rules
	}}
})

-- pusher
minetest.register_node("mesecons_pistons:piston_pusher_sticky", {
	drawtype = "nodebox",
	tiles = {
		"mesecons_piston_pusher_top.png",
		"mesecons_piston_pusher_bottom.png",
		"mesecons_piston_pusher_left.png",
		"mesecons_piston_pusher_right.png",
		"mesecons_piston_pusher_back.png",
		"mesecons_piston_pusher_front_sticky.png"
		},
	paramtype = "light",
	paramtype2 = "facedir",
	diggable = false,
	on_rotate = false,
	corresponding_piston = "mesecons_pistons:piston_sticky_on",
	selection_box = piston_pusher_box,
	node_box = piston_pusher_box,
})

-- Register pushers as stoppers if they would be seperated from the piston
local piston_pusher_get_stopper = function (node, dir, stack, stackid)
	if (stack[stackid + 1]
	and stack[stackid + 1].node.name   == minetest.registered_nodes[node.name].corresponding_piston
	and stack[stackid + 1].node.param2 == node.param2)
	or (stack[stackid - 1]
	and stack[stackid - 1].node.name   == minetest.registered_nodes[node.name].corresponding_piston
	and stack[stackid - 1].node.param2 == node.param2) then
		return false
	end
	return true
end

local piston_pusher_up_down_get_stopper = function (node, dir, stack, stackid)
	if (stack[stackid + 1]
	and stack[stackid + 1].node.name   == minetest.registered_nodes[node.name].corresponding_piston)
	or (stack[stackid - 1]
	and stack[stackid - 1].node.name   == minetest.registered_nodes[node.name].corresponding_piston) then
		return false
	end
	return true
end

mesecon.register_mvps_stopper("mesecons_pistons:piston_pusher_normal", piston_pusher_get_stopper)
mesecon.register_mvps_stopper("mesecons_pistons:piston_pusher_sticky", piston_pusher_get_stopper)

-- Register pistons as stoppers if they would be seperated from the stopper
local piston_up_down_get_stopper = function (node, dir, stack, stackid)
	if (stack[stackid + 1]
	and stack[stackid + 1].node.name   == minetest.registered_nodes[node.name].mesecons_piston.pusher)
	or (stack[stackid - 1]
	and stack[stackid - 1].node.name   == minetest.registered_nodes[node.name].mesecons_piston.pusher) then
		return false
	end
	return true
end

local piston_get_stopper = function (node, dir, stack, stackid)
	pistonspec = minetest.registered_nodes[node.name].mesecons_piston
	dir = piston_get_direction(pistonspec.dir, node)
	local pusherpos  = vector.add(stack[stackid].pos, dir)
	local pushernode = minetest.get_node(pusherpos)

	if minetest.registered_nodes[node.name].mesecons_piston.pusher == pushernode.name then
		for _, s in ipairs(stack) do
			if  vector.equals(s.pos, pusherpos) -- pusher is also to be pushed
			and s.node.param2 == node.param2 then
				return false
			end
		end
	end
	return true
end

mesecon.register_mvps_stopper("mesecons_pistons:piston_normal_on", piston_get_stopper)
mesecon.register_mvps_stopper("mesecons_pistons:piston_sticky_on", piston_get_stopper)

--craft recipes
minetest.register_craft({
	output = "mesecons_pistons:piston_normal_off 2",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"default:cobble", "default:steel_ingot", "default:cobble"},
		{"default:cobble", "group:mesecon_conductor_craftable", "default:cobble"},
	}
})

minetest.register_craft({
	output = "mesecons_pistons:piston_sticky_off",
	recipe = {
		{"mesecons_materials:glue"},
		{"mesecons_pistons:piston_normal_off"},
	}
})

