for i = 1, 4 do
local groups = {}
if i == 1 then 
	groups = {bendy=2,snappy=1,dig_immediate=2, mesecon = 3}
else
	groups = {bendy=2,snappy=1,dig_immediate=2, not_in_creative_inventory=1, mesecon = 3}
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
	groups = {bendy=2,snappy=1,dig_immediate=2, not_in_creative_inventory=1, mesecon = 3},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = true,
	drop = 'mesecons_delayer:delayer_off_1',
})
end




minetest.register_on_punchnode(function (pos, node)
	mesecon.delayer_get_output_rules(node.param2)
	if node.name=="mesecons_delayer:delayer_off_1" then
		minetest.env:add_node(pos, {name="mesecons_delayer:delayer_off_2", param2=node.param2})
	end
	if node.name=="mesecons_delayer:delayer_off_2" then
		minetest.env:add_node(pos, {name="mesecons_delayer:delayer_off_3", param2=node.param2})
	end
	if node.name=="mesecons_delayer:delayer_off_3" then
		minetest.env:add_node(pos, {name="mesecons_delayer:delayer_off_4", param2=node.param2})
	end
	if node.name=="mesecons_delayer:delayer_off_4" then
		minetest.env:add_node(pos, {name="mesecons_delayer:delayer_off_1", param2=node.param2})
	end
end)

minetest.register_on_punchnode(function (pos, node)
	mesecon.delayer_get_output_rules(node.param2)
	if node.name=="mesecons_delayer:delayer_on_1" then
		minetest.env:add_node(pos, {name="mesecons_delayer:delayer_on_2", param2=node.param2})
	end
	if node.name=="mesecons_delayer:delayer_on_2" then
		minetest.env:add_node(pos, {name="mesecons_delayer:delayer_on_3", param2=node.param2})
	end
	if node.name=="mesecons_delayer:delayer_on_3" then
		minetest.env:add_node(pos, {name="mesecons_delayer:delayer_on_4", param2=node.param2})
	end
	if node.name=="mesecons_delayer:delayer_on_4" then
		minetest.env:add_node(pos, {name="mesecons_delayer:delayer_on_1", param2=node.param2})
	end
end)

mesecon.delayer_update = function(pos, node)
	if string.find(node.name, "mesecons_delayer:delayer_off")~=nil then
		local input_rules = mesecon.delayer_get_input_rules(node.param2)[1]
		np = {x = pos.x + input_rules.x, y = pos.y + input_rules.y, z = pos.z + input_rules.z}

		if mesecon:is_power_on(np) then
			local time = 0
			if node.name=="mesecons_delayer:delayer_off_1" then
				minetest.env:add_node(pos, {name="mesecons_delayer:delayer_on_1", param2=node.param2})
				time=0.1
			end
			if node.name=="mesecons_delayer:delayer_off_2" then
				minetest.env:add_node(pos, {name="mesecons_delayer:delayer_on_2", param2=node.param2})
				time=0.3
			end
			if node.name=="mesecons_delayer:delayer_off_3" then
				minetest.env:add_node(pos, {name="mesecons_delayer:delayer_on_3", param2=node.param2})
				time=0.5
			end
			if node.name=="mesecons_delayer:delayer_off_4" then
				minetest.env:add_node(pos, {name="mesecons_delayer:delayer_on_4", param2=node.param2})
				time=1
			end
			minetest.after(time, mesecon.delayer_turnon, {pos=pos, param2=node.param2})
		end
	end

	if string.find(node.name, "mesecons_delayer:delayer_on")~=nil then
		local input_rules = mesecon.delayer_get_input_rules(node.param2)[1]
		np = {x = pos.x + input_rules.x, y = pos.y + input_rules.y, z = pos.z + input_rules.z}

		if not mesecon:is_power_on(np) then
			local time = 0
			if node.name=="mesecons_delayer:delayer_on_1" then
				minetest.env:add_node(pos, {name="mesecons_delayer:delayer_off_1", param2=node.param2})
				time=0.1
			end
			if node.name=="mesecons_delayer:delayer_on_2" then
				minetest.env:add_node(pos, {name="mesecons_delayer:delayer_off_2", param2=node.param2})
				time=0.3
			end
			if node.name=="mesecons_delayer:delayer_on_3" then
				minetest.env:add_node(pos, {name="mesecons_delayer:delayer_off_3", param2=node.param2})
				time=0.5
			end
			if node.name=="mesecons_delayer:delayer_on_4" then
				minetest.env:add_node(pos, {name="mesecons_delayer:delayer_off_4", param2=node.param2})
				time=1
			end
			minetest.after(time, mesecon.delayer_turnoff, {pos=pos, param2=node.param2})
		end
	end
