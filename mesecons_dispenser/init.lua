minetest.register_node("mesecons_dispenser:dispenser", {
	description = "Dispenser",
	tiles = {"mesecons_dispenser_top.png" , "mesecons_dispenser_bottom.png",
		 "mesecons_dispenser_side.png", "mesecons_dispenser_side.png"   ,
		 "mesecons_dispenser_side.png", "mesecons_dispenser_front.png"},
	paramtype2 = "facedir",
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("formspec",
				"size[8,7]"..
				"list[current_name;main;2.5,0;3,3;]"..
				"list[current_player;main;0,3;8,4;]")
		local inv = meta:get_inventory()
		inv:set_size("main", 3*3)
	end,
	mesecons = {effector={
		action_on = function (pos, node)
			local dir = {{x=1, y=0, z=0}}
			for _ = 0, node.param2 do
				dir = mesecon:rotate_rules_left(dir)
			end
			dir = dir[1]
			local objpos = mesecon:addPosRule(pos, {x=dir.x/2, y=dir.y/2, z=dir.z/2})
			--minetest.env:add_node(mesecon:addPosRule(pos, dir[1]), {name="default:wood"})
			local inv = minetest.env:get_meta(pos):get_inventory()
			local stacks = {}
			for j = 1, 9 do
				local ts = inv:get_stack("main", j)
				if not ts:is_empty() then
					table.insert(stacks, {stack = ts, id = j})
				end
			end
			print(dump(stacks))
			if #stacks > 0 then
				local sn = math.random(1, #stacks)
				local takenitem = stacks[sn].stack:take_item()
				inv:set_stack("main", stacks[sn].id, stacks[sn].stack)
				print(dump(takenitem:to_table()))
				local obj = minetest.env:add_item(objpos, takenitem:to_table())
				obj:setvelocity({	x=dir.x*5+math.random(1, 100)/50-0.5,
							y=dir.y*5+math.random(1, 100)/50-0.5,
							z=dir.z*5+math.random(1, 100)/50-0.5})
			end
		end
	}},
})

minetest.register_craft({
	output = 'mesecons_dispenser:dispenser',
	recipe = {
		{"default:cobble", "default:cobble", "default:cobble"},
		{"default:cobble", "mesecons_materials:fiber", "default:cobble"},
		{"default:cobble", "group:mesecon_conductor_craftable", "default:cobble"},
	}
})
