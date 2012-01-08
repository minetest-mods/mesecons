--SHORT RANGE DETECTORS
minetest.register_node("jeija:object_detector_off", {
	tile_images = {"default_steel_block.png", "default_steel_block.png", "jeija_object_detector_off.png", "jeija_object_detector_off.png", "jeija_object_detector_off.png", "jeija_object_detector_off.png"},
	inventory_image = minetest.inventorycube("default_steel_block.png", "jeija_object_detector_off.png", "jeija_object_detector_off.png"),
	paramtype = "light",
	walkable = true,
	material = minetest.digprop_stonelike(4),
})

minetest.register_node("jeija:object_detector_on", {
	tile_images = {"default_steel_block.png", "default_steel_block.png", "jeija_object_detector_on.png", "jeija_object_detector_on.png", "jeija_object_detector_on.png", "jeija_object_detector_on.png"},
	inventory_image = minetest.inventorycube("jeija_object_detector_on.png"),
	paramtype = "light",
	walkable = true,
	material = minetest.digprop_stonelike(4),
	dug_item = 'node "jeija:object_detector_off" 1'
})

minetest.register_craft({
	output = 'node "jeija:object_detector_off" 1',
	recipe = {
		{'node "default:steelblock"', '', 'node "default:steelblock"'},
		{'node "default:steelblock"', 'craft "jeija:ic"', 'node "default:steelblock"'},
		{'node "default:steelblock"', 'node "jeija:mesecon_off', 'node "default:steelblock"'},
	}
})

minetest.register_abm(
	{nodenames = {"jeija:object_detector_off"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 6)
		for k, obj in pairs(objs) do
			if obj:get_entity_name()~="jeija:piston_pusher_sticky" and obj:get_entity_name()~="jeija:piston_pusher_normal" and obj:get_player_name()~=nil then -- Detected object is not piston pusher - will be changed if every entity has a type (like entity_type=mob)
				if minetest.env:get_node({x=pos.x, y=pos.y-1, z=pos.z}).name=="default:sign_wall" then
					if obj:get_player_name()~=minetest.env:get_meta({x=pos.x, y=pos.y-1, z=pos.z}):get_text() then
						return
					end
				end
				local objpos=obj:getpos()
				minetest.env:add_node(pos, {name="jeija:object_detector_on"})
				mesecon:receptor_on(pos, "pressureplate")
			end
		end	
	end,
})

minetest.register_abm(
	{nodenames = {"jeija:object_detector_on"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 6)
		local objectfound=0
		for k, obj in pairs(objs) do
			if obj:get_entity_name()~="jeija:piston_pusher_sticky" and obj:get_entity_name()~="jeija:piston_pusher_normal" and obj~=nil 
			and obj:get_player_name()~=nil then
				if minetest.env:get_node({x=pos.x, y=pos.y-1, z=pos.z}).name=="default:sign_wall" then
					if minetest.env:get_meta({x=pos.x, y=pos.y-1, z=pos.z}):get_text() == obj:get_player_name() then
						objectfound=objectfound+1
					end
				else
-- Detected object is not piston pusher - will be changed if every entity has a type (like entity_type=mob)
					objectfound=objectfound + 1
				end
			end
		end	
		if objectfound==0 then
			minetest.env:add_node(pos, {name="jeija:object_detector_off"})
			mesecon:receptor_off(pos, "pressureplate")
		end
	end,
})

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:object_detector_on" then
			mesecon:receptor_off(pos, "pressureplate")
		end	
	end
)

mesecon:add_receptor_node("jeija:object_detector_on")
mesecon:add_receptor_node_off("jeija:object_detector_off")
