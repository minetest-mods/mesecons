-- Modified, from minetest_game/mods/doors/init.lua
local function on_rightclick(pos, dir, check_name, replace, replace_dir, params)
	pos.y = pos.y + dir
	if minetest.get_node(pos).name ~= check_name then
		return
	end
	local p2 = minetest.get_node(pos).param2
	p2 = params[p2 + 1]

	minetest.swap_node(pos, {name = replace_dir, param2 = p2})

	pos.y = pos.y - dir
	minetest.swap_node(pos, {name = replace, param2 = p2})

	if (minetest.get_meta(pos):get_int("right") ~= 0) == (params[1] ~= 3) then
		minetest.sound_play("doors_door_close", { pos = pos, gain = 0.3, max_hear_distance = 10 }, true)
	else
		minetest.sound_play("doors_door_open", { pos = pos, gain = 0.3, max_hear_distance = 10 }, true)
	end
end

local function meseconify_door(name)
	if minetest.registered_items[name .. "_b_1"] then
		-- old style double-node doors
		local function toggle_state1 (pos)
			on_rightclick(pos, 1, name.."_t_1", name.."_b_2", name.."_t_2", {1,2,3,0})
		end

		local function toggle_state2 (pos)
			on_rightclick(pos, 1, name.."_t_2", name.."_b_1", name.."_t_1", {3,0,1,2})
		end

		minetest.override_item(name.."_b_1", {
			mesecons = {effector = {
				action_on = toggle_state1,
				action_off = toggle_state1,
				rules = mesecon.rules.pplate
			}}
		})

		minetest.override_item(name.."_b_2", {
			mesecons = {effector = {
				action_on = toggle_state2,
				action_off = toggle_state2,
				rules = mesecon.rules.pplate
			}}
		})
	elseif minetest.registered_items[name .. "_a"] then
		-- new style mesh node based doors
		local override = {
			mesecons = {effector = {
				action_on = function(pos)
					local door = doors.get(pos)
					if door then
						door:open()
					end
				end,
				action_off = function(pos)
					local door = doors.get(pos)
					if door then
						door:close()
					end
				end,
				rules = mesecon.rules.pplate
			}}
		}
		minetest.override_item(name .. "_a", override)
		minetest.override_item(name .. "_b", override)
		if minetest.registered_items[name .. "_c"] then
			minetest.override_item(name .. "_c", override)
			minetest.override_item(name .. "_d", override)
		end
	end
end

meseconify_door("doors:door_wood")
meseconify_door("doors:door_steel")
meseconify_door("doors:door_glass")
meseconify_door("doors:door_obsidian_glass")
meseconify_door("xpanes:door_steel_bar")

-- Trapdoor
local function trapdoor_switch(pos, node)
	local state = minetest.get_meta(pos):get_int("state")

	if state == 1 then
		minetest.sound_play("doors_door_close", { pos = pos, gain = 0.3, max_hear_distance = 10 }, true)
		minetest.set_node(pos, {name="doors:trapdoor", param2 = node.param2})
	else
		minetest.sound_play("doors_door_open", { pos = pos, gain = 0.3, max_hear_distance = 10 }, true)
		minetest.set_node(pos, {name="doors:trapdoor_open", param2 = node.param2})
	end

	minetest.get_meta(pos):set_int("state", state == 1 and 0 or 1)
end

if doors and doors.get then
	local override = {
		mesecons = {effector = {
			action_on = function(pos)
				local door = doors.get(pos)
				if door then
					door:open()
				end
			end,
			action_off = function(pos)
				local door = doors.get(pos)
				if door then
					door:close()
				end
			end,
		}},
	}
	minetest.override_item("doors:trapdoor", override)
	minetest.override_item("doors:trapdoor_open", override)
	minetest.override_item("doors:trapdoor_steel", override)
	minetest.override_item("doors:trapdoor_steel_open", override)

	if minetest.registered_items["xpanes:trapdoor_steel_bar"] then
		minetest.override_item("xpanes:trapdoor_steel_bar", override)
		minetest.override_item("xpanes:trapdoor_steel_bar_open", override)
	end

else
	if minetest.registered_nodes["doors:trapdoor"] then
		minetest.override_item("doors:trapdoor", {
			mesecons = {effector = {
				action_on = trapdoor_switch,
				action_off = trapdoor_switch
			}},
		})

		minetest.override_item("doors:trapdoor_open", {
			mesecons = {effector = {
				action_on = trapdoor_switch,
				action_off = trapdoor_switch
			}},
		})
	end
end
