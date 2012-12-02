EEPROM_SIZE = 255

for a = 0,1 do
for b = 0,1 do
local nodename = "mesecons_22microcontroller:microcontroller_topleft"..tostring(b)..tostring(a)
local top = "jeija_microcontroller22_top_tl.png"
if tostring(a) == "1" then
	top = top.."^jeija_microcontroller_LED_A.png"
end
if tostring(b) == "1" then
	top = top.."^jeija_microcontroller_LED_B.png"
end
if tostring(b)..tostring(a) ~= "00" then
	groups = {dig_immediate=2, not_in_creative_inventory=1, mesecon = 3}
else
	groups = {dig_immediate=2, mesecon = 3}
end
minetest.register_node(nodename, {
	description = "2x2 Microcontroller",
	drawtype = "nodebox",
	tiles = {
		top,
		"jeija_microcontroller_bottom.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png"
		},

	sunlight_propagates = true,
	paramtype = "light",
	walkable = true,
	groups = groups,
	drop = '"mesecons_22microcontroller:microcontroller_topleft00" 1',
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -24/16, 24/16, -5/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 }, -- bottom slab
			{ -5/16, -7/16, -5/16, 5/16, -6/16, 5/16 }, -- circuit board
			{ -3/16, -6/16, -3/16, 3/16, -5/16, 3/16 }, -- IC
		}
	},
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_int("destruct",0)
		meta:set_string("code", "")
		meta:set_string("formspec", "size[9,2.5]"..
			"field[0.256,-0.2;9,2;code;Code:;]"..
			"button[0  ,0.2;1.5,3;band;AND]"..
			"button[1.5,0.2;1.5,3;bxor;XOR]"..
			"button[3  ,0.2;1.5,3;bnot;NOT]"..
			"button[4.5,0.2;1.5,3;bnand;NAND]"..
			"button[6  ,0.2;1.5,3;btflop;T-Flop]"..
			"button[7.5,0.2;1.5,3;brsflop;RS-Flop]"..
			"button_exit[3.5,1;2,3;program;Program]")
		meta:set_string("infotext", "Unprogrammed Microcontroller")
		meta:set_int("heat", 0)
		local r = ""
		for i=1, EEPROM_SIZE+1 do r=r.."0" end --Generate a string with EEPROM_SIZE*"0"
		meta:set_string("eeprom", r)
		local node = minetest.env:get_node(pos)
		node.name="mesecons_22microcontroller:microcontroller_topright00"
		pos.x=pos.x+1
		minetest.env:set_node(pos, node)
		node.name="mesecons_22microcontroller:microcontroller_bottomright00"
		pos.z=pos.z-1
		minetest.env:set_node(pos, node)
		node.name="mesecons_22microcontroller:microcontroller_bottomleft00"
		pos.x=pos.x-1
		minetest.env:set_node(pos, node)
		pos.z=pos.z+1
	end,
	on_destruct = function(pos)
		local meta = minetest.env:get_meta(pos)
		local des=meta:get_int("destruct")
		if des==0 then
		print("Destruction")
		meta:set_int("destruct",1)
		local node = minetest.env:get_node(pos)
		pos.x = pos.x+1
		minetest.env:remove_node(pos)
		pos.z = pos.z-1
		minetest.env:remove_node(pos)
		pos.x = pos.x-1
		minetest.env:remove_node(pos)	
		pos.z=pos.z+1
		end
	end,
	on_receive_fields = function(pos, formanme, fields, sender)
		local meta = minetest.env:get_meta(pos)
		if fields.band then
			fields.code = "sbi(C, A&B) :A and B are inputs, C is output"
		elseif fields.bxor then
			fields.code = "sbi(C, A~B) :A and B are inputs, C is output"
		elseif fields.bnot then
			fields.code = "sbi(B, !A) :A is input, B is output"
		elseif fields.bnand then
			fields.code = "sbi(C, !A|!B) :A and B are inputs, C is output"
		elseif fields.btflop then
			fields.code = "if(A)sbi(1,1);if(!A&#1)sbi(B,!B)sbi(1,0); if(C)off(B,1); :A is input, B is output (Q), C is reset, toggles with falling edge"
		elseif fields.brsflop then
			fields.code = "if(A)on(C);if(B)off(C); :A is S (Set), B is R (Reset), C is output (R dominates)"
		elseif fields.program or fields.code then --nothing
		else return nil end

		meta:set_string("code", fields.code)
		meta:set_string("formspec", "size[9,2.5]"..
		"field[0.256,-0.2;9,2;code;Code:;"..fields.code.."]"..
		"button[0  ,0.2;1.5,3;band;AND]"..
		"button[1.5,0.2;1.5,3;bxor;XOR]"..
		"button[3  ,0.2;1.5,3;bnot;NOT]"..
		"button[4.5,0.2;1.5,3;bnand;NAND]"..
		"button[6  ,0.2;1.5,3;btflop;T-Flop]"..
		"button[7.5,0.2;1.5,3;brsflop;RS-Flop]"..
		"button_exit[3.5,1;2,3;program;Program]")
		meta:set_string("infotext", "Programmed Microcontroller")
		yc22_reset (pos)
		update_yc22(pos)
	end,
})
local rules={}
if (a == 1) then table.insert(rules, {x = -1, y = 0, z =  0}) end
if (b == 1) then table.insert(rules, {x =  0, y = 0, z =  1}) end
local input_rules={}
if (a == 0) then table.insert(input_rules, {x = -1, y = 0, z =  0}) end
if (b == 0) then table.insert(input_rules, {x =  0, y = 0, z =  1}) end
mesecon:add_rules(nodename, rules)

