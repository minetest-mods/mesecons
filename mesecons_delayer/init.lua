for i = 1, 4 do
local groups = {}
if i == 1 then 
	groups = {bendy=2,snappy=1,dig_immediate=2}
else
	groups = {bendy=2,snappy=1,dig_immediate=2, not_in_creative_inventory=1}
end

minetest.register_node("mesecons_delayer:delayer_off_"..tostring(i), {
	description = "Delayer",
	drawtype = "nodebox",
	tiles = {
		"mesecons_delayer_off_"..tostring(i)..".png",
		"mesecons_delayer_sides.png"
		},
	inventory_image = "mesecons_delayer_off_1.png",
	wield_image = "mesecons_delayer_off_1.png",
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
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
		"mesecons_delayer_sides.png"
		},
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
	},
	groups = {bendy=2,snappy=1,dig_immediate=2,not_in_creative_inventory=1},
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

mesecon.delayer_signal_change = function(pos, node)
	if string.find(node.name, "mesecons_delayer:delayer_off")~=nil then
		rules = mesecon.delayer_get_input_rules(node.param2)[1]
		np = {x = pos.x + rules.x, y = pos.y + rules.y, z = pos.z + rules.z}

		if mesecon:is_power_on(np) then
			local time
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
		rules = mesecon.delayer_get_input_rules(node.param2)[1]
		np = {x = pos.x + rules.x, y = pos.y + rules.y, z = pos.z + rules.z}

		if not mesecon:is_power_on(np) then
			local time
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

mesecon:register_on_signal_change(mesecon.delayer_signal_change)

mesecon.delayer_turnon=function(params)
	local rules = mesecon.delayer_get_output_rules(params.param2)
	mesecon:receptor_on(params.pos, rules)
end

mesecon.delayer_turnoff=function(params)
	local rules = mesecon.delayer_get_output_rules(params.param2)
	mesecon:receptor_off(params.pos, rules)
end

mesecon.delayer_get_output_rules = function(param2)
	rules = {}
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
	rules = {}
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

mesecon:add_receptor_node("mesecons_delayer:delayer_on_1", nil, mesecon.delayer_get_output_rules)
mesecon:add_receptor_node("mesecons_delayer:delayer_on_2", nil, mesecon.delayer_get_output_rules)
mesecon:add_receptor_node("mesecons_delayer:delayer_on_3", nil, mesecon.delayer_get_output_rules)
mesecon:add_receptor_node("mesecons_delayer:delayer_on_4", nil, mesecon.delayer_get_output_rules)

mesecon:add_receptor_node_off("mesecons_delayer:delayer_off_1", nil, mesecon.delayer_get_output_rules)
mesecon:add_receptor_node_off("mesecons_delayer:delayer_off_2", nil, mesecon.delayer_get_output_rules)
mesecon:add_receptor_node_off("mesecons_delayer:delayer_off_3", nil, mesecon.delayer_get_output_rules)
mesecon:add_receptor_node_off("mesecons_delayer:delayer_off_4", nil, mesecon.delayer_get_output_rules)
