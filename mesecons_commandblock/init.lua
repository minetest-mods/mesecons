minetest.register_chatcommand("say", {
	params = "<text>",
	description = "Say <text> as the server",
	privs = {server=true},
	func = function(name, param)
		minetest.chat_send_all(name .. ": " .. param)
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
		if not minetest.get_player_by_name(target) then
			minetest.chat_send_player(name, "Invalid target: " .. target)
		end
		minetest.chat_send_player(target, name .. " whispers: " .. message, false)
	end
})

minetest.register_chatcommand("hp", {
	params = "<name> <value>",
	description = "Set health of <name> to <value> hitpoints",
	privs = {ban=true},
	func = function(name, param)
		local found, _, target, value = param:find("^([^%s]+)%s+(%d+)$")
		if found == nil then
			minetest.chat_send_player(name, "Invalid usage: " .. param)
			return
		end
		local player = minetest.get_player_by_name(target)
		if player then
			player:set_hp(value)
		else
			minetest.chat_send_player(name, "Invalid target: " .. target)
		end
	end
})

local function initialize_data(meta)
	local command = meta:get_string("command")
	local param = meta:get_string("param")
	meta:set_string("formspec",
		"invsize[9,4;]" ..
		"field[1,1;2,1;command;Command;" .. command .. "]" ..
		"field[3,1;5.5,1;param;Parameter;" .. param .. "]" ..
		"label[3,1.5;@nearest, @farthest, and @random are replaced by the respective player names]" ..
		"button_exit[3.3,3;2,1;submit;Submit]")
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

local function construct(pos)
	local meta = minetest.get_meta(pos)

	meta:set_string("command", "time")
	meta:set_string("param", "7000")

	meta:set_string("owner", "")

	initialize_data(meta)
end

local function after_place(pos, placer)
	if placer then
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name())
		initialize_data(meta)
	end
end

local function receive_fields(pos, formname, fields, sender)
	if fields.quit then
		return
	end
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	if owner ~= "" and sender:get_player_name() ~= owner then
		return
	end
	meta:set_string("command", fields.command)
	meta:set_string("param", fields.param)

	initialize_data(meta)
end

local function resolve_param(param, pos)
	local nearest, farthest = nil, nil
	local min_distance, max_distance = math.huge, -1
	local players = minetest.get_connected_players()
	for index, player in pairs(players) do
		local distance = vector.distance(pos, player:getpos())
		if distance < min_distance then
			min_distance = distance
			nearest = player:get_player_name()
		end
		if distance > max_distance then
			max_distance = distance
			farthest = player:get_player_name()
		end
	end
	local random = players[math.random(#players)]:get_player_name()
	param = param:gsub("@nearest", nearest)
	param = param:gsub("@farthest", farthest)
	param = param:gsub("@random", random)
	return param
end

local function commandblock_action_on(pos, node)
	if node.name ~= "mesecons_commandblock:commandblock_off" then
		return
	end

	minetest.swap_node(pos, {name = "mesecons_commandblock:commandblock_on"})

	local meta = minetest.get_meta(pos)
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
		minetest.chat_send_player(owner, "You don't have permission "
				.."to run this command (missing privileges: "
				..table.concat(missing_privs, ", ")..")")
		return
	end
	command.func(owner, resolve_param(meta:get_string("param"), pos))
end

local function commandblock_action_off(pos, node)
	if node.name == "mesecons_commandblock:commandblock_on" then
		minetest.swap_node(pos, {name = "mesecons_commandblock:commandblock_off"})
	end
end

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	return owner == "" or owner == player:get_player_name()
end

minetest.register_node("mesecons_commandblock:commandblock_off", {
	description = "Command Block",
	tiles = {"jeija_commandblock_off.png"},
	inventory_image = minetest.inventorycube("jeija_commandblock_off.png"),
	groups = {cracky=2, mesecon_effector_off=1},
	on_construct = construct,
	after_place_node = after_place,
	on_receive_fields = receive_fields,
	can_dig = can_dig,
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
	can_dig = can_dig,
	sounds = default.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_off = commandblock_action_off
	}}
})
