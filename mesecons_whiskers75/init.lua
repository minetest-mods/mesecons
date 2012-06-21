--Whiskers75's code
--AND block
local update = function(pos)
	local node = minetest.env:get_node(pos)
	if node.name=="mesecons_whiskers75:andblock" then
		lnode = minetest.env:get_node({x=pos.x-1, y=pos.y, z=pos.z})
		if lnode.name=="mesecons:mesecon_on" then set_node_on({x=pos.x, y=pos.y+1, z=pos.z}) end
		lnode = minetest.env:get_node({x=pos.x+1, y=pos.y, z=pos.z})
		if lnode.name=="mesecons:mesecon_on" then set_node_on({x=pos.x, y=pos.y+1, z=pos.z}) end

-- This SHOULD detect mesecons on x+ or -1 and turn a node y+1 on...