-- Function that get the input/output rules of the delayer
local delayer_get_output_rules = function(node)
	local rules = {}
	if node.param2 == 0 then
		table.insert(rules, {x = 1, y = 0, z = 0})
	elseif node.param2 == 2 then
		table.insert(rules, {x =-1, y = 0, z = 0})
	elseif node.param2 == 1 then
		table.insert(rules, {x = 0, y = 0, z =-1})
	elseif node.param2 == 3 then
		table.insert(rules, {x = 0, y = 0, z = 1})
	end
	return rules
end

local delayer_get_input_rules = function(node)
	local rules = {}
	if node.param2 == 0 then
		table.insert(rules, {x =-1, y = 0, z = 0})
	elseif node.param2 == 2 then
		table.insert(rules, {x = 1, y = 0, z = 0})
	elseif node.param2 == 1 then
		table.insert(rules, {x = 0, y = 0, z = 1})
	elseif node.param2 == 3 then
		table.insert(rules, {x = 0, y = 0, z =-1})
	end
	return rules
end

-- Functions that are called after the delay time

local delayer_turnon = function(params)
	local rules = delayer_get_output_rules(params)
	mesecon:receptor_on(params.pos, rules)
end

local delayer_turnoff = function(params)
	local rules = delayer_get_output_rules(params)
	mesecon:receptor_off(params.pos, rules)
end

local delayer_update = function(pos, node)
	print("update")
	if string.find(node.name, "mesecons_delayer:delayer_off")~=nil then
		local time = 0
		if node.name=="mesecons_delayer:delayer_off_1" then
			mesecon:swap_node(pos, "mesecons_delayer:delayer_on_1")
			time=0.1
		elseif node.name=="mesecons_delayer:delayer_off_2" then
			mesecon:swap_node(pos, "mesecons_delayer:delayer_on_2")
			time=0.3
		elseif node.name=="mesecons_delayer:delayer_off_3" then
			mesecon:swap_node(pos, "mesecons_delayer:delayer_on_3")
			time=0.5
		elseif node.name=="mesecons_delayer:delayer_off_4" then
			mesecon:swap_node(pos, "mesecons_delayer:delayer_on_4")
			time=1
		end
		minetest.after(time, delayer_turnon, {pos=pos, param2=node.param2})
	end

	if string.find(node.name, "mesecons_delayer:delayer_on")~=nil then
		local time = 0
		if node.name=="mesecons_delayer:delayer_on_1" then
			mesecon:swap_node(pos, "mesecons_delayer:delayer_off_1")
			time=0.1
		elseif node.name=="mesecons_delayer:delayer_on_2" then
			mesecon:swap_node(pos, "mesecons_delayer:delayer_off_2")
			time=0.3
		elseif node.name=="mesecons_delayer:delayer_on_3" then
			mesecon:swap_node(pos, "mesecons_delayer:delayer_off_3")
			time=0.5
		elseif node.name=="mesecons_delayer:delayer_on_4" then
			mesecon:swap_node(pos, "mesecons_delayer:delayer_off_4")
			time=1
		end
		minetest.after(time, delayer_turnoff, {pos=pos, param2=node.param2})
	end
end

--Actually register the 2 (states) x 4 (delay times) delayers

for i = 1, 4 do
local groups = {}
if i == 1 then 
	groups = {bendy=2,snappy=1,dig_immediate=2}
else
	groups = {bendy=2,snappy=1,dig_immediate=2, not_in_creative_inventory=1}
end

boxes = {{ -6/16, -8/16, -6/16, 6/16, -7/16, 6/16 },		-- the main slab

	 { -2/16, -7/16, -4/16, 2/16, -26/64, -3/16 },		-- the jeweled "on" indicator
	 { -3/16, -7/16, -3/16, 3/16, -26/64, -2/16 },
	 { -4/16, -7/16, -2/16, 4/16, -26/64, 2/16 },
	 { -3/16, -7/16,  2/16, 3/16, -26/64, 3/16 },
	 { -2/16, -7/16,  3/16, 2/16, -26/64, 4/16 },

	 { -6/16, -7/16, -6/16, -4/16, -27/64, -4/16 },		-- the timer indicator
	 { -8/16, -8/16, -1/16, -6/16, -7/16, 1/16 },		-- the two wire stubs
	 { 6/16, -8/16, -1/16, 8/16, -7/16, 1/16 }}

minetest.register_node("mesecons_delayer:delayer_off_"..tostring(i), {
	description = "Delayer",
	drawtype = "nodebox",
	tiles = {
		"mesecons_delayer_off_"..tostring(i)..".png",
		"mesecons_delayer_bottom.png",
		"mesecons_delayer_ends_off.png",
		"mesecons_delayer_ends_off.png",
		"mesecons_delayer_sides_off.png",
		"mesecons_delayer_sides_off.png"
		},
	inventory_image = "mesecons_delayer_off_1.png",
	wield_image = "mesecons_delayer_off_1.png",
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = boxes
	},
	groups = groups,
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = true,
	drop = 'mesecons_delayer:delayer_off_1',
	on_punch = function (pos, node)
		if node.name=="mesecons_delayer:delayer_off_1" then
			mesecon:swap_node(pos,"mesecons_delayer:delayer_off_2")
		elseif node.name=="mesecons_delayer:delayer_off_2" then
			mesecon:swap_node(pos,"mesecons_delayer:delayer_off_3")
		elseif node.name=="mesecons_delayer:delayer_off_3" then
			mesecon:swap_node(pos,"mesecons_delayer:delayer_off_4")
		elseif node.name=="mesecons_delayer:delayer_off_4" then
			mesecon:swap_node(pos,"mesecons_delayer:delayer_off_1")
		end
	end,
	mesecons = {
		receptor =
		{
			state = mesecon.state.off,
			rules = delayer_get_output_rules
		},
		effector =
		{
			rules = delayer_get_input_rules,
			action_change = delayer_update
		}
	}
})


minetest.register_node("mesecons_delayer:delayer_on_"..tostring(i), {
	description = "You hacker you",
	drawtype = "nodebox",
	tiles = {
		"mesecons_delayer_on_"..tostring(i)..".png",
		"mesecons_delayer_bottom.png",
		"mesecons_delayer_ends_on.png",
		"mesecons_delayer_ends_on.png",
		"mesecons_delayer_sides_on.png",
		"mesecons_delayer_sides_on.png"
		},
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = boxes
	},
	groups = {bendy = 2, snappy = 1, dig_immediate = 2, not_in_creative_inventory = 1},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = true,
	drop = 'mesecons_delayer:delayer_off_1',
	on_punch = function (pos, node)
		if node.name=="mesecons_delayer:delayer_on_1" then
			mesecon:swap_node(pos,"mesecons_delayer:delayer_on_2")
		elseif node.name=="mesecons_delayer:delayer_on_2" then
			mesecon:swap_node(pos,"mesecons_delayer:delayer_on_3")
		elseif node.name=="mesecons_delayer:delayer_on_3" then
			mesecon:swap_node(pos,"mesecons_delayer:delayer_on_4")
		elseif node.name=="mesecons_delayer:delayer_on_4" then
			mesecon:swap_node(pos,"mesecons_delayer:delayer_on_1")
		end
	end,
	mesecons = {
		receptor =
		{
			state = mesecon.state.on,
			rules = delayer_get_output_rules
		},
		effector =
		{
			rules = delayer_get_input_rules,
			action_change = delayer_update
		}
	}
})
end
