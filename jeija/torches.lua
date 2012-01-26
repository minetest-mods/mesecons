--MESECON TORCHES

minetest.register_craft({
    output = '"jeija:mesecon_torch_on" 4',
    recipe = {
        {'"jeija:mesecon_off"'},
        {'craft "default:stick"'},
    }
})

minetest.register_node("jeija:mesecon_torch_off", {
    drawtype = "torchlike",
    tile_images = {"jeija_torches_off.png", "jeija_torches_off_ceiling.png", "jeija_torches_off_side.png"},
    inventory_image = "jeija_torches_off.png",
    sunlight_propagates = true,
    walkable = false,
    wall_mounted = true,
    material = minetest.digprop_constanttime(0.5),
    drop = '"jeija:mesecon_torch_on" 1',
})

minetest.register_node("jeija:mesecon_torch_on", {
    drawtype = "torchlike",
    tile_images = {"jeija_torches_on.png", "jeija_torches_on_ceiling.png", "jeija_torches_on_side.png"},
    inventory_image = "jeija_torches_on.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    wall_mounted = true,
    material = minetest.digprop_constanttime(0.5),
    light_source = LIGHT_MAX-5,
})

--[[minetest.register_on_placenode(function(pos, newnode, placer)
	if (newnode.name=="jeija:mesecon_torch_off" or newnode.name=="jeija:mesecon_torch_on")
	and (newnode.param2==8 or newnode.param2==4) then
		minetest.env:remove_node(pos)
		--minetest.env:add_item(pos, "craft 'jeija:mesecon_torch_on' 1")
	end
end)]]

minetest.register_abm({
    nodenames = {"jeija:mesecon_torch_off","jeija:mesecon_torch_on"},
    interval = 0.2,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local pa = {x=0, y=0, z=0}
	pa.y = 1
	local rules_string=""

	if node.param2 == 5 then
		pa.z = -1
		rules_string="mesecontorch_z+"
	elseif node.param2 == 3 then
		pa.x = -1
		rules_string="mesecontorch_x+"
	elseif node.param2 == 4 then
		pa.z = 1
		rules_string="mesecontorch_z-"
	elseif node.param2 == 2 then
		pa.x = 1
		rules_string="mesecontorch_x-"
	elseif node.param2 == 0 then
		pa.y = 1
		rules_string="mesecontorch_y-"
        elseif node.param2 == 1 then
		pa.y = -1
		rules_string="mesecontorch_y+"
        end

        if mesecon:is_power_on({x=pos.x, y=pos.y, z=pos.z}, pa.x, pa.y, pa.z)==1 then
            if node.name ~= "jeija:mesecon_torch_off" then
                minetest.env:add_node(pos, {name="jeija:mesecon_torch_off",param2=node.param2})
                mesecon:receptor_off({x=pos.x-pa.x, y=pos.y-pa.y, z=pos.z-pa.z}, rules_string)
            end
        else
            if node.name ~= "jeija:mesecon_torch_on" then
                minetest.env:add_node(pos, {name="jeija:mesecon_torch_on",param2=node.param2})
                mesecon:receptor_on({x=pos.x-pa.x, y=pos.y-pa.y, z=pos.z-pa.z}, rules_string)
            end
        end
    end
})

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:mesecon_torch_on" then
			mesecon:receptor_off(pos)
		end	
	end
)

minetest.register_on_placenode(function(pos, node, placer)
	if node.name == "jeija:mesecon_torch_on" then
		local rules_string=""

		if node.param2 == 5 then
			rules_string="mesecontorch_z+"
		elseif node.param2 == 3 then
			rules_string="mesecontorch_x+"
		elseif node.param2 == 4 then
			rules_string="mesecontorch_z-"
		elseif node.param2 == 2 then
			rules_string="mesecontorch_x-"
		elseif node.param2 == 0 then
			rules_string="mesecontorch_y-"
	        elseif node.param2 == 1 then
			rules_string="mesecontorch_y+"
	        end
		
		mesecon:receptor_on(pos, rules_string)
	end
end)

mesecon:add_receptor_node("jeija:mesecon_torch_on")
mesecon:add_receptor_node_off("jeija:mesecon_torch_off")

-- Param2 Table (Block Attached To)
-- 5 = z-1
-- 3 = x-1
-- 4 = z+1
-- 2 = x+1
-- 0 = y+1
-- 1 = y-1