mesecon:register_effector(nodename, nodename, input_rules)
if nodename ~= "mesecons_22microcontroller:microcontroller_topleft00" then
	mesecon:add_receptor_node(nodename, rules)
end
end
end

for c = 0,1 do
for d = 0,1 do
local nodename = "mesecons_22microcontroller:microcontroller_topright"..tostring(d)..tostring(c)
local top = "jeija_microcontroller22_top_tr.png"
if tostring(c) == "1" then
	top = top.."^jeija_microcontroller_LED_B.png"
end
if tostring(d) == "1" then
	top = top.."^jeija_microcontroller_LED_C.png"
end
groups = {dig_immediate=2, not_in_creative_inventory=1, mesecon = 3}
minetest.register_node(nodename, {
	description = "2x2 Microcontroller",
	drawtype = "nodebox",
	tiles = {
		top,
		"jeija_microcontroller_bottom.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png"
		},

	sunlight_propagates = true,
	paramtype = "light",
	walkable = true,
	groups = groups,
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 }, -- bottom slab
			{ -5/16, -7/16, -5/16, 5/16, -6/16, 5/16 }, -- circuit board
			{ -3/16, -6/16, -3/16, 3/16, -5/16, 3/16 }, -- IC
		}
	},
	on_construct=function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_int("destruct",0)
	end,
	on_destruct = function(pos)
		local meta = minetest.env:get_meta(pos)
		local des=meta:get_int("destruct")
		if des==0 then
		meta:set_int("destruct",1)
		local node = minetest.env:get_node(pos)
		pos.z = pos.z-1
		minetest.env:remove_node(pos)
		pos.x = pos.x-1
		minetest.env:remove_node(pos)
		pos.z = pos.z+1
		minetest.env:remove_node(pos)	
		pos.x=pos.x+1
		end
	end,
	selection_box = {
		type = "fixed",
		fixed = { 0,0,0,0,0,0 },
	},
})
local rules={}
if (c == 1) then table.insert(rules, {x = 0, y = 0, z =  1}) end
if (d == 1) then table.insert(rules, {x =  1, y = 0, z =  0}) end
local input_rules={}
if (c == 0) then table.insert(input_rules, {x = 0, y = 0, z =  1}) end
if (d == 0) then table.insert(input_rules, {x =  1, y = 0, z =  0}) end
mesecon:add_rules(nodename, rules)

mesecon:register_effector(nodename, nodename, input_rules)
if nodename ~= "mesecons_22microcontroller:microcontroller_topright00" then
	mesecon:add_receptor_node(nodename, rules)
end
end
end

for e = 0,1 do
for f = 0,1 do
local nodename = "mesecons_22microcontroller:microcontroller_bottomright"..tostring(f)..tostring(e)
local top = "jeija_microcontroller22_top_br.png"
if tostring(e) == "1" then
	top = top.."^jeija_microcontroller_LED_C.png"
end
if tostring(f) == "1" then
	top = top.."^jeija_microcontroller_LED_D.png"
end
groups = {dig_immediate=2, not_in_creative_inventory=1, mesecon = 3}
minetest.register_node(nodename, {
	description = "2x2 Microcontroller",
	drawtype = "nodebox",
	tiles = {
		top,
		"jeija_microcontroller_bottom.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png"
		},

	sunlight_propagates = true,
	paramtype = "light",
	walkable = true,
	groups = groups,
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 }, -- bottom slab
			{ -5/16, -7/16, -5/16, 5/16, -6/16, 5/16 }, -- circuit board
			{ -3/16, -6/16, -3/16, 3/16, -5/16, 3/16 }, -- IC
		}
	},
	on_construct=function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_int("destruct",0)
	end,
	on_destruct = function(pos)
		local meta = minetest.env:get_meta(pos)
		local des=meta:get_int("destruct")
		if des==0 then
		meta:set_int("destruct",1)
		local node = minetest.env:get_node(pos)
		pos.x = pos.x-1
		minetest.env:remove_node(pos)
		pos.z = pos.z+1
		minetest.env:remove_node(pos)
		pos.x = pos.x+1
		minetest.env:remove_node(pos)	
		pos.z=pos.z-1
		end
	end,
	selection_box = {
		type = "fixed",
		fixed = { 0,0,0,0,0,0 },
	},
})
local rules={}
if (e == 1) then table.insert(rules, {x = 1, y = 0, z =  0}) end
if (f == 1) then table.insert(rules, {x =  0, y = 0, z =  -1}) end
local input_rules={}
if (e == 0) then table.insert(input_rules, {x = 1, y = 0, z =  0}) end
if (f == 0) then table.insert(input_rules, {x =  0, y = 0, z =  -1}) end
mesecon:add_rules(nodename, rules)

