-- HYDRO_TURBINE

minetest.register_node("mesecons_hydroturbine:hydro_turbine_off", {
	drawtype = "nodebox",
	tile_images = {"jeija_hydro_turbine_off.png"},
	groups = {dig_immediate=2, mesecon = 2},
    	description="Water Turbine",
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.15, 0.5, -0.15, 0.15, 1.45, 0.15},
			{-0.45, 1.15, -0.1, 0.45, 1.45, 0.1},
			{-0.1, 1.15, -0.45, 0.1, 1.45, 0.45}},
	},
	node_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.15, 0.5, -0.15, 0.15, 1.45, 0.15},
			{-0.45, 1.15, -0.1, 0.45, 1.45, 0.1},
			{-0.1, 1.15, -0.45, 0.1, 1.45, 0.45}},
	},
})

minetest.register_node("mesecons_hydroturbine:hydro_turbine_on", {
	drawtype = "nodebox",
	tile_images = {"jeija_hydro_turbine_on.png"},
	drop = '"mesecons_hydroturbine:hydro_turbine_off" 1',
	groups = {dig_immediate=2,not_in_creative_inventory=1, mesecon = 2},
	description="Water Turbine",
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.15, 0.5, -0.15, 0.15, 1.45, 0.15},
			{-0.5, 1.15, -0.1, 0.5, 1.45, 0.1},
			{-0.1, 1.15, -0.5, 0.1, 1.45, 0.5}},
	},
	node_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.15, 0.5, -0.15, 0.15, 1.45, 0.15},
			{-0.5, 1.15, -0.1, 0.5, 1.45, 0.1},
			{-0.1, 1.15, -0.5, 0.1, 1.45, 0.5}},
	},
})


minetest.register_abm({
nodenames = {"mesecons_hydroturbine:hydro_turbine_off"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local waterpos={x=pos.x, y=pos.y+1, z=pos.z}
		if minetest.env:get_node(waterpos).name=="default:water_flowing" then
			--minetest.env:remove_node(pos)
			minetest.env:add_node(pos, {name="mesecons_hydroturbine:hydro_turbine_on"})
			nodeupdate(pos)
			mesecon:receptor_on(pos)
		end
	end,
})

minetest.register_abm({
nodenames = {"mesecons_hydroturbine:hydro_turbine_on"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local waterpos={x=pos.x, y=pos.y+1, z=pos.z}
		if minetest.env:get_node(waterpos).name~="default:water_flowing" then
			--minetest.env:remove_node(pos)
			minetest.env:add_node(pos, {name="mesecons_hydroturbine:hydro_turbine_off"})
			nodeupdate(pos)
			mesecon:receptor_off(pos)
		end
	end,
})

mesecon:add_receptor_node("mesecons_hydroturbine:hydro_turbine_on")
mesecon:add_receptor_node_off("mesecons_hydroturbine:hydro_turbine_off")

minetest.register_craft({
	output = '"mesecons_hydroturbine:hydro_turbine_off" 2',
	recipe = {
	{'','"default:stick"', ''},
	{'"default:stick"', '"default:steel_ingot"', '"default:stick"'},
	{'','"default:stick"', ''},
	}
})

