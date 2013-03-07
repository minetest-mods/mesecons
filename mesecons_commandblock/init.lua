minetest.register_chatcommand("say", {
	params = "<text>",
	description = "Say <text> as the server",
	privs = {server=true},
	func = function(name, param)
		minetest.chat_send_all(param)
	end
})

minetest.register_chatcommand("tell", {
	params = "<name> <text>",
	description = "Say <text> to <name> privately",
	func = function(name, param)
		local found, _, target, message = param:find("^([^%s]+)%s+(.*)$")
		if found == nil then
			minetest.chat_send_player(name, "Invalid usage: " .. param)
			return
		end
		minetest.chat_send_player(target, name .. " whispers: " .. message)
	end
})

local initialize_data = function(meta, player, command, param)
	meta:set_string("formspec",
		"invsize[9,6;]" ..
		"field[1,1;7.5,1;player;Player;" .. player .. "]" ..
		"button[1.3,2;2,1;nearest;Nearest]" ..
		"button[3.3,2;2,1;farthest;Farthest]" ..
		"button[5.3,2;2,1;random;Random]" ..
		"field[1,4;2,1;command;Command;" .. command .. "]" ..
		"field[3,4;5.5,1;param;Parameter;" .. param .. "]" ..
		"button_exit[3.3,5;2,1;submit;Submit]")
	local owner = meta:get_string("owner")
	if owner == "" then
		owner = "not owned"
	else
		owner = "owned by " .. owner
	end
	meta:set_string("infotext", "Command Block\n" ..
		"(" .. owner .. ")\n" ..
		"Command: /" .. command .. " " .. param)
end

local construct = function(pos)
	local meta = minetest.env:get_meta(pos)

	meta:set_string("player", "@nearest")
	meta:set_string("command", "time")
	meta:set_string("param", "7000")

	meta:set_string("owner", "")

	initialize_data(meta, "@nearest", "time", "7000")
end

local after_place = function(pos, placer)
	if placer then
		local meta = minetest.env:get_meta(pos)
		meta:set_string("owner", placer:get_player_name())
		initialize_data(meta, "@nearest", "time", "7000")
	end
end

local receive_fields = function(pos, formname, fields, sender)
	local meta = minetest.env:get_meta(pos)
	if fields.nearest then
		initialize_data(meta, "@nearest", fields.command, fields.param)
	elseif fields.farthest then
		initialize_data(meta, "@farthest", fields.command, fields.param)
	elseif fields.random then
		initialize_data(meta, "@random", fields.command, fields.param)
	else --fields.submit or pressed enter
		meta:set_string("player", fields.player)
		meta:set_string("command", fields.command)
		meta:set_string("param", fields.param)

		initialize_data(meta, fields.player, fields.command, fields.param)
	end
end

local resolve_player = function(name, pos)
	local get_distance = function(pos1, pos2)
		return math.sqrt((pos1.x - pos2.x) ^ 2 + (pos1.y - pos2.y) ^ 2 + (pos1.z - pos2.z) ^ 2)
	end

	if name == "@nearest" then
		local min_distance = math.huge
		for index, player in ipairs(minetest.get_connected_players()) do
			local distance = get_distance(pos, player:getpos())
			if distance < min_distance then
				min_distance = distance
				name = player:get_player_name()
			end
		end
	elseif name == "@farthest" then
		local max_distance = -1
		for index, player in ipairs(minetest.get_connected_players()) do
			local distance = get_distance(pos, player:getpos())
			if distance > max_distance then
				max_distance = distance
				name = player:get_player_name()
			end
		end
	elseif name == "@random" then
		local players = minetest.get_connected_players()
		local player = players[math.random(#players)]
		name = player:get_player_name()
	end
	return name
end

local commandblock_action_on = function(pos, node)
	if node.name ~= "mesecons_commandblock:commandblock_off" then
		return
	end

	mesecon:swap_node(pos, "mesecons_commandblock:commandblock_on")

	local meta = minetest.env:get_meta(pos)
	local command = minetest.chatcommands[meta:get_string("command")]
	if command == nil then
		return
	end
	local owner = meta:get_string("owner")
	if owner == "" then
		return
	end
	local has_privs, missing_privs = minetest.check_player_privs(owner, command.privs)
	if not has_privs then
		minetest.chat_send_player(owner, "You don't have permission to run this command (missing privileges: "..table.concat(missing_privs, ", ")..")")
		return
	end
	local player = resolve_player(meta:get_string("player"), pos)
	command.func(player, meta:get_string("param"))
end

local commandblock_action_off = function(pos, node)
	if node.name == "mesecons_commandblock:commandblock_on" then
		mesecon:swap_node(pos, "mesecons_commandblock:commandblock_off")
	end
end

minetest.register_node("mesecons_commandblock:commandblock_off", {
	description = "Command Block",
	tiles = {"jeija_commandblock_off.png"},
	inventory_image = minetest.inventorycube("jeija_commandblock_off.png"),
	groups = {cracky=2, mesecon_effector_off=1},
	on_construct = construct,
	after_place_node = after_place,
	on_receive_fields = receive_fields,
	can_dig = function(pos,player)
		local owner = minetest.env:get_meta(pos):get_string("owner")
		return owner == "" or owner == player:get_player_name()
	end,
	sounds = default.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_on = commandblock_action_on
	}}
})

minetest.register_node("mesecons_commandblock:commandblock_on", {
	tiles = {"jeija_commandblock_on.png"},
	groups = {cracky=2, mesecon_effector_on=1, not_in_creative_inventory=1},
	light_source = 10,
	drop = "mesecons_commandblock:commandblock_off",
	on_construct = construct,
	after_place_node = after_place,
	on_receive_fields = receive_fields,
	can_dig = function(pos,player)
		local owner = minetest.env:get_meta(pos):get_string("owner")
		return owner == "" or owner == player:get_player_name()
	end,
	sounds = default.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_off = commandblock_action_off
	}}
})