mesecon:register_effector(nodename, nodename, input_rules)
if nodename ~= "mesecons_22microcontroller:microcontroller_bottomright00" then
	mesecon:add_receptor_node(nodename, rules)
end
end
end

for g = 0,1 do
for h = 0,1 do
local nodename = "mesecons_22microcontroller:microcontroller_bottomleft"..tostring(h)..tostring(g)
local top = "jeija_microcontroller22_top_bl.png"
if tostring(g) == "1" then
	top = top.."^jeija_microcontroller_LED_D.png"
end
if tostring(h) == "1" then
	top = top.."^jeija_microcontroller_LED_A.png"
end
groups = {dig_immediate=2, not_in_creative_inventory=1, mesecon = 3}
minetest.register_node(nodename, {
	description = "2x2 Microcontroller",
	drawtype = "nodebox",
	tiles = {
		top,
		"jeija_microcontroller_bottom.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png"
		},

	sunlight_propagates = true,
	paramtype = "light",
	walkable = true,
	groups = groups,
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 }, -- bottom slab
			{ -5/16, -7/16, -5/16, 5/16, -6/16, 5/16 }, -- circuit board
			{ -3/16, -6/16, -3/16, 3/16, -5/16, 3/16 }, -- IC
		}
	},
	on_construct=function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_int("destruct",0)
	end,
	on_destruct = function(pos)
		local meta = minetest.env:get_meta(pos)
		local des=meta:get_int("destruct")
		if des==0 then
		meta:set_int("destruct",1)
		local node = minetest.env:get_node(pos)
		pos.z = pos.z+1
		minetest.env:remove_node(pos)
		pos.x = pos.x+1
		minetest.env:remove_node(pos)
		pos.z = pos.z-1
		minetest.env:remove_node(pos)	
		pos.x=pos.x-1
		end
	end,
	selection_box = {
		type = "fixed",
		fixed = { 0,0,0,0,0,0 },
	},
})
local rules={}
if (g == 1) then table.insert(rules, {x = 0, y = 0, z =  -1}) end
if (h == 1) then table.insert(rules, {x =  -1, y = 0, z =  0}) end
local input_rules={}
if (g == 0) then table.insert(input_rules, {x = 0, y = 0, z =  -1}) end
if (h == 0) then table.insert(input_rules, {x =  -1, y = 0, z =  0}) end
mesecon:add_rules(nodename, rules)

mesecon:register_effector(nodename, nodename, input_rules)
if nodename ~= "mesecons_22microcontroller:microcontroller_bottomleft00" then
	mesecon:add_receptor_node(nodename, rules)
end
end
end

function yc22_reset(pos)
	yc22_action(pos, {a=false, b=false, c=false, d=false, e=false, f=false, g=false, h=false})
	local meta = minetest.env:get_meta(pos)
	meta:set_int("heat", 0)
	meta:set_int("afterid", 0)
	local r = ""
	for i=1, EEPROM_SIZE+1 do r=r.."0" end --Generate a string with EEPROM_SIZE*"0"
	meta:set_string("eeprom", r)
end


function update_yc22(pos)
	local meta = minetest.env:get_meta(pos)
	yc22_heat(meta)
	minetest.after(0.5, yc22_cool, meta)
	if (yc22_overheat(meta)) then
		minetest.env:remove_node(pos)
		minetest.after(0.2, yc22_overheat_off, pos) --wait for pending parsings
		minetest.env:add_item(pos, "mesecons_22microcontroller:microcontroller_topleft00")
	end

	local code = meta:get_string("code")
	code = yc22_code_remove_commentary(code)
	code = string.gsub(code, " ", "")	--Remove all spaces
	code = string.gsub(code, "	", "")	--Remove all tabs
	if yc22_parsecode(code, pos) == nil then
		meta:set_string("infotext", "Code not valid!\n"..code)
	else
		meta:set_string("infotext", "Working Microcontroller\n"..code)
	end
end

function yc22_code_remove_commentary(code)
	is_string = false
	for i = 1, #code do
		if code:sub(i, i) == '"' then
			is_string = not is_string --toggle is_string
		elseif code:sub(i, i) == ":" and not is_string then
			return code:sub(1, i-1)
		end
	end
	return code
end

