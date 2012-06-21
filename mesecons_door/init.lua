-- Mesecons Door

models = {
    {
        -- bottom part
        {-0.5, -0.5, -0.5, -0.4, 0.5, 0.5},
        -- A
        {-0.5, 0.5, -0.5, -0.4, 1.5, -0.3},
        -- B
        {-0.5, 0.5, 0.3, -0.4, 1.5, 0.5},
        -- C
        {-0.5, 1.3, -0.3, -0.4, 1.5, 0.3},
        -- D
        {-0.5, 0.5, -0.3, -0.4, 0.6, 0.3},
        -- E
        {-0.5, 0.6, -0.05, -0.4, 1.3, 0.05},
        -- F
        {-0.5, 0.9, -0.3, -0.4, 1, -0.05},
        -- G
        {-0.5, 0.9, 0.05, -0.4, 1, 0.3}
    },
    {
        {0.4, -0.5, -0.5, 0.5, 0.5, 0.5},
        {0.4, 0.5, -0.5, 0.5, 1.5, -0.3},
        {0.4, 0.5, 0.3, 0.5, 1.5, 0.5},
        {0.4, 1.3, -0.3, 0.5, 1.5, 0.3},
        {0.4, 0.5, -0.3, 0.5, 0.6, 0.3},
        {0.4, 0.6, -0.05, 0.5, 1.3, 0.05},
        {0.4, 0.9, -0.3, 0.5, 1, -0.05},
        {0.4, 0.9, 0.05, 0.5, 1, 0.3}
    },
    {
        {-0.5, -0.5, -0.5, 0.5, 0.5, -0.4},
        {-0.5, 0.5, -0.5, -0.3, 1.5, -0.4},
        {0.3, 0.5, -0.5, 0.5, 1.5, -0.4},
        {-0.3, 1.3, -0.5, 0.3, 1.5, -0.4},
        {-0.3, 0.5, -0.5, 0.3, 0.6, -0.4},
        {-0.05, 0.6, -0.5, 0.05, 1.3, -0.4},
        {-0.3, 0.9, -0.5, -0.05, 1, -0.4},
        {0.05, 0.9, -0.5, 0.3, 1, -0.4}
    },
    {
        {-0.5, -0.5, 0.4, 0.5, 0.5, 0.5},
        {-0.5, 0.5, 0.4, -0.3, 1.5, 0.5},
        {0.3, 0.5, 0.4, 0.5, 1.5, 0.5},
        {-0.3, 1.3, 0.4, 0.3, 1.5, 0.5},
        {-0.3, 0.5, 0.4, 0.3, 0.6, 0.5},
        {-0.05, 0.6, 0.4, 0.05, 1.3, 0.5},
        {-0.3, 0.9, 0.4, -0.05, 1, 0.5},
        {0.05, 0.9, 0.4, 0.3, 1, 0.5}
    }
}

selections = {
    {-0.5, -0.5, -0.5, -0.4, 1.5, 0.5},
    {0.5, -0.5, -0.5, 0.4, 1.5, 0.5},
    {-0.5, -0.5, -0.5, 0.5, 1.5, -0.4},
    {-0.5, -0.5, 0.4, 0.5, 1.5, 0.5}
}

transforms = {
    door_1_1 = "door_4_2",
    door_4_2 = "door_1_1",
    door_2_1 = "door_3_2",
    door_3_2 = "door_2_1",
    door_3_1 = "door_1_2",
    door_1_2 = "door_3_1",
    door_4_1 = "door_2_2",
    door_2_2 = "door_4_1"
}

mesecons_door_transform = function (pos, node)
    local x, y = node.name:find(":")
    local n = node.name:sub(x + 1)
    if transforms[n] ~= nil then
        minetest.env:add_node(pos, {name = "mesecons_door:"..transforms[n]})
    else
        print("not implemented")
    end
end

for i = 1, 4 do
    for j = 1, 2 do
        minetest.register_node("mesecons_door:door_"..i.."_"..j, {
            drawtype = "nodebox",
            tile_images = {"default_wood.png"},
            paramtype = "light",
            is_ground_content = true,
            groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
            drop = "mesecons_door:door",
            node_box = {
                type = "fixed",
                fixed = models[i]
            },
            selection_box = {
                type = "fixed",
                fixed = {
                    selections[i]
                }
            },
            on_punch = mesecons_door_transform
        })
    end
end

minetest.register_node("mesecons_door:door", {
    description = "Wooden door",
    node_placement_prediction = "",
	inventory_image     = 'door_wood.png',
	wield_image         = 'door_wood.png',
    after_place_node = function(node_pos, placer)
        local best_distance = 1e50
        local best_number = 1
        local pos = placer:getpos()
        for i = 1, 4 do
            local box = minetest.registered_nodes["mesecons_door:door_"..i.."_1"].selection_box.fixed[1]
            box = {box[1] + node_pos.x, box[2] + node_pos.y, box[3] + node_pos.z, box[4] + node_pos.x, box[5] + node_pos.y, box[6] + node_pos.z}
            local center = {x = (box[1] + box[4]) / 2, y = (box[2] + box[5]) / 2, z = (box[3] + box[6]) / 2}
            local dist = math.pow(math.pow(center.x - pos.x, 2) + math.pow(center.y - pos.y, 2) + math.pow(center.z - pos.z, 2), 0.5)
            if dist < best_distance then
                best_distance = dist
                best_number = i
            end
        end
        minetest.env:add_node(node_pos, {name = "mesecons_door:door_"..best_number.."_1"})
    end
})

minetest.register_on_placenode(function(pos, newnode, placer)
    local b_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
    local node = minetest.env:get_node(b_pos)
    if node.name:find("mesecons_door:door") ~= nil then
        minetest.env:remove_node(pos)
        minetest.env:add_item(pos, newnode.name)
    end
end)

minetest.register_craft({
	output = 'mesecons_door:door',
	recipe = {
		{ 'default:wood', 'default:wood', '' },
		{ 'default:wood', 'default:wood', '' },
		{ 'default:wood', 'default:wood', '' },
	},
})

--MESECONS
mesecon:register_on_signal_change(function(pos, node)
	if string.find(node.name, "mesecons_door:door_") then
		mesecons_door_transform(pos, node)
	end
end)
