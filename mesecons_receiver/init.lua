local rcvboxes = {
	{ -3/16, -3/16, -8/16       , 3/16,  3/16  , -13/32       }, -- the smaller bump
	{ -1/32, -1/32, -3/2        , 1/32,  1/32  , -1/2         }, -- the wire through the block
	{ -2/32, -1/2 , -.5         , 2/32,  0     , -.5002+3/32  }, -- the vertical wire bit
	{ -2/32, -1/2 , -7/16+0.002 , 2/32,  -14/32,  16/32+0.001 }  -- the horizontal wire
}

local down_rcvboxes = {
	{-6/16, -8/16, -6/16, 6/16, -7/16, 6/16}, -- Top plate
	{-2/16, -6/16, -2/16, 2/16, -7/16, 2/16}, -- Bump
	{-1/16, -8/16, -1/16, 1/16, -24/16, 1/16}, -- Wire through the block
	{-1/16, -8/16, 6/16,  1/16, -7/16, 8/16}, -- Plate extension (North)
	{-1/16, -8/16, -6/16, 1/16, -7/16, -8/16}, -- Plate extension (South)
	{-8/16, -8/16, 1/16, -6/16, -7/16, -1/16}, -- Plate extension (West)
	{6/16,  -8/16, 1/16,  8/16, -7/16, -1/16}, -- Plate extension (East)
}

local up_rcvboxes = {
	{-6/16, -8/16, -6/16, 6/16, -7/16, 6/16}, -- Top plate
	{-2/16, -6/16, -2/16, 2/16, -7/16, 2/16}, -- Bump
	{-1/16, -6/16, -1/16, 1/16, 24/16, 1/16}, -- Wire through the block
	{-1/16, -8/16, 6/16,  1/16, -7/16, 8/16}, -- Plate extension (North)
	{-1/16, -8/16, -6/16, 1/16, -7/16, -8/16}, -- Plate extension (South)
	{-8/16, -8/16, 1/16, -6/16, -7/16, -1/16}, -- Plate extension (West)
	{6/16,  -8/16, 1/16,  8/16, -7/16, -1/16}, -- Plate extension (East)
}

local receiver_get_rules = mesecon.horiz_rules_getter({
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -2},
})

local use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or nil

mesecon.register_node("mesecons_receiver:receiver", {
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	on_rotate = false,
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -8/16, -8/16, 3/16, 3/16, 8/16 }
	},
	node_box = {
		type = "fixed",
		fixed = rcvboxes
	},
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	drop = "mesecons:wire_00000000_off",
	sounds = mesecon.node_sound.default,
}, {
	tiles = {
		"receiver_top_off.png",
		"receiver_bottom_off.png",
		"receiver_lr_off.png",
		"receiver_lr_off.png",
		"receiver_fb_off.png",
		"receiver_fb_off.png",
	},
	mesecons = {conductor = {
		state = mesecon.state.off,
		rules = receiver_get_rules,
		onstate = "mesecons_receiver:receiver_on"
	}}
}, {
	tiles = {
		"receiver_top_on.png",
		"receiver_bottom_on.png",
		"receiver_lr_on.png",
		"receiver_lr_on.png",
		"receiver_fb_on.png",
		"receiver_fb_on.png",
	},
	mesecons = {conductor = {
		state = mesecon.state.on,
		rules = receiver_get_rules,
		offstate = "mesecons_receiver:receiver_off"
	}}
})

mesecon.register_node("mesecons_receiver:receiver_up", {
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	on_rotate = false,
	selection_box = {
		type = "fixed",
		fixed = up_rcvboxes
	},
	node_box = {
		type = "fixed",
		fixed = up_rcvboxes
	},
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	drop = "mesecons:wire_00000000_off",
	sounds = mesecon.node_sound.default,
	use_texture_alpha = use_texture_alpha,
}, {
	tiles = {"mesecons_wire_off.png"},
	mesecons = {conductor = {
		state = mesecon.state.off,
		rules = {{x=1, y=0, z=0},
			{x=-1, y=0, z=0},
			{x=0,  y=0, z=1},
			{x=0,  y=0, z=-1},
			{x=0,  y=1, z=0},
			{x=0,  y=2, z=0}},
		onstate = "mesecons_receiver:receiver_up_on"
	}}
}, {
	tiles = {"mesecons_wire_on.png"},
	mesecons = {conductor = {
		state = mesecon.state.on,
		rules = {{x=1, y=0, z=0},
			{x=-1, y=0, z=0},
			{x=0,  y=0, z=1},
			{x=0,  y=0, z=-1},
			{x=0,  y=1, z=0},
			{x=0,  y=2, z=0}},
		offstate = "mesecons_receiver:receiver_up_off"
	}}
})

