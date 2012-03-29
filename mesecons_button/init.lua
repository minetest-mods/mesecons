-- WALL BUTTON
minetest.register_node("mesecons_button:button_off", {
    drawtype = "signlike",
    tile_images = {"jeija_wall_button_off.png"},
    paramtype = "light",
    paramtype2 = "wallmounted",
    legacy_wallmounted = true,
    walkable = false,
    selection_box = {
        type = "wallmounted",
    },
    groups = {dig_immediate=2},
    description="Button",
})
minetest.register_node("mesecons_button:button_on", {
    drawtype = "signlike",
    tile_images = {"jeija_wall_button_on.png"},
    paramtype = "light",
    paramtype2 = "wallmounted",
    legacy_wallmounted = true,
    walkable = false,
    selection_box = {
        type = "wallmounted",
    },
    groups = {dig_immediate=2},
    drop = '"mesecons_button:button_off" 1',
    description="Button",
})

minetest.register_on_dignode(
    function(pos, oldnode, digger)
        if oldnode.name == "mesecons_button:button_on" then
            mesecon:receptor_off(pos)
        end    
    end
)
minetest.register_on_punchnode(function(pos, node, puncher)
	if node.name == "mesecons_button:button_off" then
		minetest.env:add_node(pos, {name="mesecons_button:button_on",param2=node.param2})

		local rules=mesecon:get_rules("button")
		if node.param2 == 5 then
			rules=mesecon:rotate_rules_left(rules)
		end
		if node.param2 == 3 then
			rules=mesecon:rotate_rules_right(mesecon:rotate_rules_right(rules))
		end
		if node.param2 == 4 then
			rules=mesecon:rotate_rules_right(rules)
		end
        	mesecon:receptor_on(pos, rules)
	end
end)

minetest.register_abm({
	nodenames = {"mesecons_button:button_on"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.env:add_node(pos, {name="mesecons_button:button_off",param2=node.param2})

		local rules=mesecon:get_rules("button")
		print (rules[1].x)
		if node.param2 == 5 then
			rules=mesecon:rotate_rules_left(rules)
		end
		print (rules[1].x)
		if node.param2 == 3 then
			rules=mesecon:rotate_rules_right(mesecon:rotate_rules_right(rules))
		end
		print (rules[1].x)
		if node.param2 == 4 then
			rules=mesecon:rotate_rules_right(rules)
		end
		print (rules[1].x)
        	mesecon:receptor_off(pos, rules)
	end
})

minetest.register_craft({
	output = '"mesecons_button:button_off" 2',
	recipe = {
		{'"mesecons:mesecon_off"','"default:stone"'},
	}
})

mesecon:add_rules("button", {
{x=1,  y=0,  z=0},
{x=-1, y=0,  z=0},
{x=0,  y=0,  z=1},
{x=1,  y=1,  z=0},
{x=1,  y=-1, z=0},
{x=-1, y=1,  z=0},
{x=-1, y=-1, z=0},
{x=0,  y=1,  z=1},
{x=0,  y=-1, z=1},
{x=0,  y=1,  z=-1},
{x=0,  y=-1, z=-1},
{x=0,  y=-1, z=0},
{x=2,  y=0,  z=0}})

mesecon:add_receptor_node("mesecons_button:button")
mesecon:add_receptor_node_off("mesecons_button:button_off")
