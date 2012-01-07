--TEMPEREST-PLUG

minetest.register_node("jeija:mesecon_plug", {
    drawtype = "raillike",
    paramtype = "light",
    is_ground_content = true,
    tile_images = {"jeija_mesecon_plug.png"},
    inventory_image = "jeija_mesecon_plug.png",
    material = minetest.digprop_constanttime(0.1),
    walkable = false,
    selection_box = {
        type = "fixed",
    },
})

mesecon:register_on_signal_on(function(pos, node)
    if node.name=="jeija:mesecon_plug" then
        for x = -2,2,2 do
        for z = -2,2,2 do
            lpos = {x=pos.x+x, y=pos.y, z=pos.z+z}
            lnode = minetest.env:get_node(lpos)
            if lnode.name=="jeija:mesecon_socket_off" then
                minetest.env:add_node(lpos, {name="jeija:mesecon_socket_on"})
                nodeupdate(lpos)
                mesecon:receptor_on(lpos)
            elseif lnode.name=="jeija:mesecon_inverter_on" then
                minetest.env:add_node(lpos, {name="jeija:mesecon_inverter_off"})
                nodeupdate(lpos)
                mesecon:receptor_off(lpos)
            end
        end
        end
    end
end)

mesecon:register_on_signal_off(function(pos, node)
    if node.name=="jeija:mesecon_plug" then
        for x = -2,2,2 do
        for z = -2,2,2 do
            lpos = {x=pos.x+x, y=pos.y, z=pos.z+z}
            lnode = minetest.env:get_node(lpos)
            if lnode.name=="jeija:mesecon_socket_on" then
                minetest.env:add_node(lpos, {name="jeija:mesecon_socket_off"})
                nodeupdate(lpos)
                mesecon:receptor_off(lpos)
            elseif lnode.name=="jeija:mesecon_inverter_off" then
                minetest.env:add_node(lpos, {name="jeija:mesecon_inverter_on"})
                nodeupdate(lpos)
                mesecon:receptor_on(lpos)
            end
        end
        end
    end
end)

minetest.register_on_dignode(function(pos, oldnode, digger)
    if oldnode.name == "jeija:mesecon_plug" then
        for x = -2,2,2 do
        for z = -2,2,2 do
            lpos = {x=pos.x+x, y=pos.y, z=pos.z+z}
            lnode = minetest.env:get_node(lpos)
            if lnode.name=="jeija:mesecon_socket_on" then
                minetest.env:add_node(lpos, {name="jeija:mesecon_socket_off"})
                nodeupdate(lpos)
                mesecon:receptor_off(lpos)
            elseif lnode.name=="jeija:mesecon_inverter_on" then
                minetest.env:add_node(lpos, {name="jeija:mesecon_inverter_off"})
                nodeupdate(lpos)
                mesecon:receptor_off(lpos)
            end
        end
        end
    end
end)


minetest.register_craft({
    output = 'node "jeija:mesecon_plug" 2',
    recipe = {
        {'', 'node "jeija:mesecon_off"', ''},
        {'node "jeija:mesecon_off"', 'craft "default:steel_ingot"', 'node "jeija:mesecon_off"'},
        {'', 'node "jeija:mesecon_off"', ''},
    }
})

--TEMPEREST-SOCKET

minetest.register_node("jeija:mesecon_socket_off", {
    drawtype = "raillike",
    paramtype = "light",
    is_ground_content = true,
    tile_images = {"jeija_mesecon_socket_off.png"},
    inventory_image = "jeija_mesecon_socket_off.png",
    material = minetest.digprop_constanttime(0.1),
    walkable = false,
    selection_box = {
        type = "fixed",
    },
})

minetest.register_node("jeija:mesecon_socket_on", {
    drawtype = "raillike",
    paramtype = "light",
    is_ground_content = true,
    tile_images = {"jeija_mesecon_socket_on.png"},
    inventory_image = "jeija_mesecon_socket_on.png",
    material = minetest.digprop_constanttime(0.1),
    walkable = false,
    selection_box = {
        type = "fixed",
    },
    dug_item='node "jeija:mesecon_socket_off" 1',
})

minetest.register_on_dignode(
    function(pos, oldnode, digger)
        if oldnode.name == "jeija:mesecon_socket_on" then
            mesecon:receptor_off(pos)
        end
    end
)

mesecon:add_receptor_node("jeija:mesecon_socket_on")
mesecon:add_receptor_node_off("jeija:mesecon_socket_off")

minetest.register_craft({
    output = 'node "jeija:mesecon_socket_off" 2',
    recipe = {
        {'', 'craft "default:steel_ingot"', ''},
        {'craft "default:steel_ingot"', 'node "jeija:mesecon_off"', 'craft "default:steel_ingot"'},
        {'', 'craft "default:steel_ingot"', ''},
    }
})

--TEMPEREST-INVERTER

minetest.register_node("jeija:mesecon_inverter_off", {
    drawtype = "raillike",
    paramtype = "light",
    is_ground_content = true,
    tile_images = {"jeija_mesecon_inverter_off.png"},
    inventory_image = "jeija_mesecon_inverter_off.png",
    material = minetest.digprop_constanttime(0.1),
    walkable = false,
    selection_box = {
        type = "fixed",
    },
})

minetest.register_node("jeija:mesecon_inverter_on", {
    drawtype = "raillike",
    paramtype = "light",
    is_ground_content = true,
    tile_images = {"jeija_mesecon_inverter_on.png"},
    inventory_image = "jeija_mesecon_inverter_on.png",
    material = minetest.digprop_constanttime(0.1),
    walkable = false,
    selection_box = {
        type = "fixed",
    },
    dug_item='node "jeija:mesecon_inverter_off" 1',
})

minetest.register_on_dignode(
    function(pos, oldnode, digger)
        if oldnode.name == "jeija:mesecon_inverter_on" then
            mesecon:receptor_off(pos)
        end
    end
)

mesecon:add_receptor_node("jeija:mesecon_inverter_on")
mesecon:add_receptor_node_off("jeija:mesecon_inverter_off")

minetest.register_craft({
    output = 'node "jeija:mesecon_inverter_off" 2',
    recipe = {
        {'node "jeija:mesecon_off"', 'craft "default:steel_ingot"', 'node "jeija:mesecon_off"'},
        {'craft "default:steel_ingot"', '', 'craft "default:steel_ingot"'},
        {'node "jeija:mesecon_off"', 'craft "default:steel_ingot"', 'node "jeija:mesecon_off"'},
    }
})