mesecon.register_node("mesecons_receiver:receiver_down", {
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	on_rotate = false,
	selection_box = {
		type = "fixed",
		fixed = down_rcvboxes
	},
	node_box = {
		type = "fixed",
		fixed = down_rcvboxes
	},
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	drop = "mesecons:wire_00000000_off",
	sounds = mesecon.node_sound.default,
	use_texture_alpha = use_texture_alpha,
}, {
	tiles = {"mesecons_wire_off.png"},
	mesecons = {conductor = {
		state = mesecon.state.off,
		rules = {{x=1,y=0, z=0},
			{x=-1,y=0, z=0},
			{x=0, y=0, z=1},
			{x=0, y=0, z=-1},
			{x=0, y=-2,z=0}},
		onstate = "mesecons_receiver:receiver_down_on"
	}}
}, {
	tiles = {"mesecons_wire_on.png"},
	mesecons = {conductor = {
		state = mesecon.state.on,
		rules = {{x=1,y=0, z=0},
			{x=-1,y=0, z=0},
			{x=0, y=0, z=1},
			{x=0, y=0, z=-1},
			{x=0, y=-2,z=0}},
		offstate = "mesecons_receiver:receiver_down_off"
	}}
})

function mesecon.receiver_get_pos_from_rcpt(pos, param2)
	local rules = {{x = 2,  y = 0, z = 0}}
	if param2 == nil then param2 = minetest.get_node(pos).param2 end
	local rcvtype = "mesecons_receiver:receiver_off"
	local dir = minetest.facedir_to_dir(param2)

	if dir.x == 1 then
		-- No action needed
	elseif dir.z == -1 then
		rules = mesecon.rotate_rules_left(rules)
	elseif dir.x == -1 then
		rules = mesecon.rotate_rules_right(mesecon.rotate_rules_right(rules))
	elseif dir.z == 1 then
		rules = mesecon.rotate_rules_right(rules)
	elseif dir.y == -1 then
		rules = mesecon.rotate_rules_up(rules)
		rcvtype = "mesecons_receiver:receiver_up_off"
	elseif dir.y == 1 then
		rules = mesecon.rotate_rules_down(rules)
		rcvtype = "mesecons_receiver:receiver_down_off"
	end
	local np = {	x = pos.x + rules[1].x,
			y = pos.y + rules[1].y,
			z = pos.z + rules[1].z}
	return np, rcvtype
end

function mesecon.receiver_place(rcpt_pos)
	local node = minetest.get_node(rcpt_pos)
	local pos, rcvtype = mesecon.receiver_get_pos_from_rcpt(rcpt_pos, node.param2)
	local nn = minetest.get_node(pos)
	local param2 = minetest.dir_to_facedir(minetest.facedir_to_dir(node.param2))

	if string.find(nn.name, "mesecons:wire_") ~= nil then
		local rcv_node = {name = rcvtype, param2 = param2}
		minetest.set_node(pos, rcv_node)
		mesecon.on_dignode(pos, nn)
		mesecon.on_placenode(pos, rcv_node)
	end
end

function mesecon.receiver_remove(rcpt_pos, dugnode)
	local pos = mesecon.receiver_get_pos_from_rcpt(rcpt_pos, dugnode.param2)
	local nn = minetest.get_node(pos)
	if string.find(nn.name, "mesecons_receiver:receiver_") ~= nil then
		local node = {name = "mesecons:wire_00000000_off"}
		minetest.set_node(pos, node)
		mesecon.on_dignode(pos, nn)
		mesecon.on_placenode(pos, node)
	end
end

minetest.register_on_placenode(function (pos, node)
	if minetest.get_item_group(node.name, "mesecon_needs_receiver") == 1 then
		mesecon.receiver_place(pos)
	end
end)

minetest.register_on_dignode(function(pos, node)
	if minetest.get_item_group(node.name, "mesecon_needs_receiver") == 1 then
		mesecon.receiver_remove(pos, node)
	end
end)

minetest.register_on_placenode(function (pos, node)
	if string.find(node.name, "mesecons:wire_") ~= nil then
		local rules = {	{x = 2,  y = 0,  z = 0},
				{x =-2,  y = 0,  z = 0},
				{x = 0,  y = 0,  z = 2},
				{x = 0,  y = 0,  z =-2},
				{x = 0,  y = 2,  z = 0},
				{x = 0,  y = -2, z = 0}}
		local i = 1
		while rules[i] ~= nil do
			local np = {	x = pos.x + rules[i].x,
					y = pos.y + rules[i].y,
					z = pos.z + rules[i].z}
			if minetest.get_item_group(minetest.get_node(np).name, "mesecon_needs_receiver") == 1 then
				mesecon.receiver_place(np)
			end
			i = i + 1
		end
	end
end)

function mesecon.buttonlike_onrotate(pos, node, _, _, new_param2)
	local new_node = {name = node.name, param1 = node.param1, param2 = new_param2}
	minetest.swap_node(pos, new_node)
	mesecon.receiver_remove(pos, node)
	mesecon.on_dignode(pos, node)
	mesecon.on_placenode(pos, new_node)
	mesecon.receiver_place(pos)
	minetest.check_for_falling(pos)
	return true
end