function yc22_parsecode(code, pos)
	local meta = minetest.env:get_meta(pos)
	local endi = 1
	local Lreal = yc22_get_real_portstates(pos)
	local Lvirtual = yc22_get_virtual_portstates(pos)
	if Lvirtual == nil then return nil end
	local c
	local eeprom = meta:get_string("eeprom")
	while true do
		command, endi = yc22_parse_get_command(code, endi)
		if command == nil then return nil end
		if command == true then break end --end of code
		if command == "if" then
			r, endi = yc22_command_if(code, endi, yc22_merge_portstates(Lreal, Lvirtual), eeprom)
			if r == nil then return nil end
			if r == true then  -- nothing
			elseif r == false then
				endi_new = yc22_skip_to_else (code, endi)
				if endi_new == nil then --else > not found
					endi = yc22_skip_to_endif(code, endi)
				else
					endi = endi_new
				end
				if endi == nil then return nil end
			end
		else
			params, endi = yc22_parse_get_params(code, endi)
			if params  == nil then return nil end
		end
		if command == "on" then
			L = yc22_command_on (params, Lvirtual)
		elseif command == "off" then
			L = yc22_command_off(params, Lvirtual)
		elseif command == "print" then
			local su = yc22_command_print(params, eeprom, yc22_merge_portstates(Lreal, Lvirtual))
			if su ~= true then return nil end
		elseif command == "after" then
			local su = yc22_command_after(params, pos)
			if su == nil then return nil end
		elseif command == "sbi" then
			new_eeprom, Lvirtual = yc22_command_sbi (params, eeprom, yc22_merge_portstates(Lreal, Lvirtual), Lvirtual)
			if new_eeprom == nil then return nil
			else eeprom = new_eeprom end
		elseif command == "if" then --nothing
		else
			return nil
		end
		if Lvirtual == nil then return nil end
		if eeprom == nil then return nil else
		minetest.env:get_meta(pos):set_string("eeprom", eeprom) end
	end
	yc22_action(pos, Lvirtual)
	return true
end

function yc22_parse_get_command(code, starti)
	i = starti
	s = nil
	while s ~= "" do
		s = string.sub(code, i, i)
		if s == "(" then
			return string.sub(code, starti, i-1), i + 1 -- i: ( i+1 after (
		end
		if s == ";" and starti == i then 
			starti = starti + 1
			i = starti
		elseif s == ">" then
			starti = yc22_skip_to_endif(code, starti)
			if starti == nil then return nil end
			i = starti
		else
			i = i + 1
		end
	end

	if starti == i-1 then
		return true, true
	end
	return nil, nil
end

function yc22_parse_get_params(code, starti)
	i = starti
	s = nil
	local params = {}
	local is_string = false
	while s ~= "" do
		s = string.sub(code, i, i)
		if code:sub(i, i) == '"' then
			is_string = (is_string==false) --toggle is_string
		end
		if s == ")" and is_string == false then
			table.insert(params, string.sub(code, starti, i-1)) -- i: ) i+1 after )
			return params, i + 1
		end
		if s == "," and is_string == false then
			table.insert(params, string.sub(code, starti, i-1)) -- i: ) i+1 after )
			starti = i + 1
		end
		i = i + 1
	end
	return nil, nil
end


function yc22_parse_get_eeprom_param(cond, starti)
	i = starti
	s = nil
	local addr
	while s ~= "" do
		s = string.sub(cond, i, i)
		if string.find("0123456789", s) == nil or s == "" then
			addr = string.sub(cond, starti, i-1) -- i: last number i+1 after last number
			return addr, i
		end
		if s == "," then return nil, nil end
		i = i + 1
	end
	return nil, nil
end

function yc22_skip_to_endif(code, starti)
	local i = starti
	local s = false
	local open_ifs = 1
	while s ~= nil and s~= "" do
		s = code:sub(i, i)
		if s == "i" and code:sub(i+1, i+1) == "f" then --if in µCScript
			open_ifs = open_ifs + 1
		end
		if s == ";" then
			open_ifs = open_ifs - 1
		end
		if open_ifs == 0 then
			return i + 1
		end
		i = i + 1
	end
	return nil
end

function yc22_skip_to_else(code, starti)
	local i = starti
	local s = false
	local open_ifs = 1
	while s ~= nil and s~= "" do
		s = code:sub(i, i)
		if s == "i" and code:sub(i+1, i+1) == "f" then --if in µCScript
			open_ifs = open_ifs + 1
		end
		if s == ";" then
			open_ifs = open_ifs - 1
		end
		if open_ifs == 1 and s == ">" then
			return i + 1
		end
		i = i + 1
	end
	return nil
end

function yc22_command_on(params, L)
	local rules = {}
	for i, port in ipairs(params) do
		L = yc22_set_portstate (port, true, L)
	end
	return L
end

function yc22_command_off(params, L)
	local rules = {}
	for i, port in ipairs(params) do
		L = yc22_set_portstate (port, false, L)
	end
	return L
end

