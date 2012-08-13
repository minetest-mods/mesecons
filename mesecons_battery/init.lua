for i = 1, 5 do
	minetest.register_node("mesecons_battery:battery_charging_"..i, {
		drawtype = "nodebox",
		tiles = {"jeija_battery_charging.png"},
		paramtype = "light",
		is_ground_content = true,
		walkable = true,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.499, -0.499, -0.499, -0.4,   0.499,       0.499},
				{ 0.4, -0.499, -0.499,  0.499,   0.499,       0.499},
				{-0.499, -0.499, -0.499,  0.499, 0.499,      -0.4  },
				{-0.499, -0.499,  0.4,  0.499, 0.499,       0.499  },
				{-0.4  , -0.5  , -0.4  ,  0.4  , 1*(i/5)-0.5, 0.4}}
		},

		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		},
		groups = {dig_immediate=2, mesecon = 2},
	    	description="Battery",
	})
end

for i = 1, 5 do
	minetest.register_node("mesecons_battery:battery_discharging_"..i, {
		drawtype = "nodebox",
		tiles = {"jeija_battery_discharging.png"},
		paramtype = "light",
		is_ground_content = true,
		walkable = true,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.499, -0.499, -0.499, -0.4,   0.499,       0.499},
				{ 0.4, -0.499, -0.499,  0.499,   0.499,       0.499},
				{-0.499, -0.499, -0.499,  0.499, 0.499,      -0.4  },
				{-0.499, -0.499,  0.4,  0.499, 0.499,       0.499  },
				{-0.4  , -0.5  , -0.4  ,  0.4  , 1*(i/5)-0.5, 0.4}}
		},

		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		},
		groups = {dig_immediate=2, not_in_creative_inventory=1, mesecon = 2},
	    	description="Battery",
	})
	mesecon:add_receptor_node("mesecons_battery:battery_discharging_"..i)
	mesecon:register_effector("mesecons_battery:battery_discharging_"..i, "mesecons_battery:battery_charging_"..i)
end

minetest.register_on_placenode(function (pos, newnode, placer)
	if string.find(newnode.name, "mesecons_battery:battery") then
		meta = minetest.env:get_meta(pos)
		meta:set_int("batterystate", tonumber(string.sub(newnode.name, string.len(newnode.name)))*20-19)
		meta:set_int("charging", 0)
	end
end)

minetest.register_on_punchnode(function(pos, node, puncher)
	if string.find(node.name, "mesecons_battery:battery_charging") then
		local meta = minetest.env:get_meta(pos);
		local batterystate = meta:get_int("batterystate")
		local charging = meta:get_int("charging")
		minetest.env:remove_node(pos)
		minetest.env:place_node(pos, {name=string.gsub(node.name, "charging", "discharging")})
		mesecon:receptor_on(pos)
		meta:set_int("batterystate", batterystate)
		meta:set_int("charging", charging)
	end
	if string.find(node.name, "mesecons_battery:battery_discharging") then
		local meta = minetest.env:get_meta(pos);
		local batterystate = meta:get_int("batterystate")
		local charging = meta:get_int("charging")
		minetest.env:remove_node(pos)
		minetest.env:place_node(pos, {name=string.gsub(node.name, "discharging", "charging")})
		mesecon:receptor_off(pos)
		meta:set_int("batterystate", batterystate)
		meta:set_int("charging", charging)
	end
end)

minetest.register_abm({
nodenames = {"mesecons_battery:battery_charging_1", "mesecons_battery:battery_charging_2", "mesecons_battery:battery_charging_3", "mesecons_battery:battery_charging_4", "mesecons_battery:battery_charging_5"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.env:get_meta(pos);
		if meta:get_int("charging") == 1 then
			local batterystate = meta:get_int("batterystate")
			local charging = meta:get_int("charging")
			local name = node.name;
			if batterystate < 100 then --change battery charging state
				batterystate = batterystate + 1
			else
				node.name=string.gsub(node.name, "charging", "discharging")
				mesecon:receptor_on(pos)
			end

			if string.find(node.name, tostring(math.ceil(batterystate/20))) == nil then
				node.name = string.gsub(node.name, tostring(math.ceil(batterystate/20)-1), tostring(math.ceil(batterystate/20))) --change node for new nodebox model
			end
			minetest.env:add_node(pos, node)
			meta:set_int("batterystate", batterystate)
			meta:set_int("charging", charging)
		end
	end,
})

minetest.register_abm({
nodenames = {"mesecons_battery:battery_discharging_1", "mesecons_battery:battery_discharging_2", "mesecons_battery:battery_discharging_3", "mesecons_battery:battery_discharging_4", "mesecons_battery:battery_discharging_5"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.env:get_meta(pos);
		local batterystate = meta:get_int("batterystate")
		local charging = meta:get_int("charging")
		local name = node.name;
		if batterystate > 1 then --change battery charging state
			batterystate = batterystate - 1
		else
			node.name=string.gsub(node.name, "discharging", "charging")
			mesecon:receptor_off(pos)
		end

		if string.find(node.name, tostring(math.ceil(batterystate/20))) == nil then
			node.name = string.gsub(node.name, tostring(math.ceil(batterystate/20)+1), tostring(math.ceil(batterystate/20))) --change node for new nodebox model
		end
		minetest.env:add_node(pos, node)
		meta:set_int("batterystate", batterystate)
		meta:set_int("charging", charging)
	end,
})


mesecon:register_on_signal_on(function(pos, node)
	if string.find(node.name, "mesecons_battery:battery") then
		minetest.env:get_meta(pos):set_int("charging", 1)
	end
end)

mesecon:register_on_signal_off(function(pos, node)
	if string.find(node.name, "mesecons_battery:battery") then
		minetest.env:get_meta(pos):set_int("charging", 0)
	end
end)
