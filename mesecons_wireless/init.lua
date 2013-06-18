
local wireless_filename=minetest.get_worldpath() .. "/wireless"

local function read_file()
	local f = io.open(wireless_filename, "r")
	if f==nil then return {} end
    	local t = f:read("*all")
    	f:close()
	if t=="" or t==nil then return {} end
	return minetest.deserialize(t)
end

local function write_file(tbl)
	local f = io.open(wireless_filename, "w")
    	f:write(minetest.serialize(tbl))
    	f:close()
end

local function add_wireless_receiver(pos,channel)
	local tbl=read_file()
	for _,val in ipairs(tbl) do
		if val.x==pos.x and val.y==pos.y and val.z==pos.z then
			return
		end
	end
	table.insert(tbl,{x=pos.x,y=pos.y,z=pos.z,channel=channel})
	write_file(tbl)
end

local function remove_wireless_receiver(pos)
	local tbl=read_file()
	local newtbl={}
	for _,val in ipairs(tbl) do
		if val.x~=pos.x or val.y~=pos.y or val.z~=pos.z then
			table.insert(newtbl,val)
		end
	end
	write_file(newtbl)
end

local function get_wireless_receivers(channel)
	local tbl=read_file()
	local newtbl={}
	local changed=false
	for _,val in ipairs(tbl) do
		local node = minetest.env:get_node(val)
		local meta = minetest.env:get_meta(val)
		if node.name~="ignore"  and val.channel~=meta:get_string("channel") then
			val.channel=meta:get_string("channel")
			changed=true
		end
		if val.channel==channel and node.name~="ignore" then
			table.insert(newtbl,val)
		end
	end
	if changed then write_file(tbl) end
	return newtbl
end

minetest.register_node("mesecons_wireless:emitter", {
	description = "Wireless emitter",
	paramtype = "light",
	drawtype = "normal",
	tiles = {"mesecons_wireless_emitter.png"},
	walkable = true,
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("channel","")
		meta:set_string("formspec","size[9,1;]field[0,0.5;9,1;channel;Channel:;${channel}]")
	end,
	on_receive_fields = function(pos,formname,fields,sender)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("channel",fields.channel)
	end,
	groups = {dig_immediate=2},
	sounds = default.node_sound_stone_defaults(),
	mesecons =
	{
		effector =
		{
			action_on = function(pos)
				local meta = minetest.env:get_meta(pos)
				local channel = meta:get_string("channel")
				local w = get_wireless_receivers(channel)
				for _,i in ipairs(w) do
					mesecon:receptor_on(i)
					mesecon:swap_node(i, "mesecons_wireless:receiver_on")
				end
			end,
			action_off = function(pos)
				local meta = minetest.env:get_meta(pos)
				local channel = meta:get_string("channel")
				local w = get_wireless_receivers(channel)
				for _,i in ipairs(w) do
					mesecon:receptor_off(i)
					mesecon:swap_node(i, "mesecons_wireless:receiver")
				end
			end,
		}
	}
})

minetest.register_node("mesecons_wireless:receiver", {
	description = "Wireless receiver",
	paramtype = "light",
	drawtype = "normal",
	tiles = {"mesecons_wireless_receiver.png"},
	walkable = true,
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("channel","")
		meta:set_string("formspec","size[9,1;]field[0,0.5;9,1;channel;Channel:;${channel}]")
		add_wireless_receiver(pos,"")
	end,
	on_receive_fields = function(pos,formname,fields,sender)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("channel",fields.channel)
		remove_wireless_receiver(pos)
		add_wireless_receiver(pos,fields.channel)
	end,
	on_destruct = function(pos)
		remove_wireless_receiver(pos)
	end,
	groups = {dig_immediate=2},
	sounds = default.node_sound_stone_defaults(),
	mesecons =
	{
		receptor =
		{
			state = "off",
		},
	}
})

minetest.register_node("mesecons_wireless:receiver_on", {
	description = "Wireless receiver on (you hacker you)",
	paramtype = "light",
	drawtype = "normal",
	tiles = {"mesecons_wireless_receiver_on.png"},
	walkable = true,
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("channel","")
		meta:set_string("formspec","size[9,1;]field[0,0.5;9,1;channel;Channel:;${channel}]")
		add_wireless_receiver(pos,"")
	end,
	on_receive_fields = function(pos,formname,fields,sender)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("channel",fields.channel)
		remove_wireless_receiver(pos)
		add_wireless_receiver(pos,fields.channel)
	end,
	on_destruct = function(pos)
		remove_wireless_receiver(pos)
	end,
	groups = {dig_immediate=2, not_in_creative_inventory=1},
	drop = "mesecons_wireless:receiver",
	sounds = default.node_sound_stone_defaults(),
	mesecons =
	{
		receptor =
		{
			state = "on",
		},
	}
})

