local other_state_node = {}
for _, material in ipairs({
	{ id = "wood", desc = "Wooden", color = "brown" },
	{ id = "steel", desc = "Steel", color = "grey" },
}) do
	doors:register_door("mesecons_doors:op_door_"..material.id, {
		description = "Mesecon-operated "..material.desc.." Door",
		inventory_image = minetest.registered_items["doors:door_"..material.id].inventory_image,
		groups = minetest.registered_nodes["doors:door_"..material.id.."_b_1"].groups,
		tiles_bottom = {"door_"..material.id.."_b.png", "door_"..material.color..".png"},
		tiles_top = {"door_"..material.id.."_a.png", "door_"..material.color..".png"},
	})
	local groups_plus_mesecon = { mesecon = 2 }
	for k, v in pairs(minetest.registered_nodes["doors:door_"..material.id.."_b_1"].groups) do
		groups_plus_mesecon[k] = v
	end
	doors:register_door("mesecons_doors:sig_door_"..material.id, {
		description = "Mesecon-signalling "..material.desc.." Door",
		inventory_image = minetest.registered_items["doors:door_"..material.id].inventory_image,
		groups = groups_plus_mesecon,
		tiles_bottom = {"door_"..material.id.."_b.png", "door_"..material.color..".png"},
		tiles_top = {"door_"..material.id.."_a.png", "door_"..material.color..".png"},
	})
	for _, thishalf in ipairs({ "t", "b" }) do
		local otherhalf = thishalf == "t" and "b" or "t"
		local otherdir = thishalf == "t" and -1 or 1
		for orientation = 1, 2 do
			local thissuffix = material.id.."_"..thishalf.."_"..orientation
			local othersuffix = material.id.."_"..otherhalf.."_"..orientation
			local thisopname = "mesecons_doors:op_door_"..thissuffix
			local otheropname = "mesecons_doors:op_door_"..othersuffix
			local oponr = minetest.registered_nodes[thisopname].on_rightclick
			local function handle_mesecon_signal (thispos, thisnode, signal)
				local thismeta = minetest.get_meta(thispos)
				if signal == thismeta:get_int("sigstate") then return end
				thismeta:set_int("sigstate", signal)
				local otherpos = { x = thispos.x, y = thispos.y + otherdir, z = thispos.z }
				if minetest.get_node(otherpos).name ~= otheropname then return end
				local othermeta = minetest.get_meta(otherpos)
				local newdoorstate = math.max(thismeta:get_int("sigstate"), othermeta:get_int("sigstate"))
				if newdoorstate == thismeta:get_int("doorstate") then return end
				oponr(thispos, thisnode, nil)
				thismeta:set_int("doorstate", newdoorstate)
				othermeta:set_int("doorstate", newdoorstate)
			end
			minetest.override_item(thisopname, {
				on_construct = function (pos)
					if mesecon:is_powered(pos) then
						local node = minetest.get_node(pos)
						mesecon:changesignal(pos, node, mesecon:effector_get_rules(node), "on", 1)
						mesecon:activate(pos, node, nil, 1)
					end
				end,
				on_rightclick = function (pos, node, clicker) end,
				mesecons = {
					effector = {
						action_on = function (pos, node)
							handle_mesecon_signal(pos, node, 1)
						end,
						action_off = function (pos, node)
							handle_mesecon_signal(pos, node, 0)
						end,
					},
				},
			})
			local thissigname = "mesecons_doors:sig_door_"..thissuffix
			local othersigname = "mesecons_doors:sig_door_"..othersuffix
			local sigonr = minetest.registered_nodes[thissigname].on_rightclick
			minetest.override_item(thissigname, {
				on_rightclick = function (thispos, thisnode, clicker)
					local otherpos = { x = thispos.x, y = thispos.y + otherdir, z = thispos.z }
					print("open: otherpos.name="..minetest.get_node(otherpos).name..", othersigname="..othersigname)
					if minetest.get_node(otherpos).name ~= othersigname then return end
					sigonr(thispos, thisnode, clicker)
					for _, pos in ipairs({ thispos, otherpos }) do
						local node = minetest.get_node(pos)
						node.name = other_state_node[node.name]
						minetest.swap_node(pos, node)
						mesecon:receptor_on(pos)
					end
				end,
				mesecons = { receptor = { state = mesecon.state.off } },
			})
			other_state_node[thissigname] = thissigname.."_on"
			local ondef = {}
			for k, v in pairs(minetest.registered_nodes[thissigname]) do
				ondef[k] = v
			end
			ondef.on_rightclick = function (thispos, thisnode, clicker)
				local otherpos = { x = thispos.x, y = thispos.y + otherdir, z = thispos.z }
				print("close: otherpos.name="..minetest.get_node(otherpos).name..", othersigname="..othersigname)
				if minetest.get_node(otherpos).name ~= othersigname.."_on" then return end
				for _, pos in ipairs({ thispos, otherpos }) do
					local node = minetest.get_node(pos)
					node.name = other_state_node[node.name]
					minetest.swap_node(pos, node)
					mesecon:receptor_off(pos)
				end
				sigonr(thispos, thisnode, clicker)
			end
			ondef.mesecons = { receptor = { state = mesecon.state.on } }
			ondef.after_destruct = function (thispos, thisnode)
				local otherpos = { x = thispos.x, y = thispos.y + otherdir, z = thispos.z }
				if minetest.get_node(otherpos).name == othersigname.."_on" then
					minetest.remove_node(otherpos)
					mesecon:receptor_off(otherpos)
				end
			end
			other_state_node[thissigname.."_on"] = thissigname
			ondef.mesecon_other_state_node = thissigname
			minetest.register_node(thissigname.."_on", ondef)
		end
	end
	minetest.register_craft({
		output = "mesecons_doors:op_door_"..material.id,
		recipe = {
			{ "group:mesecon_conductor_craftable", "", "" },
			{ "", "doors:door_"..material.id, "group:mesecon_conductor_craftable" },
			{ "group:mesecon_conductor_craftable", "", "" },
		},
	})
	minetest.register_craft({
		output = "mesecons_doors:sig_door_"..material.id,
		recipe = {
			{ "", "", "group:mesecon_conductor_craftable" },
			{ "group:mesecon_conductor_craftable", "doors:door_"..material.id, "" },
			{ "", "", "group:mesecon_conductor_craftable" },
		},
	})
end
