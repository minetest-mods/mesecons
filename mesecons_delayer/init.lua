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
	if node.name=="mesecons_delayer:delayer_off_1" then
		minetest.env:add_node(pos, {name="mesecons_delayer:delayer_off_2"})
	end
	if node.name=="mesecons_delayer:delayer_off_2" then
		minetest.env:add_node(pos, {name="mesecons_delayer:delayer_off_3"})
	end
	if node.name=="mesecons_delayer:delayer_off_3" then
		minetest.env:add_node(pos, {name="mesecons_delayer:delayer_off_4"})
	end
	if node.name=="mesecons_delayer:delayer_off_4" then
		minetest.env:add_node(pos, {name="mesecons_delayer:delayer_off_1"})
	end
end)

minetest.register_on_punchnode(function (pos, node)
	if node.name=="mesecons_delayer:delayer_on_1" then
		minetest.env:add_node(pos, {name="mesecons_delayer:delayer_on_2"})
	end
	if node.name=="mesecons_delayer:delayer_on_2" then
		minetest.env:add_node(pos, {name="mesecons_delayer:delayer_on_3"})
	end
	if node.name=="mesecons_delayer:delayer_on_3" then
		minetest.env:add_node(pos, {name="mesecons_delayer:delayer_on_4"})
	end
	if node.name=="mesecons_delayer:delayer_on_4" then
		minetest.env:add_node(pos, {name="mesecons_delayer:delayer_on_1"})
	end
end)

mesecon.delayer_signal_change = function(pos, node)
	if string.find(node.name, "mesecons_delayer:delayer_off")~=nil then
		np={x=pos.x-1, y=pos.y, z=pos.z}
		nn=minetest.env:get_node(np)
		if nn.name=="mesecons:mesecon_on" or mesecon:is_receptor_node(nn.name, np, pos) then
			local time
			if node.name=="mesecons_delayer:delayer_off_1" then
				minetest.env:add_node(pos, {name="mesecons_delayer:delayer_on_1"})
				time=0.1
			end
			if node.name=="mesecons_delayer:delayer_off_2" then
				minetest.env:add_node(pos, {name="mesecons_delayer:delayer_on_2"})
				time=0.3
			end
			if node.name=="mesecons_delayer:delayer_off_3" then
				minetest.env:add_node(pos, {name="mesecons_delayer:delayer_on_3"})
				time=0.5
			end
			if node.name=="mesecons_delayer:delayer_off_4" then
				minetest.env:add_node(pos, {name="mesecons_delayer:delayer_on_4"})
				time=1
			end
			minetest.after(time, mesecon.delayer_turnon, {pos=pos})

		end
	end
	if string.find(node.name, "mesecons_delayer:delayer_on")~=nil then
		np={x=pos.x-1, y=pos.y, z=pos.z}
		nn=minetest.env:get_node(np)
		if nn.name=="mesecons:mesecon_off" or mesecon:is_receptor_node_off(nn.name, np, pos) or nn.name=="air" then
			local time
			if node.name=="mesecons_delayer:delayer_on_1" then
				minetest.env:add_node(pos, {name="mesecons_delayer:delayer_off_1"})
				time=0.1
			end
			if node.name=="mesecons_delayer:delayer_on_2" then
				minetest.env:add_node(pos, {name="mesecons_delayer:delayer_off_2"})
				time=0.3
			end
			if node.name=="mesecons_delayer:delayer_on_3" then
				minetest.env:add_node(pos, {name="mesecons_delayer:delayer_off_3"})
				time=0.5
			end
			if node.name=="mesecons_delayer:delayer_on_4" then
				minetest.env:add_node(pos, {name="mesecons_delayer:delayer_off_4"})
				time=1
			end
			minetest.after(time, mesecon.delayer_turnoff, {pos=pos})
		end
	end
end

mesecon:register_on_signal_change(mesecon.delayer_signal_change)

mesecon.delayer_turnon=function(params)
	mesecon:receptor_on(params.pos, mesecon:get_rules("delayer"))
end

mesecon.delayer_turnoff=function(params)
	mesecon:receptor_off(params.pos, mesecon:get_rules("delayer"))
end

mesecon:add_rules("delayer", {{x=1, y=0, z=0}})

mesecon:add_receptor_node("mesecons_delayer:delayer_on_1", mesecon:get_rules("delayer"))
mesecon:add_receptor_node("mesecons_delayer:delayer_on_2", mesecon:get_rules("delayer"))
mesecon:add_receptor_node("mesecons_delayer:delayer_on_3", mesecon:get_rules("delayer"))
mesecon:add_receptor_node("mesecons_delayer:delayer_on_4", mesecon:get_rules("delayer"))

mesecon:add_receptor_node_off("mesecons_delayer:delayer_off_1", mesecon:get_rules("delayer"))
mesecon:add_receptor_node_off("mesecons_delayer:delayer_off_2", mesecon:get_rules("delayer"))
mesecon:add_receptor_node_off("mesecons_delayer:delayer_off_3", mesecon:get_rules("delayer"))
mesecon:add_receptor_node_off("mesecons_delayer:delayer_off_4", mesecon:get_rules("delayer"))
