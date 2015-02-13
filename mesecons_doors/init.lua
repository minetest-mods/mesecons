-- Modified, from minetest_game/mods/doors/init.lua
local function on_rightclick(pos, dir, check_name, replace, replace_dir, params)
	pos.y = pos.y + dir
	if not minetest.get_node(pos).name == check_name then
		return
	end
	local p2 = minetest.get_node(pos).param2
	p2 = params[p2 + 1]

	minetest.swap_node(pos, {name = replace_dir, param2 = p2})

	pos.y = pos.y - dir
	minetest.swap_node(pos, {name = replace, param2 = p2})

	if (minetest.get_meta(pos):get_int("right") ~= 0) == (params[1] ~= 3) then
		minetest.sound_play("door_close", {pos = pos, gain = 0.3, max_hear_distance = 10})
	else
		minetest.sound_play("door_open", {pos = pos, gain = 0.3, max_hear_distance = 10})
	end
end

local function meseconify_door(name)
	if not minetest.registered_items[name] then return end

	local function toggle_state1 (pos, node)
		on_rightclick(pos, 1, name.."_t_1", name.."_b_2", name.."_t_2", {1,2,3,0})
	end

	local function toggle_state2 (pos, node)
		on_rightclick(pos, 1, name.."_t_2", name.."_b_1", name.."_t_1", {3,0,1,2})
	end

	minetest.override_item(name.."_b_1", {
		mesecons = {effector = {
			action_on = toggle_state1,
			action_off = toggle_state1,
			rules = mesecon.rules.pplate
		}},
	})

	minetest.override_item(name.."_b_2", {
		mesecons = {effector = {
			action_on = toggle_state2,
			action_off = toggle_state2,
			rules = mesecon.rules.pplate
		}},
	})
end

meseconify_door("doors:door_wood")
meseconify_door("doors:door_steel")
meseconify_door("doors:door_glass")
meseconify_door("doors:door_obsidian_glass")

-- Trapdoor
local function trapdoor_switch(pos, node)
	local state = minetest.get_meta(pos):get_int("state")

	if state == 1 then
		minetest.sound_play("doors_door_close", {pos = pos, gain = 0.3, max_hear_distance = 10})
		minetest.set_node(pos, {name="doors:trapdoor", param2 = node.param2})
	else
		minetest.sound_play("doors_door_open", {pos = pos, gain = 0.3, max_hear_distance = 10})
		minetest.set_node(pos, {name="doors:trapdoor_open", param2 = node.param2})
	end

	minetest.get_meta(pos):set_int("state", state == 1 and 0 or 1)
end

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
