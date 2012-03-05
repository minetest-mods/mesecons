-- WALL LEVER
minetest.register_node("mesecons_walllever:wall_lever_off", {
    drawtype = "signlike",
    tile_images = {"jeija_wall_lever_off.png"},
    inventory_image = "jeija_wall_lever_off.png",
    wield_image = "jeija_wall_lever_off.png",
    paramtype = "light",
    paramtype2 = "wallmounted",
    legacy_wallmounted = true,
    walkable = false,
    selection_box = {
        type = "wallmounted",
    },
    material = minetest.digprop_constanttime(0.3),
    description="Lever",
})
minetest.register_node("mesecons_walllever:wall_lever_on", {
    drawtype = "signlike",
    tile_images = {"jeija_wall_lever_on.png"},
    inventory_image = "jeija_wall_lever_on.png",
    paramtype = "light",
    paramtype2 = "wallmounted",
    legacy_wallmounted = true,
    walkable = false,
    selection_box = {
        type = "wallmounted",
    },
    material = minetest.digprop_constanttime(0.3),
    drop = '"mesecons_walllever:wall_lever_off" 1',
    description="Lever",
})

minetest.register_on_dignode(
    function(pos, oldnode, digger)
        if oldnode.name == "mesecons_walllever:wall_lever_on" then
            mesecon:receptor_off(pos)
        end    
    end
)
minetest.register_on_punchnode(function(pos, node, puncher)
	if node.name == "mesecons_walllever:wall_lever_off" then
		minetest.env:add_node(pos, {name="mesecons_walllever:wall_lever_on",param2=node.param2})
		local rules_string=nil
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
	if node.name == "mesecons_walllever:wall_lever_on" then
		minetest.env:add_node(pos, {name="mesecons_walllever:wall_lever_off",param2=node.param2})
		local rules_string=nil
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
end)

minetest.register_craft({
	output = '"mesecons_walllever:wall_lever_off" 2',
	recipe = {
	    {'"mesecons:mesecon_off"'},
		{'"default:stone"'},
		{'"default:stick"'},
	}
})
mesecon:add_receptor_node("mesecons_walllever:wall_lever")
mesecon:add_receptor_node_off("mesecons_walllever:wall_lever_off")
