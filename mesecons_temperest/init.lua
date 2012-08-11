--TEMPEREST-PLUG

local set_node_on
local set_node_off

if ENABLE_TEMPEREST then
	set_node_on = function(pos)
		local node = minetest.env:get_node(pos)
		if node.name=="mesecons_temperest:mesecon_socket_off" then
			minetest.env:add_node(pos, {name="mesecons_temperest:mesecon_socket_on"})
			nodeupdate(pos)
			mesecon:receptor_on(pos)
		elseif node.name=="mesecons_temperest:mesecon_inverter_on" then
			minetest.env:add_node(pos, {name="mesecons_temperest:mesecon_inverter_off"})
			nodeupdate(pos)
			mesecon:receptor_off(pos)
		end
	end
	
	set_node_off = function(pos)
		node = minetest.env:get_node(pos)
		if node.name=="mesecons_temperest:mesecon_socket_on" then
			minetest.env:add_node(pos, {name="mesecons_temperest:mesecon_socket_off"})
			nodeupdate(pos)
			mesecon:receptor_off(pos)
		elseif node.name=="mesecons_temperest:mesecon_inverter_off" then
			minetest.env:add_node(pos, {name="mesecons_temperest:mesecon_inverter_on"})
			nodeupdate(pos)
			mesecon:receptor_on(pos)
		end
	end
else
	set_node_on = function(pos)
		local node = minetest.env:get_node(pos)
		if node.name=="mesecons_temperest:mesecon_socket_off" then
			minetest.env:add_node(pos, {name="mesecons_temperest:mesecon_socket_on"})
			nodeupdate(pos)
			mesecon:receptor_on(pos)
		end
	end
	
	set_node_off = function(pos)
		node = minetest.env:get_node(pos)
		if node.name=="mesecons_temperest:mesecon_socket_on" then
			minetest.env:add_node(pos, {name="mesecons_temperest:mesecon_socket_off"})
			nodeupdate(pos)
			mesecon:receptor_off(pos)
		end
	end
end

