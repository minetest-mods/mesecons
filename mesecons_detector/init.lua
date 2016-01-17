local GET_COMMAND = "GET"

-- Object detector
-- Detects players in a certain radius

local object_detector_make_formspec = function (pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec", "size[9,2.5]" ..
		"field[0.3,  0;9,2;scanname;Name of player to scan for (empty for any):;${scanname}]"..
		"field[0.3,1.5;4,2;digiline_channel;Digiline Channel (optional):;${digiline_channel}]"..
		"field[4.5,1.5;2,2;radius;Radius:;${radius}]"..
		"button_exit[7,0.75;2,3;save;Save]")
end

local object_detector_on_receive_fields = function(pos, formname, fields)
	if not fields.save then return end

	local meta = minetest.get_meta(pos)
	meta:set_string("scanname", fields.scanname)
	meta:set_string("digiline_channel", fields.digiline_channel)
	local max_radius = mesecon.setting("object_detector_max_radius")
	local radius = math.max(1, math.min(max_radius, fields.radius))
	meta:set_float("radius", radius)
	object_detector_make_formspec(pos)
end

-- Returns names of players found
local object_detector_scan = function (pos, meta)
	local radius = meta:get_float("radius")
	if radius == 0 then radius = 6 end
	local objs = minetest.get_objects_inside_radius(pos, radius)
	local ret = {}
	for k, obj in pairs(objs) do
		-- "" is returned if it is not a player; "" ~= nil!
		local name = obj:get_player_name()
		local scan_name = meta:get_string("scanname")
		-- If a player with scan_name found or not scan_name specified
		if name ~= "" and name == scan_name or scan_name == "" then
			table.insert(ret, name)
			if name == scan_name then
				break
			end
		end
	end
	return ret
end

-- set player name when receiving a digiline signal on a specific channel
local object_detector_digiline = {
	effector = {
		action = function (pos, node, channel, msg)
			local meta = minetest.get_meta(pos)
			local active_channel = meta:get_string("digiline_channel")
			if channel ~= active_channel or type(msg) ~= "string" then
				return
			end
			meta:set_string("scanname", msg)
			object_detector_make_formspec(pos)
		end,
	},
	receptor = {}
}

minetest.register_node("mesecons_detector:object_detector_off", {
	tiles = {"default_steel_block.png", "default_steel_block.png", "jeija_object_detector_off.png", "jeija_object_detector_off.png", "jeija_object_detector_off.png", "jeija_object_detector_off.png"},
	paramtype = "light",
	walkable = true,
	groups = {cracky=3},
	description="Player Detector",
	mesecons = {receptor = {
		state = mesecon.state.off,
		rules = mesecon.rules.pplate
	}},
	on_construct = object_detector_make_formspec,
	on_receive_fields = object_detector_on_receive_fields,
	sounds = default.node_sound_stone_defaults(),
	digiline = object_detector_digiline
})

minetest.register_node("mesecons_detector:object_detector_on", {
	tiles = {"default_steel_block.png", "default_steel_block.png", "jeija_object_detector_on.png", "jeija_object_detector_on.png", "jeija_object_detector_on.png", "jeija_object_detector_on.png"},
	paramtype = "light",
	walkable = true,
	groups = {cracky=3,not_in_creative_inventory=1},
	drop = 'mesecons_detector:object_detector_off',
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = mesecon.rules.pplate
	}},
	on_construct = object_detector_make_formspec,
	on_receive_fields = object_detector_on_receive_fields,
	sounds = default.node_sound_stone_defaults(),
	digiline = object_detector_digiline
})

minetest.register_craft({
	output = 'mesecons_detector:object_detector_off',
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "mesecons_luacontroller:luacontroller0000", "default:steel_ingot"},
		{"default:steel_ingot", "group:mesecon_conductor_craftable", "default:steel_ingot"},
	}
})

minetest.register_abm({
	nodenames = {"mesecons_detector:object_detector_on",
		"mesecons_detector:object_detector_off"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node)
		local was_on = node.name:sub(-2) == "on"
		local meta = minetest.get_meta(pos)
		local objs = object_detector_scan(pos, meta)
		local nobjs = #objs

		if was_on and nobjs == 0 then
			minetest.swap_node(pos, {name="mesecons_detector:object_detector_off"})
			mesecon.receptor_off(pos, mesecon.rules.pplate)
		elseif not was_on and nobjs > 0 then
			minetest.swap_node(pos, {name="mesecons_detector:object_detector_on"})
			mesecon.receptor_on(pos, mesecon.rules.pplate)
		end

		local channel = meta:get_string("digiline_channel")
		if (was_on or nobjs > 0) and channel ~= "" then
			digiline:receptor_send(pos, digiline.rules.default, channel, objs)
		end
	end,
})

-- Node detector
-- Detects the node in front of it

local node_detector_make_formspec = function (pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec", "size[9,2.5]" ..
		"field[0.3,  0;9,2;scanname;Name of node to scan for (empty for any):;${scanname}]"..
		"field[0.3,1.5;4,2;digiline_channel;Digiline Channel (optional):;${digiline_channel}]"..
		"button_exit[7,0.75;2,3;;Save]")
