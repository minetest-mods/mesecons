--COMMON WIRELESS FUNCTIONS

function mesecon:read_wlre_from_file()
	print "[MESEcons] Reading Mesecon Data..."
	mesecon_file=io.open(minetest.get_modpath("jeija").."/mesecon_data", "r")
	if mesecon_file==nil then return end
	local row=mesecon_file:read()
	local i=1
	while row~=nil do
		mesecon.wireless_receivers[i]={}
		mesecon.wireless_receivers[i].pos={}
		mesecon.wireless_receivers[i].pos.x=tonumber(mesecon_file:read())
		mesecon.wireless_receivers[i].pos.y=tonumber(mesecon_file:read())
		mesecon.wireless_receivers[i].pos.z=tonumber(mesecon_file:read())
		mesecon.wireless_receivers[i].channel=mesecon_file:read()
		mesecon.wireless_receivers[i].requested_state=tonumber(mesecon_file:read())
		mesecon.wireless_receivers[i].inverting=tonumber(mesecon_file:read())
		i=i+1
		row=mesecon_file:read()
	end
	mesecon_file:close()	
	print "[MESEcons] Finished Reading Mesecon Data..."
end


function mesecon:register_wireless_receiver(pos, inverting)
	local i	= 1	
	repeat
		if mesecon.wireless_receivers[i]==nil then break end
		i=i+1
	until false


	local node_under_pos={}
	node_under_pos.x=pos.x
	node_under_pos.y=pos.y
	node_under_pos.z=pos.z

	node_under_pos.y=node_under_pos.y-1
	local node_under=minetest.env:get_node(node_under_pos)
	mesecon.wireless_receivers[i]={}
	mesecon.wireless_receivers[i].pos={}
	mesecon.wireless_receivers[i].pos.x=pos.x
	mesecon.wireless_receivers[i].pos.y=pos.y
	mesecon.wireless_receivers[i].pos.z=pos.z
	mesecon.wireless_receivers[i].channel=node_under.name
	mesecon.wireless_receivers[i].requested_state=0
	mesecon.wireless_receivers[i].inverting=inverting
end

function mesecon:remove_wireless_receiver(pos)
	local i = 1
	while mesecon.wireless_receivers[i]~=nil do
		if mesecon.wireless_receivers[i].pos.x==pos.x and
		   mesecon.wireless_receivers[i].pos.y==pos.y and
		   mesecon.wireless_receivers[i].pos.z==pos.z then
			mesecon.wireless_receivers[i]=nil
			break
		end
		i=i+1
	end
end

function mesecon:set_wlre_channel(pos, channel)
	--local i = 1
	--while mesecon.wireless_receivers[i]~=nil do
	--	if tonumber(mesecon.wireless_receivers[i].pos.x)==tonumber(pos.x) and
	--	   tonumber(mesecon.wireless_receivers[i].pos.y)==tonumber(pos.y) and
	--	   tonumber(mesecon.wireless_receivers[i].pos.z)==tonumber(pos.z) then
	--		mesecon.wireless_receivers[i].channel=channel
	--		break
	--	end
	--	i=i+1
	--end
	local wlre=mesecon:get_wlre(pos)
	if wlre~=nil then 
		wlre.channel=channel
	end
end

function mesecon:get_wlre(pos)
	local i=1
	while mesecon.wireless_receivers[i]~=nil do
		if mesecon.wireless_receivers[i].pos.x==pos.x and
		   mesecon.wireless_receivers[i].pos.y==pos.y and
		   mesecon.wireless_receivers[i].pos.z==pos.z then
			return mesecon.wireless_receivers[i]
		end
		i=i+1
	end
end

minetest.register_on_placenode(function(pos, newnode, placer)
	pos.y=pos.y+1
	if minetest.env:get_node(pos).name == "jeija:wireless_receiver_off" or
	   minetest.env:get_node(pos).name == "jeija:wireless_receiver_on"  or
	   minetest.env:get_node(pos).name == "jeija:wireless_inverter_off" or
	   minetest.env:get_node(pos).name == "jeija:wireless_inverter_on" then
		mesecon:set_wlre_channel(pos, newnode.name)
	end
end)

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		local channel
		pos.y=pos.y+1
		if minetest.env:get_node(pos).name == "jeija:wireless_receiver_on" or
		   minetest.env:get_node(pos).name == "jeija:wireless_receiver_off" or
		   minetest.env:get_node(pos).name == "jeija:wireless_inverter_on" or
		   minetest.env:get_node(pos).name == "jeija:wireless_inverter_off" then
			mesecon:set_wlre_channel(pos, "air")
		end	
	end
)

