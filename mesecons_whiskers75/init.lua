--Whiskers75's code
--AND block

-- Make the block:

minetest.register_node("mesecons_whiskers75:andblock", {
	description = "AND block",
	drawtype = "raillike",
	tile_images = {"whiskers75andblock.png"},
	inventory_image = {"whiskers75andblock.png"},
	sunlight_propagates = true,
	paramtype = 'light',
	walkable = true,
	groups = {dig_immediate=2},
	material = minetest.digprop_constanttime(1.0),
})

minetest.register_on_punchnode(function(pos, node, puncher)
	if node.name=="mesecons_whiskers75:andblock" then
		anode = minetest.env:get_node({x=pos.x-1, y=pos.y, z=pos.z})
		bnode = minetest.env:get_node({x=pos.x+1, y=pos.y, z=pos.z}) 
		if anode.name=="mesecons:mesecon_on" and bnode.name=="mesecons:mesecon_on" then mesecon:receptor_on({x=pos.x, y=pos.y+1, z=pos.z}) end
	end
end)

minetest.register_on_punchnode(function(pos, node, puncher)
	if node.name=="mesecons_whiskers75:andblock" then
		anode = minetest.env:get_node({x=pos.x-1, y=pos.y, z=pos.z})
		bnode = minetest.env:get_node({x=pos.x+1, y=pos.y, z=pos.z}) 
		if anode.name=="mesecons:mesecon_off" then mesecon:receptor_off({x=pos.x, y=pos.y+1, z=pos.z}) end
		if bnode.name=="mesecons:mesecon_off" then mesecon:receptor_off({x=pos.x, y=pos.y+1, z=pos.z}) end
	end
end)

function update(pos, node)
	if node.name=="mesecons_whiskers75:andblock" then
		anode = minetest.env:get_node({x=pos.x-1, y=pos.y, z=pos.z})
		bnode = minetest.env:get_node({x=pos.x+1, y=pos.y, z=pos.z}) 
		if anode.name=="mesecons:mesecon_off" then mesecon:receptor_off({x=pos.x, y=pos.y+1, z=pos.z}) end
		if bnode.name=="mesecons:mesecon_off" then mesecon:receptor_off({x=pos.x, y=pos.y+1, z=pos.z}) end
	end

	if node.name=="mesecons_whiskers75:andblock" then
		anode = minetest.env:get_node({x=pos.x-1, y=pos.y, z=pos.z})
		bnode = minetest.env:get_node({x=pos.x+1, y=pos.y, z=pos.z}) 
		if anode.name=="mesecons:mesecon_on" and bnode.name=="mesecons:mesecon_on" then mesecon:receptor_on({x=pos.x, y=pos.y+1, z=pos.z}) end
	end
end


minetest.register_craft({
	output = '"mesecons_whiskers75:andblock" 2',
	recipe = {
		{'"default:wood"', '', '"default:dirt"'},
	}
})

mesecon:register_on_signal_on(update)
mesecon:register_on_signal_off(update)