end

local node_detector_on_receive_fields = function(pos, formname, fields)
	if not fields.scanname or not fields.digiline_channel then return end;

	local meta = minetest.get_meta(pos)
	meta:set_string("scanname", fields.scanname)
	meta:set_string("digiline_channel", fields.digiline_channel)
	node_detector_make_formspec(pos)
end

-- returns true if player was found, false if not
local node_detector_scan = function (pos)
	if not pos then return end
	local node = minetest.get_node_or_nil(pos)
	if not node then return end
	local scandir = minetest.facedir_to_dir(node.param2)
	if not scandir then return end
	local frontpos = vector.subtract(pos, scandir)
	local frontnode = minetest.get_node(frontpos)
	local meta = minetest.get_meta(pos)
	return (frontnode.name == meta:get_string("scanname")) or
		(frontnode.name ~= "air" and frontnode.name ~= "ignore" and meta:get_string("scanname") == "")
end

-- set player name when receiving a digiline signal on a specific channel
local node_detector_digiline = {
	effector = {
		action = function (pos, node, channel, msg)
			local meta = minetest.get_meta(pos)
			local active_channel = meta:get_string("digiline_channel")
			if channel ~= active_channel then
				return
			end
			if msg == GET_COMMAND then
				local frontpos = vector.subtract(pos, minetest.facedir_to_dir(node.param2))
				local name = minetest.get_node(frontpos).name
				digiline:receptor_send(pos, digiline.rules.default, channel, name)
			elseif type(msg) == "string" then
				meta:set_string("scanname", msg)
				node_detector_make_formspec(pos)
			end
		end,
	},
	receptor = {}
}

minetest.register_node("mesecons_detector:node_detector_off", {
	tiles = {"default_steel_block.png", "default_steel_block.png", "default_steel_block.png", "default_steel_block.png", "default_steel_block.png", "jeija_node_detector_off.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = true,
	groups = {cracky=3},
	description="Node Detector",
	mesecons = {receptor = {
		state = mesecon.state.off
	}},
	on_construct = node_detector_make_formspec,
	on_receive_fields = node_detector_on_receive_fields,
	after_place_node = function (pos, placer)
		local placer_pos = placer:getpos()

		--correct for the player's height
		if placer:is_player() then placer_pos.y = placer_pos.y + 1.5 end

		--correct for 6d facedir
		if placer_pos then
			local dir = {
				x = pos.x - placer_pos.x,
				y = pos.y - placer_pos.y,
				z = pos.z - placer_pos.z
			}
			local node = minetest.get_node(pos)
			node.param2 = minetest.dir_to_facedir(dir, true)
			minetest.set_node(pos, node)
			minetest.log("action", "real (6d) facedir: " .. node.param2)
		end
	end,
	sounds = default.node_sound_stone_defaults(),
	digiline = node_detector_digiline
})

minetest.register_node("mesecons_detector:node_detector_on", {
	tiles = {"default_steel_block.png", "default_steel_block.png", "default_steel_block.png", "default_steel_block.png", "default_steel_block.png", "jeija_node_detector_on.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = true,
	groups = {cracky=3,not_in_creative_inventory=1},
	drop = 'mesecons_detector:node_detector_off',
	mesecons = {receptor = {
		state = mesecon.state.on
	}},
	on_construct = node_detector_make_formspec,
	on_receive_fields = node_detector_on_receive_fields,
	after_place_node = function (pos, placer)
		local placer_pos = placer:getpos()

		--correct for the player's height
		if placer:is_player() then placer_pos.y = placer_pos.y + 1.5 end

		--correct for 6d facedir
		if placer_pos then
			local dir = {
				x = pos.x - placer_pos.x,
				y = pos.y - placer_pos.y,
				z = pos.z - placer_pos.z
			}
			local node = minetest.get_node(pos)
			node.param2 = minetest.dir_to_facedir(dir, true)
			minetest.set_node(pos, node)
			minetest.log("action", "real (6d) facedir: " .. node.param2)
		end
	end,
	sounds = default.node_sound_stone_defaults(),
	digiline = node_detector_digiline
})

minetest.register_craft({
	output = 'mesecons_detector:node_detector_off',
	recipe = {
		{"default:steel_ingot", "group:mesecon_conductor_craftable", "default:steel_ingot"},
		{"default:steel_ingot", "mesecons_luacontroller:luacontroller0000", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	}
})

minetest.register_abm(
	{nodenames = {"mesecons_detector:node_detector_off"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node)
		if node_detector_scan(pos) then
			minetest.swap_node(pos, {name = "mesecons_detector:node_detector_on", param2 = node.param2})
			mesecon.receptor_on(pos)
		end
	end,
})

minetest.register_abm(
	{nodenames = {"mesecons_detector:node_detector_on"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node)
		if not node_detector_scan(pos) then
			minetest.swap_node(pos, {name = "mesecons_detector:node_detector_off", param2 = node.param2})
			mesecon.receptor_off(pos)
		end
	end,
})
