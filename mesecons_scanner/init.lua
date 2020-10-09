-- mesecons_scanner

local digilines_enabled = minetest.get_modpath("digilines") ~= nil

local scanner_get_output_rules = function(node)
	local rules = {{x = 0, y = 0, z = 1}}
	for i = 0, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end

local scanner_get_input_rules = function(node)
	local rules = {{x = 0, y = 0, z = -1}}
	for i = 0, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end

local function rotated_facedir(node)
	local rules = scanner_get_input_rules(node)
	local dir = rules[1]
	return dir
end

local function update_keys(pos, node)
	local meta = minetest.get_meta(pos)
	local dir = rotated_facedir(node)
	local target = { x=pos.x+dir.x, y=pos.y+dir.y, z=pos.z+dir.z }
	local invs = minetest.get_meta(target):get_inventory():get_lists()
	local keys = {}
	for k,v in pairs(invs) do
		keys[#keys + 1] = k
		if k == meta:get_string("selected_inv") then
			meta:set_string("selected_key", #keys)
		end
	end
	meta:set_string("keys", table.concat(keys, ","))
end

local function update_formspec(pos, meta)
	if digilines_enabled then
		meta:set_string("formspec", "size[6,8]"..
					((default and default.gui_bg) or "")..
					((default and default.gui_bg_img) or "")..
					"label[0,0;Inventory Scanner]"..

					"label[5,0;(?)]"..
					"tooltip[5,0;1,1;Watermark values are in percent of slots occupied with one or more items.;black;white]"..

					"label[0,1;Select inventory]"..
					"dropdown[3,1;3,1;inventory;" .. meta:get_string("keys") .. ";" .. meta:get_string("selected_key") .. "]"..
					"label[0,2;Low watermark]"..
					"field[4,2;2,1;low;;" .. meta:get_int("low_pct") .. "]"..
					"label[0,3;High watermark]"..
					"field[4,3;2,1;high;;" .. meta:get_int("high_pct") .. "]"..

					"label[0,4;Presets]"..
					"button[0,4.5;2,1;empty;Empty]"..
					"button[2,4.5;2,1;has_items;Has items]"..
					"button[4,4.5;2,1;full;Full]"..

					"label[0,6;Digiline Channel (optional)]"..
					"field[4,6;2,1;channel;;" .. meta:get_string("channel") .. "]"..

					"checkbox[0,7;invert;Invert output;".. meta:get_string("invert") .."]"..
					"button_exit[4,7;2,1;save;Save]"..
					""
		)
	else
		meta:set_string("formspec", "size[6,7]"..
					((default and default.gui_bg) or "")..
					((default and default.gui_bg_img) or "")..
					"label[0,0;Inventory Scanner]"..

					"label[5,0;(?)]"..
					"tooltip[5,0;1,1;Watermark values are in percent of slots occupied with one or more items.;black;white]"..

					"label[0,1;Select inventory]"..
					"dropdown[3,1;3,1;inventory;" .. meta:get_string("keys") .. ";" .. meta:get_string("selected_key") .. "]"..
					"label[0,2;Low watermark]"..
					"field[4,2;2,1;low;;" .. meta:get_int("low_pct") .. "]"..
					"label[0,3;High watermark]"..
					"field[4,3;2,1;high;;" .. meta:get_int("high_pct") .. "]"..

					"label[0,4;Presets]"..
					"button[0,4.5;2,1;empty;Empty]"..
					"button[2,4.5;2,1;has_items;Has items]"..
					"button[4,4.5;2,1;full;Full]"..

					"checkbox[0,6;invert;Invert output;".. meta:get_string("invert") .."]"..
					"button_exit[4,6;2,1;save;Save]"..
					""
		)
	end
end

-- Convert input percent to actual inventory slot counts and cache the values
local function update_watermarks(pos, meta)
	local node = minetest.get_node(pos)
	local dir = rotated_facedir(node)
	local i_pos = { x=pos.x+dir.x, y=pos.y+dir.y, z=pos.z+dir.z }
	local i_meta = minetest.get_meta(i_pos)
	local i_name = meta:get_string("selected_inv")
	local i_inv = i_meta:get_inventory()
	local i_size = i_inv:get_size(i_name)

	local low_pct = meta:get_int("low_pct")
	local high_pct = meta:get_int("high_pct")

	local low = math.ceil(i_size * (low_pct / 100.0))
	local high = math.floor(i_size * (high_pct / 100.0))

	meta:set_int("low", low)
	meta:set_int("high", high)
end

local function on_receive_fields(pos, form_name, fields, sender)
	local meta = minetest.get_meta(pos)
	if fields.inventory then
		meta:set_string("selected_inv", fields.inventory)
	end
	if fields.channel then
		meta:set_string("channel", fields.channel)
	end
	if fields.low then
		meta:set_int("low_pct", fields.low)
	end
	if fields.high then
		meta:set_int("high_pct", fields.high)
	end
	if fields.invert then
		meta:set_string("invert", fields.invert)
	end
	-- Buttons
	if fields.empty then
		meta:set_int("low_pct", 0)
		meta:set_int("high_pct", 0)
		meta:set_string("invert", "false")
	elseif fields.has_items then
		meta:set_int("low_pct", 1)
		meta:set_int("high_pct", 100)
		meta:set_string("invert", "false")
	elseif fields.full then
		meta:set_int("low_pct", 100)
		meta:set_int("high_pct", 100)
		meta:set_string("invert", "false")
	end
	update_formspec(pos, meta)
	update_watermarks(pos, meta)
end

local function set_receptor(pos, output, rules)
	if output then
		mesecon.receptor_on(pos, rules)
	else
		mesecon.receptor_off(pos, rules)
	end
end

local boxes = {
	 { -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },		-- the bottom slab
	 { -7/16, -7/16, -4/16, 4/16, -4/16, 4/16 },		-- the "box"
	 { -8/16, -7/16, -5/16, -7/16, -3/16, 5/16 },		-- the back plate in YZ plane
}

mesecon.register_node("mesecons_scanner:mesecon_scanner", {
	paramtype2="facedir",
	description = "Inventory scanner",
	is_ground_content = false,
	sunlight_propagates = true,
	inventory_image = "mesecons_scanner_preview.png",
	drawtype = "nodebox",
	wield_image = "mesecons_scanner_preview.png",
	selection_box = {
		type = "fixed",
		fixed =	{
			{ -8/16, -8/16, -8/16,  8/16, -3/16, 8/16 },
		}
	},
	node_box = {
		type = "fixed",
		fixed = boxes
	},
	after_dig_node = function (pos, node)
		mesecon.do_cooldown(pos)
		mesecon.receptor_off(pos, output_rules)
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local node = minetest.get_node(pos)
		meta:set_string("selected_inv", "main")
		-- Default behavior is output signal on "has items"
		meta:set_int("low_pct", 1)
		meta:set_int("high_pct", 100)
		meta:set_string("invert", "false")
		meta:set_string("output", "off")
		update_keys(pos, node)
		update_watermarks(pos, meta)
		update_formspec(pos, meta)
		minetest.get_node_timer(pos):start(1)
	end,
	on_receive_fields = on_receive_fields,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		-- Update in case the node behind the scanner has changed
		update_keys(pos, node)
		update_formspec(pos, meta)
	end,
	on_timer = function (pos, elapsed)
		local meta = minetest.get_meta(pos)
		local node = minetest.get_node(pos)
		local dir = rotated_facedir(node)
		local invert = meta:get_string("invert") == "true"
		local old_output = meta:get_string("output") == "on"

		-- Get watermark values in converted from percent to # slots
		local low = meta:get_int("low")
		local high = meta:get_int("high")

		-- Get the inventory of the node behind our scanner
		local i_pos = { x=pos.x+dir.x, y=pos.y+dir.y, z=pos.z+dir.z }
		local i_meta = minetest.get_meta(i_pos)
		local i_inv = i_meta:get_inventory()
		local output = false
		local i_name = meta:get_string("selected_inv")
		local i_size = i_inv:get_size(i_name)
		meta:set_int("inventory_size", i_size)
		local count = 0
		if i_size > 0 then
			-- Get number of slots with items in them
			for i = 1, i_size do
				if not i_inv:get_stack(i_name, i):is_empty() then count = count + 1 end
			end
			-- Calculate our output
			output = (count >= low and count <= high)
			if invert then
				output = not output
			end
		end
		meta:set_int("current", count)

		-- Update node
		local output_string = (output and "on") or "off"
		set_receptor(pos, output, {scanner_get_output_rules(node)})
		mesecon.setstate(pos, node, output_string)

		-- Save the new state
		meta:set_string("output", output_string)

		-- Send digiline message on change
		if old_output ~= output then
			if digilines_enabled and meta:get_string("channel") ~= "" then
				digilines.receptor_send(pos, digilines.rules.default,
							meta:get_string("channel"),
							{ output = output_string }
				)
			end
		end
		return true
	end,
	digiline = {
		receptor = {action = function() end},
		effector = {
			action = function(pos, node, channel, msg)
				local meta = minetest.get_meta(pos)
				if channel ~= meta:get_string("channel") then
					return
				end
				if type(msg) == "table" then
					if msg.inventory then
						meta:set_string("selected_inv", msg.inventory)
					end
					if msg.low then
						-- 0-100
						meta:set_int("low_pct", msg.low)
					end
					if msg.high then
						-- 0-100
						meta:set_int("high_pct", msg.high)
					end
					if msg.invert then
						-- "true" or "false"
						meta:set_string("invert", msg.invert)
					end
					update_watermarks(pos, meta)
				else
					if msg == "GET" or msg == "get" then
						local size = meta:get_int("inventory_size")
						local current = meta:get_int("current")
						local current_pct = 0
						if size > 0 and current > 0 then
							current_pct = math.ceil((100 * current) / size)
						end
						digilines.receptor_send(pos, digilines.rules.default, channel, {
							output = meta:get_string("output"),
							inventory = meta:get_string("selected_inv"),
							low = meta:get_int("low_pct"),
							high = meta:get_int("high_pct"),
							current = current_pct,
						})
					end
				end
			end
		},
	},

},{
	groups = { dig_immediate=2 },
	tiles = {
		-- top
		"mesecons_scanner_top_off.png",
		-- bottom
		"mesecons_scanner_bottom.png",
		-- side 1 (since we are rotated names don't match)
		"mesecons_scanner_front_off.png",
		-- side 2
		"mesecons_scanner_back.png",
		-- front
		"mesecons_scanner_right_off.png",
		-- back
		"mesecons_scanner_left_off.png",
	},
	mesecons = { receptor = { state = mesecon.state.off } }
},{
	groups = { dig_immediate=2, not_in_creative_inventory=1 },
	tiles = {
		"mesecons_scanner_top_on.png",
		"mesecons_scanner_bottom.png",
		"mesecons_scanner_front_on.png",
		"mesecons_scanner_back.png",
		"mesecons_scanner_right_on.png",
		"mesecons_scanner_left_on.png",
	},
	mesecons = { receptor = { state = mesecon.state.off } }
})

minetest.register_craft({
	output = "mesecons_scanner:mesecon_scanner_off 1",
	recipe = {
		{"", "group:mesecon_conductor_craftable", ""},
		{"", "mesecons_microcontroller:microcontroller0000", ""},
		{"default:stone", "default:stone", "default:stone"},
	}
})
