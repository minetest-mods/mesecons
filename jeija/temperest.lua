--TEMPEREST-PLUG

minetest.register_node("jeija:mesecon_plug", {
	drawtype = "raillike",
	paramtype = "light",
	is_ground_content = true,
	tile_images = {"jeija_mesecon_plug.png"},
	inventory_image = "jeija_mesecon_plug.png",
	wield_image = "jeija_mesecon_plug.png",
	material = minetest.digprop_constanttime(0.1),
	walkable = false,
	selection_box = {
		type = "fixed",
	},
	description = "Plug",
})

local set_node_on = function(pos)
	local node = minetest.env:get_node(pos)
	if node.name=="jeija:mesecon_socket_off" then
		minetest.env:add_node(pos, {name="jeija:mesecon_socket_on"})
		nodeupdate(pos)
		mesecon:receptor_on(pos)
	elseif node.name=="jeija:mesecon_inverter_on" then
		minetest.env:add_node(pos, {name="jeija:mesecon_inverter_off"})
		nodeupdate(pos)
		mesecon:receptor_off(pos)
	end
end

local set_node_off = function(pos)
	node = minetest.env:get_node(pos)
	if node.name=="jeija:mesecon_socket_on" then
		minetest.env:add_node(pos, {name="jeija:mesecon_socket_off"})
		nodeupdate(pos)
		mesecon:receptor_off(pos)
	elseif node.name=="jeija:mesecon_inverter_off" then
		minetest.env:add_node(pos, {name="jeija:mesecon_inverter_on"})
		nodeupdate(pos)
		mesecon:receptor_on(pos)
	end
end

local plug_on = function(pos, node)
	if node.name=="jeija:mesecon_plug" then
		local lnode = minetest.env:get_node({x=pos.x-1, y=pos.y, z=pos.z}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_on({x=pos.x-2, y=pos.y, z=pos.z}) end
		
		local lnode = minetest.env:get_node({x=pos.x+1, y=pos.y, z=pos.z}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_on({x=pos.x+2, y=pos.y, z=pos.z}) end
		
		local lnode = minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z-1}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_on({x=pos.x, y=pos.y, z=pos.z-2}) end
		
		local lnode = minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z+1}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_on({x=pos.x, y=pos.y, z=pos.z+2}) end
	end
end

local plug_off = function(pos, node)
	if node.name=="jeija:mesecon_plug" then
		lnode = minetest.env:get_node({x=pos.x-1, y=pos.y, z=pos.z}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_off({x=pos.x-2, y=pos.y, z=pos.z}) end
		
		lnode = minetest.env:get_node({x=pos.x+1, y=pos.y, z=pos.z}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_off({x=pos.x+2, y=pos.y, z=pos.z}) end
		
		lnode = minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z-1}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_off({x=pos.x, y=pos.y, z=pos.z-2}) end
		
		lnode = minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z+1}) --a node between this node and the one two nodes away
		if lnode.name=="air" then set_node_off({x=pos.x, y=pos.y, z=pos.z+2}) end
	end
end

mesecon:register_on_signal_on(plug_on)
mesecon:register_on_signal_off(plug_off)

minetest.register_on_placenode(plug_off)
minetest.register_on_dignode(plug_off)

minetest.register_craft({
	output = 'node "jeija:mesecon_plug" 2',
	recipe = {
		{'', 'node "jeija:mesecon_off"', ''},
		{'node "jeija:mesecon_off"', 'craft "default:steel_ingot"', 'node "jeija:mesecon_off"'},
		{'', 'node "jeija:mesecon_off"', ''},
	}
})

--TEMPEREST-SOCKET

minetest.register_node("jeija:mesecon_socket_off", {
	description = "Socket",
	drawtype = "raillike",
	paramtype = "light",
	is_ground_content = true,
	tile_images = {"jeija_mesecon_socket_off.png"},
	inventory_image = "jeija_mesecon_socket_off.png",
	wield_image = "jeija_mesecon_socket_off.png",
	material = minetest.digprop_constanttime(0.1),
	walkable = false,
	selection_box = {
		type = "fixed",
	},
})

minetest.register_node("jeija:mesecon_socket_on", {
	drawtype = "raillike",
	paramtype = "light",
	is_ground_content = true,
	tile_images = {"jeija_mesecon_socket_on.png"},
	material = minetest.digprop_constanttime(0.1),
	walkable = false,
	selection_box = {
		type = "fixed",
	},
	drop='"jeija:mesecon_socket_off" 1',
})

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:mesecon_socket_on" then
			mesecon:receptor_off(pos)
		end
	end
)

mesecon:add_receptor_node("jeija:mesecon_socket_on")
mesecon:add_receptor_node_off("jeija:mesecon_socket_off")

minetest.register_craft({
	output = 'node "jeija:mesecon_socket_off" 2',
	recipe = {
		{'', 'craft "default:steel_ingot"', ''},
		{'craft "default:steel_ingot"', 'node "jeija:mesecon_off"', 'craft "default:steel_ingot"'},
		{'', 'craft "default:steel_ingot"', ''},
	}
})

--TEMPEREST-INVERTER

minetest.register_node("jeija:mesecon_inverter_off", {
	drawtype = "raillike",
	paramtype = "light",
	is_ground_content = true,
	tile_images = {"jeija_mesecon_inverter_off.png"},
	material = minetest.digprop_constanttime(0.1),
	walkable = false,
	selection_box = {
		type = "fixed",
	},
	drop='"jeija:mesecon_inverter_on" 1',
})

minetest.register_node("jeija:mesecon_inverter_on", {
	description = "Inverter",
	drawtype = "raillike",
	paramtype = "light",
	is_ground_content = true,
	tile_images = {"jeija_mesecon_inverter_on.png"},
	inventory_image = "jeija_mesecon_inverter_on.png",
	wield_image = "jeija_mesecon_inverter_on.png",
	material = minetest.digprop_constanttime(0.1),
	walkable = false,
	selection_box = {
		type = "fixed",
	},
})

minetest.register_on_placenode(function(pos, node)
	if node.name=="jeija:mesecon_inverter" then
		mesecon:receptor_on(pos)
	end
end
)

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:mesecon_inverter_on" then
			mesecon:receptor_off(pos)
		end
	end
)

mesecon:add_receptor_node("jeija:mesecon_inverter_on")
mesecon:add_receptor_node_off("jeija:mesecon_inverter_off")

minetest.register_craft({
	output = 'node "jeija:mesecon_inverter_on" 2',
	recipe = {
		{'node "jeija:mesecon_off"', 'craft "default:steel_ingot"', 'node "jeija:mesecon_off"'},
		{'craft "default:steel_ingot"', '', 'craft "default:steel_ingot"'},
		{'node "jeija:mesecon_off"', 'craft "default:steel_ingot"', 'node "jeija:mesecon_off"'},
	}
})