minetest.register_abm(
	{nodenames = {"jeija:wireless_receiver_on", "jeija:wireless_receiver_off",
		      "jeija:wireless_inverter_on", "jeija:wireless_inverter_off"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local wlre=mesecon:get_wlre(pos)
		if (wlre==nil) then return end
		
		if node.name=="jeija:wireless_receiver_on" and wlre.requested_state==0  then
			minetest.env:add_node(pos, {name="jeija:wireless_receiver_off"})
			mesecon:receptor_off(pos)
		end
		if node.name=="jeija:wireless_receiver_off" and wlre.requested_state==1  then
			minetest.env:add_node(pos, {name="jeija:wireless_receiver_on"})
			mesecon:receptor_on(pos)
		end
		if node.name=="jeija:wireless_inverter_off" and wlre.requested_state==0 and wlre.inverting==1 then
			minetest.env:add_node(pos, {name="jeija:wireless_inverter_on"})
			mesecon:receptor_on(pos)
		end
		if node.name=="jeija:wireless_inverter_on" and wlre.requested_state==1 and wlre.inverting==1 then
			minetest.env:add_node(pos, {name="jeija:wireless_inverter_off"})
			mesecon:receptor_off(pos)
		end
	end,
})

--WIRELESS RECEIVER

minetest.register_node("jeija:wireless_receiver_off", {
	tile_images = {"jeija_wireless_receiver_tb_off.png", "jeija_wireless_receiver_tb_off.png", "jeija_wireless_receiver_off.png", "jeija_wireless_receiver_off.png", "jeija_wireless_receiver_off.png", "jeija_wireless_receiver_off.png"},
	inventory_image = minetest.inventorycube("jeija_wireless_receiver_off.png"),
	material = minetest.digprop_constanttime(0.8),
    	description="Wireless Receiver",
})

minetest.register_node("jeija:wireless_receiver_on", {
	tile_images = {"jeija_wireless_receiver_tb_on.png", "jeija_wireless_receiver_tb_on.png", "jeija_wireless_receiver_on.png", "jeija_wireless_receiver_on.png", "jeija_wireless_receiver_on.png", "jeija_wireless_receiver_on.png"},
	inventory_image = minetest.inventorycube("jeija_wireless_receiver_on.png"),
	material = minetest.digprop_constanttime(0.8),
	dug_item = 'node "jeija:wireless_receiver_off" 1',
    	description="Wireless Receiver",
})

minetest.register_craft({
	output = 'node "jeija:wireless_receiver_off" 2',
	recipe = {
		{'', 'node "jeija:mesecon_off"', ''},
		{'', 'node "jeija:mesecon_off"', ''},
		{'', 'craft "jeija:ic"', ''},
	}
})

minetest.register_on_placenode(function(pos, newnode, placer)
	if newnode.name == "jeija:wireless_receiver_off" then
		mesecon:register_wireless_receiver(pos, 0)
	end
end)

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:wireless_receiver_on" then
			mesecon:remove_wireless_receiver(pos)
			mesecon:receptor_off(pos)
		end	
		if oldnode.name == "jeija:wireless_receiver_off" then
			mesecon:remove_wireless_receiver(pos)		
		end
	end
)

minetest.register_abm( -- SAVE WIRELESS RECEIVERS TO FILE
	{nodenames = {"jeija:wireless_receiver_off", "jeija:wireless_receiver_on", "jeija:wireless_inverter_on", "jeija:wireless_inverter_off"},
	interval = 10,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local mesecon_file = io.open(minetest.get_modpath("jeija").."/mesecon_data", "w")
		local i=1
		while mesecon.wireless_receivers[i]~=nil do
			mesecon_file:write("NEXT\n")
			mesecon_file:write(mesecon.wireless_receivers[i].pos.x.."\n")
			mesecon_file:write(mesecon.wireless_receivers[i].pos.y.."\n")
			mesecon_file:write(mesecon.wireless_receivers[i].pos.z.."\n")
			mesecon_file:write(mesecon.wireless_receivers[i].channel.."\n")
			mesecon_file:write(mesecon.wireless_receivers[i].requested_state.."\n")
			mesecon_file:write(mesecon.wireless_receivers[i].inverting.."\n")
			i=i+1
		end
		mesecon_file:close()
	end, 
})

mesecon:add_receptor_node("jeija:wireless_receiver_on")
mesecon:add_receptor_node_off("jeija:wireless_receiver_off")

-- WIRELESS INVERTER OFF/ON BELONGS TO THE OUTPUT STATE (ON=INPUT OFF)

