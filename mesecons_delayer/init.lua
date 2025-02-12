local S = minetest.get_translator(minetest.get_current_modname())

-- Function that get the input/output rules of the delayer
local delayer_get_output_rules = mesecon.horiz_rules_getter({{x = 1, y = 0, z = 0}})

local delayer_get_input_rules = mesecon.horiz_rules_getter({{x = -1, y = 0, z = 0}})

-- Functions that are called after the delay time

local delayer_activate = function(pos, node)
	local def = minetest.registered_nodes[node.name]
	local time = def.delayer_time
	minetest.swap_node(pos, {name = def.delayer_onstate, param2=node.param2})
	mesecon.queue:add_action(pos, "receptor_on", {delayer_get_output_rules(node)}, time, nil)
end

local delayer_deactivate = function(pos, node)
	local def = minetest.registered_nodes[node.name]
	local time = def.delayer_time
	minetest.swap_node(pos, {name = def.delayer_offstate, param2=node.param2})
	mesecon.queue:add_action(pos, "receptor_off", {delayer_get_output_rules(node)}, time, nil)
end

-- Register the 2 (states) x 4 (delay times) delayers

local delaytime = { 0.1, 0.3, 0.5, 1.0 }

for i = 1, 4 do

-- Delayer definition defaults
local def = {
	drawtype = "nodebox",
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or nil,
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 }, -- bottom slab
			{ -6/16, -7/16, -6/16, 6/16, -6/16, 6/16 }
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	delayer_time = delaytime[i],
	sounds = mesecon.node_sound.stone,
	on_blast = mesecon.on_blastnode,
	drop = "mesecons_delayer:delayer_off_1",
	delayer_onstate = "mesecons_delayer:delayer_on_"..tostring(i),
	delayer_offstate = "mesecons_delayer:delayer_off_"..tostring(i),
}

-- Deactivated delayer definition defaults
local off_groups = {bendy=2,snappy=1,dig_immediate=2}
if i > 1 then
	off_groups.not_in_creative_inventory = 1
end

local off_state = {
	description = S("Delayer"),
	inventory_image = "jeija_gate_off.png^jeija_delayer.png",
	wield_image = "jeija_gate_off.png^jeija_delayer.png",
	tiles = {
		"jeija_microcontroller_bottom.png^jeija_gate_output_off.png^jeija_gate_off.png^"..
			"jeija_delayer.png^mesecons_delayer_"..tostring(i)..".png",
		"jeija_microcontroller_bottom.png^jeija_gate_output_off.png",
		"jeija_gate_side.png^jeija_gate_side_output_off.png",
		"jeija_gate_side.png",
		"jeija_gate_side.png",
		"jeija_gate_side.png",
	},
	groups = off_groups,
	on_punch = function(pos, node, puncher)
		if minetest.is_protected(pos, puncher and puncher:get_player_name() or "") then
			return
		end

		minetest.swap_node(pos, {
			name = "mesecons_delayer:delayer_off_"..tostring(i % 4 + 1),
			param2 = node.param2
		})
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
			action_off = delayer_deactivate,
			action_on = delayer_activate
		}
	},
}
for k, v in pairs(def) do
	off_state[k] = off_state[k] or v
end
minetest.register_node("mesecons_delayer:delayer_off_"..tostring(i), off_state)

-- Activated delayer definition defaults
local on_state = {
	--## It makes no sense to leave such an Easter egg here. It's literally useless! ##--
	--description = "You hacker you",
	inventory_image = "jeija_gate_on.png^jeija_delayer.png",
	wield_image = "jeija_gate_on.png^jeija_delayer.png",
	tiles = {
		"jeija_microcontroller_bottom.png^jeija_gate_output_on.png^jeija_gate_on.png^"..
			"jeija_delayer.png^mesecons_delayer_"..tostring(i)..".png",
		"jeija_microcontroller_bottom.png^jeija_gate_output_on.png",
		"jeija_gate_side.png^jeija_gate_side_output_on.png",
		"jeija_gate_side.png",
		"jeija_gate_side.png",
		"jeija_gate_side.png",
	},
	groups = {bendy = 2, snappy = 1, dig_immediate = 2, not_in_creative_inventory = 1},
	on_punch = function(pos, node, puncher)
		if minetest.is_protected(pos, puncher and puncher:get_player_name() or "") then
			return
		end

		minetest.swap_node(pos, {
			name = "mesecons_delayer:delayer_on_"..tostring(i % 4 + 1),
			param2 = node.param2
		})
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
			action_off = delayer_deactivate,
			action_on = delayer_activate
		}
	},
}
for k, v in pairs(def) do
	on_state[k] = on_state[k] or v
end
minetest.register_node("mesecons_delayer:delayer_on_"..tostring(i), on_state)

end

minetest.register_craft({
	output = "mesecons_delayer:delayer_off_1",
	recipe = {
		{"mesecons_torch:mesecon_torch_on", "group:mesecon_conductor_craftable", "mesecons_torch:mesecon_torch_on"},
		{"mesecons_gamecompat:cobble","mesecons_gamecompat:cobble", "mesecons_gamecompat:cobble"},
	}
})