end

mesecon:register_on_signal_change(mesecon.delayer_update)

mesecon.delayer_turnon=function(params)
	local rules = mesecon.delayer_get_output_rules(params.param2)
	mesecon:receptor_on(params.pos, rules)
end

mesecon.delayer_turnoff=function(params)
	local rules = mesecon.delayer_get_output_rules(params.param2)
	mesecon:receptor_off(params.pos, rules)
end

mesecon.delayer_get_output_rules = function(param2)
	local rules = {}
	if param2 == 0 then
		table.insert(rules, {x = 1, y = 0, z = 0})
	elseif param2 == 2 then
		table.insert(rules, {x =-1, y = 0, z = 0})
	elseif param2 == 1 then
		table.insert(rules, {x = 0, y = 0, z =-1})
	elseif param2 == 3 then
		table.insert(rules, {x = 0, y = 0, z = 1})
	end
	return rules
end

mesecon.delayer_get_input_rules = function(param2)
	local rules = {}
	if param2 == 0 then
		table.insert(rules, {x =-1, y = 0, z = 0})
	elseif param2 == 2 then
		table.insert(rules, {x = 1, y = 0, z = 0})
	elseif param2 == 1 then
		table.insert(rules, {x = 0, y = 0, z = 1})
	elseif param2 == 3 then
		table.insert(rules, {x = 0, y = 0, z =-1})
	end
	return rules
end

all_rules = {{x = 1, y = 0, z = 0}, {x =-1, y = 0, z = 0}, {x = 0, y = 0, z =-1}, {x = 0, y = 0, z = 1}} --required to check if a newly placed should be turned on

mesecon:add_receptor_node("mesecons_delayer:delayer_on_1", all_rules, mesecon.delayer_get_output_rules)
mesecon:add_receptor_node("mesecons_delayer:delayer_on_2", all_rules, mesecon.delayer_get_output_rules)
mesecon:add_receptor_node("mesecons_delayer:delayer_on_3", all_rules, mesecon.delayer_get_output_rules)
mesecon:add_receptor_node("mesecons_delayer:delayer_on_4", all_rules, mesecon.delayer_get_output_rules)

mesecon:add_receptor_node_off("mesecons_delayer:delayer_off_1", all_rules, mesecon.delayer_get_output_rules)
mesecon:add_receptor_node_off("mesecons_delayer:delayer_off_2", all_rules, mesecon.delayer_get_output_rules)
mesecon:add_receptor_node_off("mesecons_delayer:delayer_off_3", all_rules, mesecon.delayer_get_output_rules)
mesecon:add_receptor_node_off("mesecons_delayer:delayer_off_4", all_rules, mesecon.delayer_get_output_rules)

mesecon:register_effector("mesecons_delayer:delayer_on_1", "mesecons_delayer:delayer_off_1", all_rules, mesecon.delayer_get_input_rules)
mesecon:register_effector("mesecons_delayer:delayer_on_2", "mesecons_delayer:delayer_off_2", all_rules, mesecon.delayer_get_input_rules)
mesecon:register_effector("mesecons_delayer:delayer_on_3", "mesecons_delayer:delayer_off_3", all_rules, mesecon.delayer_get_input_rules)
mesecon:register_effector("mesecons_delayer:delayer_on_4", "mesecons_delayer:delayer_off_4", all_rules, mesecon.delayer_get_input_rules)
