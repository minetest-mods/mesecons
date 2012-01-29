-- WALL BUTTON
minetest.register_node("jeija:wall_button_off", {
    drawtype = "signlike",
    tile_images = {"jeija_wall_button_off.png"},
    inventory_image = "jeija_wall_button_off.png",
    wield_image = "jeija_wall_button_off.png",
    paramtype = "light",
    paramtype2 = "wallmounted",
    legacy_wallmounted = true,
    walkable = false,
    selection_box = {
        type = "wallmounted",
    },
    material = minetest.digprop_constanttime(0.3),
    description="Button",
})
minetest.register_node("jeija:wall_button_on", {
    drawtype = "signlike",
    tile_images = {"jeija_wall_button_on.png"},
    inventory_image = "jeija_wall_button_on.png",
    paramtype = "light",
    paramtype2 = "wallmounted",
    legacy_wallmounted = true,
    walkable = false,
    selection_box = {
        type = "wallmounted",
    },
    material = minetest.digprop_constanttime(0.3),
    drop = '"jeija:wall_button_off" 1',
    description="Button",
})

minetest.register_on_dignode(
    function(pos, oldnode, digger)
        if oldnode.name == "jeija:wall_button_on" then
            mesecon:receptor_off(pos)
        end    
    end
)
minetest.register_on_punchnode(function(pos, node, puncher)
	if node.name == "jeija:wall_button_off" then
		minetest.env:add_node(pos, {name="jeija:wall_button_on",param2=node.param2})
		local rules_string=""
		if node.param2 == 5 then
			rules_string="button_z+"
		end
		if node.param2 == 3 then
			rules_string="button_x+"
		end
		if node.param2 == 4 then
			rules_string="button_z-"
		end
		if node.param2 == 2 then
			rules_string="button_x-"
		end
		mesecon:receptor_on(pos, rules_string)
	end
end)
minetest.register_abm({
	nodenames = {"jeija:wall_button_on"},
	interval = 0.1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.env:add_node(pos, {name="jeija:wall_button_off",param2=node.param2})

		local rules_string=""
		if node.param2 == 5 then
			rules_string="button_z+"
		end
		if node.param2 == 3 then
			rules_string="button_x+"
		end
		if node.param2 == 4 then
			rules_string="button_z-"
		end
		if node.param2 == 2 then
			rules_string="button_x-"
		end
        	mesecon:receptor_off(pos, rules_string)
	end
})
minetest.register_craft({
	output = '"jeija:wall_button_off" 2',
	recipe = {
		{'"jeija:mesecon_off"','"default:stone"'},
	}
})
mesecon:add_receptor_node("jeija:wall_button")
mesecon:add_receptor_node_off("jeija:wall_button_off")
