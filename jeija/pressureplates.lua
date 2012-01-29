-- PRESSURE PLATE WOOD

minetest.register_node("jeija:pressure_plate_wood_off", {
	drawtype = "raillike",
	tile_images = {"jeija_pressure_plate_wood_off.png"},
	inventory_image = "jeija_pressure_plate_wood_off.png",
	paramtype = "light",
	is_ground_content = true,
	walkable = false,
	selection_box = {
		type = "fixed",
	},
	material = minetest.digprop_constanttime(0.3),
    	description="Wood Pressure Plate",
})

minetest.register_node("jeija:pressure_plate_wood_on", {
	drawtype = "raillike",
	tile_images = {"jeija_pressure_plate_wood_on.png"},
	inventory_image = "jeija_pressure_plate_wood_on.png",
	paramtype = "light",
	is_ground_content = true,
	walkable = false,
	selection_box = {
		type = "fixed",
	},
	material = minetest.digprop_constanttime(0.3),
	drop='"jeija:pressure_plate_wood_off" 1',
    	description="Wood Pressure Plate",
})

minetest.register_craft({
	output = '"jeija:pressure_plate_wood_off" 1',
	recipe = {
		{'"default:wood"', '"default:wood"'},
	}
})

minetest.register_abm(
	{nodenames = {"jeija:pressure_plate_wood_off"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		for k, obj in pairs(objs) do
			local objpos=obj:getpos()
			if objpos.y>pos.y-1 and objpos.y<pos.y then
				minetest.env:add_node(pos, {name="jeija:pressure_plate_wood_on"})
				mesecon:receptor_on(pos, "pressureplate")
			end
		end	
	end,
})

minetest.register_abm(
	{nodenames = {"jeija:pressure_plate_wood_on"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		if objs[1]==nil then
			minetest.env:add_node(pos, {name="jeija:pressure_plate_wood_off"})
			mesecon:receptor_off(pos, "pressureplate")
		end
	end,
})

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:pressure_plate_wood_on" then
			mesecon:receptor_off(pos, "pressureplate")
		end	
	end
)

mesecon:add_receptor_node("jeija:pressure_plate_wood_on")
mesecon:add_receptor_node_off("jeija:pressure_plate_wood_off")

-- PRESSURE PLATE STONE

minetest.register_node("jeija:pressure_plate_stone_off", {
	drawtype = "raillike",
	tile_images = {"jeija_pressure_plate_stone_off.png"},
	inventory_image = "jeija_pressure_plate_stone_off.png",
	paramtype = "light",
	is_ground_content = true,
	walkable = false,
	selection_box = {
		type = "fixed",
	},
	material = minetest.digprop_constanttime(0.3),
    	description="Stone Pressure Plate",
})

minetest.register_node("jeija:pressure_plate_stone_on", {
	drawtype = "raillike",
	tile_images = {"jeija_pressure_plate_stone_on.png"},
	inventory_image = "jeija_pressure_plate_stone_on.png",
	paramtype = "light",
	is_ground_content = true,
	walkable = false,
	selection_box = {
		type = "fixed",
	},
	material = minetest.digprop_constanttime(0.3),
	drop='"jeija:pressure_plate_stone_off" 1',
    	description="Stone Pressure Plate",
})

minetest.register_craft({
	output = '"jeija:pressure_plate_stone_off" 1',
	recipe = {
		{'"default:cobble"', '"default:cobble"'},
	}
})

minetest.register_abm(
	{nodenames = {"jeija:pressure_plate_stone_off"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		for k, obj in pairs(objs) do
			local objpos=obj:getpos()
			if objpos.y>pos.y-1 and objpos.y<pos.y then
				minetest.env:add_node(pos, {name="jeija:pressure_plate_stone_on"})
				mesecon:receptor_on(pos, "pressureplate")
			end
		end	
	end,
})

minetest.register_abm(
	{nodenames = {"jeija:pressure_plate_stone_on"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		if objs[1]==nil then
			minetest.env:add_node(pos, {name="jeija:pressure_plate_stone_off"})
			mesecon:receptor_off(pos, "pressureplate")
		end
	end,
})

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:pressure_plate_stone_on" then
			mesecon:receptor_off(pos, "pressureplate")
		end	
	end
)

mesecon:add_receptor_node("jeija:pressure_plate_stone_on")
mesecon:add_receptor_node_off("jeija:pressure_plate_stone_off")
