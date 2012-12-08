-- PRESSURE PLATE WOOD

minetest.register_node("mesecons_pressureplates:pressure_plate_wood_off", {
	drawtype = "nodebox",
	tiles = {"jeija_pressure_plate_wood_off.png"},
	inventory_image = "jeija_pressure_plate_wood_off.png",
	wield_image = "jeija_pressure_plate_wood_off.png",
	paramtype = "light",
	is_ground_content = true,
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
	},
	node_box = {
		type = "fixed",
		fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
	},
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=3, mesecon = 2},
    	description="Wood Pressure Plate",
	
	on_timer = function(pos, elapsed)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		for k, obj in pairs(objs) do
			local objpos=obj:getpos()
			if objpos.y>pos.y-1 and objpos.y<pos.y then
				minetest.env:add_node(pos, {name="mesecons_pressureplates:pressure_plate_wood_on"})
				mesecon:receptor_on(pos)
			end
		end
		return true
	end,
	
	on_construct = function(pos)
		minetest.env:get_node_timer(pos):start(PRESSURE_PLATE_INTERVAL)
	end,
})

minetest.register_node("mesecons_pressureplates:pressure_plate_wood_on", {
	drawtype = "nodebox",
	tiles = {"jeija_pressure_plate_wood_on.png"},
	paramtype = "light",
	is_ground_content = true,
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
	},
	node_box = {
		type = "fixed",
		fixed = { -7/16, -8/16, -7/16, 7/16, -31/64, 7/16 },
	},
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=3,not_in_creative_inventory=1, mesecon = 2},
	drop='"mesecons_pressureplates:pressure_plate_wood_off" 1',
	
	on_timer = function(pos, elapsed)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		if objs[1]==nil then
			minetest.env:add_node(pos, {name="mesecons_pressureplates:pressure_plate_wood_off"})
			mesecon:receptor_off(pos)
		end
		return true
	end,
	
	on_construct = function(pos)
		minetest.env:get_node_timer(pos):start(PRESSURE_PLATE_INTERVAL)
	end,
})

minetest.register_craft({
	output = '"mesecons_pressureplates:pressure_plate_wood_off" 1',
	recipe = {
		{'"default:wood"', '"default:wood"'},
	}
})

-- PRESSURE PLATE STONE

minetest.register_node("mesecons_pressureplates:pressure_plate_stone_off", {
	drawtype = "nodebox",
	tiles = {"jeija_pressure_plate_stone_off.png"},
	inventory_image = "jeija_pressure_plate_stone_off.png",
	wield_image = "jeija_pressure_plate_stone_off.png",
	paramtype = "light",
	is_ground_content = true,
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
	},
	node_box = {
		type = "fixed",
		fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
	},
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=3},
    	description="Stone Pressure Plate",
	
	on_timer = function(pos, elapsed)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		for k, obj in pairs(objs) do
			local objpos=obj:getpos()
			if objpos.y>pos.y-1 and objpos.y<pos.y then
				minetest.env:add_node(pos, {name="mesecons_pressureplates:pressure_plate_stone_on"})
				mesecon:receptor_on(pos)
			end
		end
		return true
	end,
	
	on_construct = function(pos)
		minetest.env:get_node_timer(pos):start(PRESSURE_PLATE_INTERVAL)
	end,

	mesecons = {receptor = {
		state = mesecon.state.off
	}}
})

minetest.register_node("mesecons_pressureplates:pressure_plate_stone_on", {
	drawtype = "nodebox",
	tiles = {"jeija_pressure_plate_stone_on.png"},
	paramtype = "light",
	is_ground_content = true,
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
	},
	node_box = {
		type = "fixed",
		fixed = { -7/16, -8/16, -7/16, 7/16, -31/64, 7/16 },
	},
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=3,not_in_creative_inventory=1},
	drop='"mesecons_pressureplates:pressure_plate_stone_off" 1',
	
	on_timer = function(pos, elapsed)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		if objs[1]==nil then
			minetest.env:add_node(pos, {name="mesecons_pressureplates:pressure_plate_stone_off"})
			mesecon:receptor_off(pos)
		end
		return true
	end,
	
	on_construct = function(pos)
		minetest.env:get_node_timer(pos):start(PRESSURE_PLATE_INTERVAL)
	end,

	mesecons = {receptor = {
		state = mesecon.state.off
	}}
})

minetest.register_craft({
	output = '"mesecons_pressureplates:pressure_plate_stone_off" 1',
	recipe = {
		{'"default:cobble"', '"default:cobble"'},
	}
})