local plug_on = function(pos)
	local node = minetest.env:get_node(pos)
	if node.name=="mesecons_temperest:mesecon_plug" then
		local lnode = minetest.env:get_node({x=pos.x-1, y=pos.y, z=pos.z}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_on({x=pos.x-2, y=pos.y, z=pos.z}) end
		
		local lnode = minetest.env:get_node({x=pos.x+1, y=pos.y, z=pos.z}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_on({x=pos.x+2, y=pos.y, z=pos.z}) end
		
		lnode = minetest.env:get_node({x=pos.x, y=pos.y-1, z=pos.z}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_on({x=pos.x, y=pos.y-2, z=pos.z}) end
		
		lnode = minetest.env:get_node({x=pos.x, y=pos.y+1, z=pos.z}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_on({x=pos.x, y=pos.y+2, z=pos.z}) end
		
		local lnode = minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z-1}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_on({x=pos.x, y=pos.y, z=pos.z-2}) end
		
		local lnode = minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z+1}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_on({x=pos.x, y=pos.y, z=pos.z+2}) end
	end
end

local plug_off = function(pos)
	local node = minetest.env:get_node(pos)
	if node.name=="mesecons_temperest:mesecon_plug" then
		lnode = minetest.env:get_node({x=pos.x-1, y=pos.y, z=pos.z}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_off({x=pos.x-2, y=pos.y, z=pos.z}) end
		
		lnode = minetest.env:get_node({x=pos.x+1, y=pos.y, z=pos.z}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_off({x=pos.x+2, y=pos.y, z=pos.z}) end
		
		lnode = minetest.env:get_node({x=pos.x, y=pos.y-1, z=pos.z}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_off({x=pos.x, y=pos.y-2, z=pos.z}) end
		
		lnode = minetest.env:get_node({x=pos.x, y=pos.y+1, z=pos.z}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_off({x=pos.x, y=pos.y+2, z=pos.z}) end
		
		lnode = minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z-1}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_off({x=pos.x, y=pos.y, z=pos.z-2}) end
		
		lnode = minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z+1}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_off({x=pos.x, y=pos.y, z=pos.z+2}) end
	end
end

mesecon:register_on_signal_on(plug_on)
mesecon:register_on_signal_off(plug_off)

minetest.register_node("mesecons_temperest:mesecon_plug", {
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = true,
	tile_images = {"jeija_mesecon_plug.png"},
	inventory_image = "jeija_mesecon_plug.png",
	wield_image = "jeija_mesecon_plug.png",
	groups = {dig_immediate=2, mesecon = 2},
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
	},
	description = "Plug",
	after_place_node = plug_off,
	after_dig_node = plug_off
})

minetest.register_craft({
	output = '"mesecons_temperest:mesecon_plug" 2',
	recipe = {
		{'', '"mesecons:mesecon_off"', ''},
		{'"mesecons:mesecon_off"', '"default:steel_ingot"', '"mesecons:mesecon_off"'},
		{'', '"mesecons:mesecon_off"', ''},
	}
})

--TEMPEREST-SOCKET

minetest.register_node("mesecons_temperest:mesecon_socket_off", {
	description = "Socket",
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = true,
	tile_images = {"jeija_mesecon_socket_off.png"},
	inventory_image = "jeija_mesecon_socket_off.png",
	wield_image = "jeija_mesecon_socket_off.png",
	groups = {dig_immediate=2, mesecon = 2},
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
	},
})

minetest.register_node("mesecons_temperest:mesecon_socket_on", {
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = true,
	tile_images = {"jeija_mesecon_socket_on.png"},
	groups = {dig_immediate=2,not_in_creative_inventory=1, mesecon = 2},
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
	},
	drop='"mesecons_temperest:mesecon_socket_off" 1',
	after_dig_node = function(pos)
		mesecon:receptor_off(pos)
	end
})

mesecon:add_receptor_node("mesecons_temperest:mesecon_socket_on")
mesecon:add_receptor_node_off("mesecons_temperest:mesecon_socket_off")

minetest.register_craft({
	output = '"mesecons_temperest:mesecon_socket_off" 2',
	recipe = {
		{'', '"default:steel_ingot"', ''},
		{'"default:steel_ingot"', '"mesecons_temperest:mesecon_off"', '"default:steel_ingot"'},
		{'', '"default:steel_ingot"', ''},
	}
})

--TEMPEREST-INVERTER
if ENABLE_TEMPEREST then
	minetest.register_node("mesecons_temperest:mesecon_inverter_off", {
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = true,
		tile_images = {"jeija_mesecon_inverter_off.png"},
		groups = {dig_immediate=2,not_in_creative_inventory=1, mesecon = 2},
		walkable = false,
		selection_box = {
			type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
		},
		node_box = {
			type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
		},
		drop='"mesecons_temperest:mesecon_inverter_on" 1',
	})

	minetest.register_node("mesecons_temperest:mesecon_inverter_on", {
		description = "Inverter",
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = true,
		tile_images = {"jeija_mesecon_inverter_on.png"},
		inventory_image = "jeija_mesecon_inverter_on.png",
		wield_image = "jeija_mesecon_inverter_on.png",
		groups = {dig_immediate=2, mesecon = 2},
		walkable = false,
		selection_box = {
			type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
		},
		node_box = {
			type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
		},
		after_place_node = function(pos)
			mesecon:receptor_on(pos)
		end,
		after_dig_node = function(pos)
			mesecon:receptor_off(pos)
		end
	})

	mesecon:add_receptor_node("mesecons_temperest:mesecon_inverter_on")
	mesecon:add_receptor_node_off("mesecons_temperest:mesecon_inverter_off")

	minetest.register_craft({
		output = '"mesecons_temperest:mesecon_inverter_on" 2',
		recipe = {
			{'"mesecons_temperest:mesecon_off"', '"default:steel_ingot"', '"mesecons:mesecon_off"'},
			{'"default:steel_ingot"', '', '"default:steel_ingot"'},
			{'"mesecons:mesecon_off"', '"default:steel_ingot"', '"mesecons:mesecon_off"'},
		}
	})
end