function yc22_command_print(params, eeprom, L)
	local s = ""
	for i, param in ipairs(params) do
		if param:sub(1,1) == '"' and param:sub(#param, #param) == '"' then
			s = s..param:sub(2, #param-1)
		else
			r = yc22_command_parsecondition(param, L, eeprom)
			if r == "1" or r == "0" then
				s = s..r
			else return nil end
		end
	end
	print(s) --don't remove
	return true
end

function yc22_command_sbi(params, eeprom, L, Lv)
	if params[1]==nil or params[2]==nil or params[3] ~=nil then return nil end
	local status = yc22_command_parsecondition(params[2], L, eeprom)

	if status == nil then return nil, nil end

	if string.find("ABCDEFGH", params[1])~=nil and #params[1]==1 then --is a port
		if status == "1" then
			Lv = yc22_set_portstate (params[1], true,  Lv)
		else
			Lv = yc22_set_portstate (params[1], false, Lv)
		end
		return eeprom, Lv;
	end

	--is an eeprom address
	new_eeprom = "";
	for i=1, #eeprom do
		if tonumber(params[1])==i then 
			new_eeprom = new_eeprom..status
		else
			new_eeprom = new_eeprom..eeprom:sub(i, i)
		end
	end
	return new_eeprom, Lv
end

function yc22_command_after(params, pos)
	if params[1] == nil or params[2] == nil or params[3] ~= nil then return nil end

	--get time (maximum time is 200)
	local time = tonumber(params[1])
	if time == nil or time > 200 then
		return nil
	end

	--get code in quotes "code"
	if string.sub(params[2], 1, 1) ~= '"' or string.sub(params[2], #params[2], #params[2]) ~= '"' then return nil end
	local code = string.sub(params[2], 2, #params[2] - 1)

	local afterid = math.random(10000)
	local meta = minetest.env:get_meta(pos)
	meta:set_int("afterid", afterid)
	minetest.after(time, yc22_command_after_execute, {pos = pos, code = code, afterid = afterid})
	return true
end

function yc22_command_after_execute(params)
	local meta = minetest.env:get_meta(params.pos)
	if meta:get_int("afterid") == params.afterid then --make sure the node has not been changed
		if yc22_parsecode(params.code, params.pos) == nil then
			meta:set_string("infotext", "Code in after() not valid!")
		else
			if code ~= nil then
				meta:set_string("infotext", "Working Microcontroller\n"..code)
			else
				meta:set_string("infotext", "Working Microcontroller")
			end
		end
	end
end

--If
function yc22_command_if(code, starti, L, eeprom)
	local cond, endi = yc22_command_if_getcondition(code, starti)
	if cond == nil then return nil end

	cond = yc22_command_parsecondition(cond, L, eeprom)

	if cond == "0" then result = false
	elseif cond == "1" then result = true
	else result = nil end
	if result == nil then end
	return result, endi --endi from local cond, endi = yc22_command_if_getcondition(code, starti)
end

--Condition parsing
function yc22_command_if_getcondition(code, starti)
	i = starti
	s = nil
	local brackets = 1 --1 Bracket to close
	while s ~= "" do
		s = string.sub(code, i, i)
		
		if s == ")" then
			brackets = brackets - 1
		end

		if s == "(" then
			brackets = brackets + 1
		end

		if brackets == 0 then
			return string.sub(code, starti, i-1), i + 1 -- i: ( i+1 after (
		end

		i = i + 1
	end
	return nil, nil
end

function yc22_command_parsecondition(cond, L, eeprom)
	cond = string.gsub(cond, "A", tonumber(L.a and 1 or 0))
	cond = string.gsub(cond, "B", tonumber(L.b and 1 or 0))
	cond = string.gsub(cond, "C", tonumber(L.c and 1 or 0))
	cond = string.gsub(cond, "D", tonumber(L.d and 1 or 0))
	cond = string.gsub(cond, "E", tonumber(L.e and 1 or 0))
	cond = string.gsub(cond, "F", tonumber(L.f and 1 or 0))
	cond = string.gsub(cond, "G", tonumber(L.g and 1 or 0))
	cond = string.gsub(cond, "H", tonumber(L.h and 1 or 0))


	local i = 1
	local l = string.len(cond)
	while i<=l do
		local s = cond:sub(i,i)
		if s == "#" then
			addr, endi = yc22_parse_get_eeprom_param(cond, i+1)
			buf = yc22_eeprom_read(tonumber(addr), eeprom)
			if buf == nil then return nil end
			local call = cond:sub(i, endi-1)
			cond = string.gsub(cond, call, buf)
			i = 0
			l = string.len(cond)
		end
		i = i + 1
	end

	cond = string.gsub(cond, "!0", "1")
	cond = string.gsub(cond, "!1", "0")

	local i = 2
	local l = string.len(cond)
	while i<=l do
		local s = cond:sub(i,i)
		local b = tonumber(cond:sub(i-1, i-1))
		local a = tonumber(cond:sub(i+1, i+1))
		if cond:sub(i+1, i+1) == nil then break end
		if s == "=" then
			if a==nil then return nil end
			if b==nil then return nil end
			if a == b  then buf = "1" end
			if a ~= b then buf = "0" end
			cond = string.gsub(cond, b..s..a, buf)
			i = 1
			l = string.len(cond)
		end
		i = i + 1
	end

	local i = 2 
	local l = string.len(cond)
	while i<=l do
		local s = cond:sub(i,i)
		local b = tonumber(cond:sub(i-1, i-1))
		local a = tonumber(cond:sub(i+1, i+1))
		if cond:sub(i+1, i+1) == nil then break end
		if s == "&" then
			if a==nil then return nil end
			local buf = ((a==1) and (b==1))
			if buf == true  then buf = "1" end
			if buf == false then buf = "0" end
			cond = string.gsub(cond, b..s..a, buf)
			i = 1
			l = string.len(cond)
		end
		if s == "|" then
			if a==nil then return nil end
			local buf = ((a == 1) or (b == 1))
			if buf == true  then buf = "1" end
			if buf == false then buf = "0" end
			cond = string.gsub(cond, b..s..a, buf)
			i = 1
			l = string.len(cond)
		end
		if s == "~" then
			if a==nil then return nil end
			local buf = (((a == 1) or (b == 1)) and not((a==1) and (b==1)))
			if buf == true  then buf = "1" end
			if buf == false then buf = "0" end
			cond = string.gsub(cond, b..s..a, buf)
			i = 1
			l = string.len(cond)
		end
		i = i + 1
	end

	return cond
end

--Virtual-Hardware functions
function yc22_eeprom_read(number, eeprom)
	if number == nil then return nil, nil end
	value = eeprom:sub(number, number)
	if value  == nil then return nil, nil end
	return value, endi
end

--Real I/O functions
function yc22_action(pos, L) --L-->Lvirtual
	local Lv = yc22_get_virtual_portstates(pos)
	local meta = minetest.env:get_meta(pos)
	local metatable = meta:to_table()
	local node=minetest.env:get_node(pos)
	node.name = "mesecons_22microcontroller:microcontroller_topleft"
		..tonumber(L.b and 1 or 0)
		..tonumber(L.a and 1 or 0)
	minetest.env:set_node(pos, node)
	minetest.env:get_meta(pos):from_table(metatable)
	meta = minetest.env:get_meta(pos)
	meta:set_int("destruct",0)
	name = "mesecons_22microcontroller:microcontroller_topright"
		..tonumber(L.d and 1 or 0)
		..tonumber(L.c and 1 or 0)
	pos.x=pos.x+1
	meta = minetest.env:get_meta(pos)
	meta:set_int("destruct",1)
	minetest.env:add_node(pos, {name=name})
	name = "mesecons_22microcontroller:microcontroller_bottomright"
		..tonumber(L.f and 1 or 0)
		..tonumber(L.e and 1 or 0)
	meta = minetest.env:get_meta(pos)
	meta:set_int("destruct",0)
	pos.z=pos.z-1
	meta = minetest.env:get_meta(pos)
	meta:set_int("destruct",1)
	minetest.env:add_node(pos, {name=name})
	name = "mesecons_22microcontroller:microcontroller_bottomleft"
		..tonumber(L.h and 1 or 0)
		..tonumber(L.g and 1 or 0)
	meta = minetest.env:get_meta(pos)
	meta:set_int("destruct",0)
	pos.x=pos.x-1
	meta = minetest.env:get_meta(pos)
	meta:set_int("destruct",1)
	minetest.env:add_node(pos, {name=name})
	meta = minetest.env:get_meta(pos)
	meta:set_int("destruct",0)
	pos.z=pos.z+1

	yc22_action_setports(pos, L, Lv)
end

function yc22_action_setports(pos, L, Lv)
	local name = "mesecons_22microcontroller:microcontroller_"
	local rules
	if Lv.a ~= L.a then
		rules = mesecon:get_rules(name.."topleft01")
		if L.a == true then mesecon:receptor_on(pos, rules)
		else mesecon:receptor_off(pos, rules) end
	end
	if Lv.b ~= L.b then
		rules = mesecon:get_rules(name.."topleft10")
		if L.b == true then mesecon:receptor_on(pos, rules)
		else mesecon:receptor_off(pos, rules) end
	end
	if Lv.c ~= L.c then 
		rules = mesecon:get_rules(name.."topright01")
		pos.x=pos.x+1
		if L.c == true then mesecon:receptor_on(pos, rules)
		else mesecon:receptor_off(pos, rules) end
		pos.x=pos.x-1
	end
	if Lv.d ~= L.d then 
		rules = mesecon:get_rules(name.."topright10")
		pos.x=pos.x+1
		if L.d == true then mesecon:receptor_on(pos, rules)
		else mesecon:receptor_off(pos, rules) end
		pos.x=pos.x-1
	end
	if Lv.e ~= L.e then
		rules = mesecon:get_rules(name.."bottomright01")
		pos.x=pos.x+1
		pos.z=pos.z-1
		if L.e == true then mesecon:receptor_on(pos, rules)
		else mesecon:receptor_off(pos, rules) end
		pos.x=pos.x-1
		pos.z=pos.z+1
	end
	if Lv.f ~= L.f then
		rules = mesecon:get_rules(name.."bottomright10")
		pos.x=pos.x+1
		pos.z=pos.z-1
		if L.f == true then mesecon:receptor_on(pos, rules)
		else mesecon:receptor_off(pos, rules) end
		pos.x=pos.x-1
		pos.z=pos.z+1
	end
	if Lv.g ~= L.g then 
		rules = mesecon:get_rules(name.."bottomleft01")
		pos.z=pos.z-1
		if L.g == true then mesecon:receptor_on(pos, rules)
		else mesecon:receptor_off(pos, rules) end
		pos.z=pos.z+1
	end
	if Lv.h ~= L.h then 
		rules = mesecon:get_rules(name.."bottomleft10")
		pos.z=pos.z-1
		if L.h == true then mesecon:receptor_on(pos, rules)
		else mesecon:receptor_off(pos, rules) end
		pos.z=pos.z+1
	end
end

function yc22_set_portstate(port, state, L)
	if port == "A" then L.a = state
	elseif port == "B" then L.b = state
	elseif port == "C" then L.c = state
	elseif port == "D" then L.d = state
	elseif port == "E" then L.e = state
	elseif port == "F" then L.f = state
	elseif port == "G" then L.g = state
	elseif port == "H" then L.h = state
	else return nil end
	return L
end

function yc22_get_real_portstates(pos)
	rulesA = mesecon:get_rules("mesecons_22microcontroller:microcontroller_topleft01")
	rulesB = mesecon:get_rules("mesecons_22microcontroller:microcontroller_topleft10")
	rulesC = mesecon:get_rules("mesecons_22microcontroller:microcontroller_topright01")
	rulesD = mesecon:get_rules("mesecons_22microcontroller:microcontroller_topright10")
	rulesE = mesecon:get_rules("mesecons_22microcontroller:microcontroller_bottomright01")
	rulesF = mesecon:get_rules("mesecons_22microcontroller:microcontroller_bottomright10")
	rulesG = mesecon:get_rules("mesecons_22microcontroller:microcontroller_bottomleft01")
	rulesH = mesecon:get_rules("mesecons_22microcontroller:microcontroller_bottomleft10")
	L = {
		a = mesecon:is_power_on({x=pos.x+rulesA[1].x, y=pos.y+rulesA[1].y, z=pos.z+rulesA[1].z}) and mesecon:rules_link({x=pos.x+rulesA[1].x, y=pos.y+rulesA[1].y, z=pos.z+rulesA[1].z}, pos),
		b = mesecon:is_power_on({x=pos.x+rulesB[1].x, y=pos.y+rulesB[1].y, z=pos.z+rulesB[1].z}) and mesecon:rules_link({x=pos.x+rulesB[1].x, y=pos.y+rulesB[1].y, z=pos.z+rulesB[1].z}, pos),
		c = mesecon:is_power_on({x=pos.x+rulesC[1].x+1, y=pos.y+rulesC[1].y, z=pos.z+rulesC[1].z}) and mesecon:rules_link({x=pos.x+rulesC[1].x+1, y=pos.y+rulesC[1].y, z=pos.z+rulesC[1].z}, pos),
		d = mesecon:is_power_on({x=pos.x+rulesD[1].x+1, y=pos.y+rulesD[1].y, z=pos.z+rulesD[1].z}) and mesecon:rules_link({x=pos.x+rulesD[1].x+1, y=pos.y+rulesD[1].y, z=pos.z+rulesD[1].z}, pos),
		e = mesecon:is_power_on({x=pos.x+rulesA[1].x+1, y=pos.y+rulesA[1].y, z=pos.z+rulesA[1].z-1}) and mesecon:rules_link({x=pos.x+rulesA[1].x+1, y=pos.y+rulesA[1].y, z=pos.z+rulesA[1].z-1}, pos),
		f = mesecon:is_power_on({x=pos.x+rulesB[1].x+1, y=pos.y+rulesB[1].y, z=pos.z+rulesB[1].z-1}) and mesecon:rules_link({x=pos.x+rulesB[1].x+1, y=pos.y+rulesB[1].y, z=pos.z+rulesB[1].z-1}, pos),
		g = mesecon:is_power_on({x=pos.x+rulesC[1].x, y=pos.y+rulesC[1].y, z=pos.z+rulesC[1].z-1}) and mesecon:rules_link({x=pos.x+rulesC[1].x, y=pos.y+rulesC[1].y, z=pos.z+rulesC[1].z-1}, pos),
		h = mesecon:is_power_on({x=pos.x+rulesD[1].x, y=pos.y+rulesD[1].y, z=pos.z+rulesD[1].z-1}) and mesecon:rules_link({x=pos.x+rulesD[1].x, y=pos.y+rulesD[1].y, z=pos.z+rulesD[1].z-1}, pos)
	}
	return L
end

function yc22_get_virtual_portstates(pos)
	name = minetest.env:get_node(pos).name
	b, a = string.find(name, ":microcontroller_topleft")
	if a == nil then return nil end
	a = a + 1

	Lvirtual = {a=false, b=false, c=false, d=false, e=false, f=false, g=false, h=false}
	if name:sub(a  , a  ) == "1" then Lvirtual.b = true end
	if name:sub(a+1, a+1) == "1" then Lvirtual.a = true end
	
	pos.x=pos.x+1
	name = minetest.env:get_node(pos).name
	b, a = string.find(name, ":microcontroller_topright")
	if a == nil then return nil end
	a = a + 1
	if name:sub(a  , a  ) == "1" then Lvirtual.d = true end
	if name:sub(a+1, a+1) == "1" then Lvirtual.c = true end

	pos.z=pos.z-1
	name = minetest.env:get_node(pos).name
	b, a = string.find(name, ":microcontroller_bottomright")
	if a == nil then return nil end
	a = a + 1
	if name:sub(a  , a  ) == "1" then Lvirtual.f = true end
	if name:sub(a+1, a+1) == "1" then Lvirtual.e = true end
	
	pos.x=pos.x-1
	name = minetest.env:get_node(pos).name
	b, a = string.find(name, ":microcontroller_bottomleft")
	if a == nil then return nil end
	a = a + 1
	if name:sub(a  , a  ) == "1" then Lvirtual.h = true end
	if name:sub(a+1, a+1) == "1" then Lvirtual.g = true end
	pos.z=pos.z+1
	return Lvirtual
end

function yc22_merge_portstates(Lreal, Lvirtual)
	local L = {a=false, b=false, c=false, d=false, e=false, f=false, g=false, h=false}
	if Lvirtual.a or Lreal.a then L.a = true end
	if Lvirtual.b or Lreal.b then L.b = true end
	if Lvirtual.c or Lreal.c then L.c = true end
	if Lvirtual.d or Lreal.d then L.d = true end
	if Lvirtual.e or Lreal.e then L.e = true end
	if Lvirtual.f or Lreal.f then L.f = true end
	if Lvirtual.g or Lreal.g then L.g = true end
	if Lvirtual.h or Lreal.h then L.h = true end
	return L
end

--"Overheat" protection
function yc22_heat(meta)
	h = meta:get_int("heat")
	if h ~= nil then
		meta:set_int("heat", h + 1)
	end
end

function yc22_cool(meta)
	h = meta:get_int("heat")
	if h ~= nil then
		meta:set_int("heat", h - 1)
	end
end

function yc22_overheat(meta)
	h = meta:get_int("heat")
	if h == nil then return true end -- if nil the overheat
	if h>30 then 
		return true
	else 
		return false 
	end
end

function yc22_overheat_off(pos)
	rules = mesecon:get_rules("mesecons_22microcontroller:microcontroller_topleft11")
	mesecon:receptor_off(pos, rules)
	pos.x=pos.x+1
	rules = mesecon:get_rules("mesecons_22microcontroller:microcontroller_topright11")
	mesecon:receptor_off(pos, rules)
	pos.z=pos.z-1
	rules = mesecon:get_rules("mesecons_22microcontroller:microcontroller_bottomright11")
	mesecon:receptor_off(pos, rules)
	pos.x=pos.x-1
	rules = mesecon:get_rules("mesecons_22microcontroller:microcontroller_bottomleft11")
	mesecon:receptor_off(pos, rules)
	pos.z=pos.z+1
end

mesecon:register_on_signal_change(function(pos, node)
	if string.find(node.name, "mesecons_22microcontroller:microcontroller")~=nil then
		update_yc22(pos)
	end
end)

minetest.register_on_dignode(function(pos, node)
	if string.find(node.name, "mesecons_22microcontroller:microcontroller_topleft") then
		rules = mesecon:get_rules(node.name)
		mesecon:receptor_off(pos, rules)
		pos.x=pos.x+1
		rules = mesecon:get_rules("mesecons_22microcontroller:microcontroller_topright11")
		mesecon:receptor_off(pos, rules)
		pos.z=pos.z-1
		rules = mesecon:get_rules("mesecons_22microcontroller:microcontroller_bottomright11")
		mesecon:receptor_off(pos, rules)
		pos.x=pos.x-1
		rules = mesecon:get_rules("mesecons_22microcontroller:microcontroller_bottomleft11")
		mesecon:receptor_off(pos, rules)
		pos.z=pos.z+1
	end
end)

