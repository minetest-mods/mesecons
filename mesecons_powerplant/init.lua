-- The POWER_PLANT

minetest.register_node("mesecons_powerplant:power_plant", {
	drawtype = "plantlike",
	visual_scale = 1,
	tile_images = {"jeija_power_plant.png"},
	inventory_image = "jeija_power_plant.png",
	paramtype = "light",
	walkable = false,
	groups = {snappy=2},
	light_source = LIGHT_MAX-9,
    	description="Power Plant",
})

minetest.register_craft({
	output = '"mesecons_powerplant:power_plant" 1',
	recipe = {
		{'"mesecons:mesecon_off"'},
		{'"mesecons:mesecon_off"'},
		{'"default:junglegrass"'},
	}
})

minetest.register_on_placenode(function(pos, newnode, placer)
	if newnode.name == "mesecons_powerplant:power_plant" then
		mesecon:receptor_on(pos)
	end
end)

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "mesecons_powerplant:power_plant" then
			mesecon:receptor_off(pos)
		end	
	end
)

mesecon:add_receptor_node("mesecons_powerplant:power_plant")