minetest.register_node("jeija:wireless_inverter_off", {
	tile_images = {"jeija_wireless_inverter_tb.png", "jeija_wireless_inverter_tb.png", "jeija_wireless_inverter_off.png", "jeija_wireless_inverter_off.png", "jeija_wireless_inverter_off.png", "jeija_wireless_inverter_off.png"},
	inventory_image = minetest.inventorycube("jeija_wireless_inverter_off.png"),
	material = minetest.digprop_constanttime(0.8),
	dug_item = 'node "jeija:wireless_inverter_on" 1',
    	description="Wireless Inverter",
})

minetest.register_node("jeija:wireless_inverter_on", {
	tile_images = {"jeija_wireless_inverter_tb.png", "jeija_wireless_inverter_tb.png", "jeija_wireless_inverter_on.png", "jeija_wireless_inverter_on.png", "jeija_wireless_inverter_on.png", "jeija_wireless_inverter_on.png"},
	inventory_image = minetest.inventorycube("jeija_wireless_inverter_on.png"),
	material = minetest.digprop_constanttime(0.8),
    	description="Wireless Inverter",
})

minetest.register_craft({
	output = 'node "jeija:wireless_inverter_off" 2',
	recipe = {
		{'', 'craft "default:steel_ingot"', ''},
		{'craft "jeija:ic"', 'node "jeija:mesecon_off"', 'craft "jeija:ic"'},
		{'', 'node "jeija:mesecon_off"', ''},
	}
})

minetest.register_on_placenode(function(pos, newnode, placer)
	if newnode.name == "jeija:wireless_inverter_on" then
		mesecon:register_wireless_receiver(pos, 1)
		mesecon:receptor_on(pos)
	end
end)

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:wireless_inverter_on" then
			mesecon:remove_wireless_receiver(pos)
			mesecon:receptor_off(pos)
		end	
		if oldnode.name == "jeija:wireless_inverter_off" then
			mesecon:remove_wireless_receiver(pos)		
		end
	end
)

mesecon:add_receptor_node("jeija:wireless_inverter_on")
mesecon:add_receptor_node_off("jeija:wireless_inverter_off")

-- WIRELESS TRANSMITTER

function mesecon:wireless_transmit(channel, senderstate)
	local i = 1
	while mesecon.wireless_receivers[i]~=nil do
		if mesecon.wireless_receivers[i].channel==channel then
			if senderstate==1 then
				mesecon.wireless_receivers[i].requested_state=1
			elseif senderstate==0 then
				mesecon.wireless_receivers[i].requested_state=0
			end
		end
		i=i+1
	end
end

minetest.register_node("jeija:wireless_transmitter_on", {
	tile_images = {"jeija_wireless_transmitter_tb.png", "jeija_wireless_transmitter_tb.png", "jeija_wireless_transmitter_on.png", "jeija_wireless_transmitter_on.png", "jeija_wireless_transmitter_on.png", "jeija_wireless_transmitter_on.png"},
	inventory_image = minetest.inventorycube("jeija_wireless_transmitter_on.png"),
	material = minetest.digprop_constanttime(0.8),
	dug_item = 'node "jeija:wireless_transmitter_off" 1',
    	description="Wireless Transmitter",
})

minetest.register_node("jeija:wireless_transmitter_off", {
	tile_images = {"jeija_wireless_transmitter_tb.png", "jeija_wireless_transmitter_tb.png", "jeija_wireless_transmitter_off.png", "jeija_wireless_transmitter_off.png", "jeija_wireless_transmitter_off.png", "jeija_wireless_transmitter_off.png"},
	inventory_image = minetest.inventorycube("jeija_wireless_transmitter_off.png"),
	material = minetest.digprop_constanttime(0.8),
    	description="Wireless Transmitter",
})

minetest.register_craft({
	output = 'node "jeija:wireless_transmitter_off" 2',
	recipe = {
		{'craft "default:steel_ingot"', 'node "jeija:mesecon_off"', 'craft "default:steel_ingot"'},
		{'', 'node "jeija:mesecon_off"', ''},
		{'', 'craft "jeija:ic"', ''},
	}
})

mesecon:register_on_signal_on(function(pos, node)
	if node.name=="jeija:wireless_transmitter_off" then
		minetest.env:add_node(pos, {name="jeija:wireless_transmitter_on"})
		local node_under_pos=pos
		node_under_pos.y=node_under_pos.y-1
		local node_under=minetest.env:get_node(node_under_pos)
		mesecon:wireless_transmit(node_under.name, 1)
	end
end)

mesecon:register_on_signal_off(function(pos, node)
	if node.name=="jeija:wireless_transmitter_on" then
		minetest.env:add_node(pos, {name="jeija:wireless_transmitter_off"})
		local node_under_pos=pos
		node_under_pos.y=node_under_pos.y-1
		local node_under=minetest.env:get_node(node_under_pos)
		mesecon:wireless_transmit(node_under.name, 0)
	end
end)
