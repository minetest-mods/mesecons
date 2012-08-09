EEPROM_SIZE = 255

for a = 0, 1 do
for b = 0, 1 do
for c = 0, 1 do
for d = 0, 1 do
local nodename = "mesecons_microcontroller:microcontroller"..tostring(d)..tostring(c)..tostring(b)..tostring(a)
if tostring(d)..tostring(c)..tostring(b)..tostring(a) ~= "0000" then
	groups = {dig_immediate=2, not_in_creative_inventory=1}
else
	groups = {dig_immediate=2}
end
minetest.register_node(nodename, {
	description = "Microcontroller",
	drawtype = "nodebox",
	tiles = {
		"jeija_microcontroller_top_"..tostring(d)..tostring(c)..tostring(b)..tostring(a)..".png",
		"jeija_microcontroller_sides.png",
		},
	inventory_image = "jeija_microcontroller_top_0000.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = true,
	groups = groups,
	material = minetest.digprop_constanttime(1.0),
	drop = '"mesecons_microcontroller:microcontroller0000" 1',
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -4/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 }, -- bottom slab
			{ -5/16, -6/16, -5/16, 5/16, -5/16, 5/16 }, -- circuit board
			{ -3/16, -5/16, -3/16, 3/16, -4/16, 3/16 }, -- IC
		}
	},
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("code", "")
		meta:set_string("formspec", "size[8,2]"..
			"field[0.256,0.5;8,1;code;Code:;]"..
			"button_exit[3,0.5;2,2;program;Program]")
		meta:set_string("infotext", "Unprogrammed Microcontroller")
		local r = ""
		for i=1, EEPROM_SIZE+1 do r=r.."0" end --Generate a string with EEPROM_SIZE*"0"
		meta:set_string("eeprom", r)
	end,
	on_receive_fields = function(pos, formanme, fields, sender)
		if fields.program then
			local meta = minetest.env:get_meta(pos)
			meta:set_string("infotext", "Programmed Microcontroller")
			meta:set_string("code", fields.code)
			meta:set_string("formspec", "size[8,2]"..
			"field[0.256,0.5;8,1;code;Code:;"..fields.code.."]"..
			"button_exit[3,0.5;2,2;program;Program]")
			reset_yc (pos)
			update_yc(pos)
		end
	end
})
local rules={}
if (a == 1) then table.insert(rules, {x = -1, y = 0, z =  0}) end
if (b == 1) then table.insert(rules, {x =  0, y = 0, z =  1}) end
if (c == 1) then table.insert(rules, {x =  1, y = 0, z =  0}) end
if (d == 1) then table.insert(rules, {x =  0, y = 0, z = -1}) end
mesecon:add_rules(nodename, rules)
mesecon:add_receptor_node(nodename, rules)
end
end
end
end

minetest.register_craft({
	output = 'craft "mesecons_microcontroller:microcontroller0000" 2',
	recipe = {
		{'mesecons_materials:silicon', 'mesecons_materials:silicon', 'mesecons:mesecon_off'},
		{'mesecons_materials:silicon', 'mesecons_materials:silicon', 'mesecons:mesecon_off'},
		{'mesecons:mesecon_off', 'mesecons:mesecon_off', ''},
	}
})

function reset_yc(pos)
	yc_action(pos, {a=false, b=false, c=false, d=false})
	local meta = minetest.env:get_meta(pos)
	local r = ""
	for i=1, EEPROM_SIZE+1 do r=r.."0" end --Generate a string with EEPROM_SIZE*"0"
	meta:set_string("eeprom", r)
end

function update_yc(pos)
	local meta = minetest.env:get_meta(pos)
	local code = meta:get_string("code")
	code = yc_code_remove_commentary(code)
	code = string.gsub(code, " ", "")	--Remove all spaces
	code = string.gsub(code, "	", "")	--Remove all tabs
	if parse_yccode(code, pos) == nil then
		meta:set_string("infotext", "Code not valid!")
	else
		meta:set_string("infotext", "Working Microcontroller")
	end
end

function yc_code_remove_commentary(code)
	for i = 1, #code do
		if code:sub(i, i) == ":" then
			return code:sub(1, i-1)
		end
	end
	return code
end

function parse_yccode(code, pos)
	local endi = 1
	local Lreal = yc_get_real_portstates(pos)
	local Lvirtual = yc_get_virtual_portstates(pos)
	if Lvirtual == nil then return nil end
	local c
	local eeprom = minetest.env:get_meta(pos):get_string("eeprom")
	while true do
		command, endi = parse_get_command(code, endi)
		if command == nil then return nil end
		if command == true then break end
		if command == "if" then
			r, endi = yc_command_if(code, endi, yc_merge_portstates(Lreal, Lvirtual), eeprom)
			if r == nil then return nil end
			if r == true then  -- nothing
			elseif r == false then
				endi = yc_skip_to_endif(code, endi)
				if endi == nil then return nil end
			end
		else
			params, endi = parse_get_params(code, endi)
			if params  == nil then return nil end
		end
		if command == "on" then
			L = yc_command_on (params, Lvirtual)
		elseif command == "off" then
			L = yc_command_off(params, Lvirtual)
		elseif command == "sbi" then
			new_eeprom = yc_command_sbi (params, eeprom, yc_merge_portstates(Lreal, Lvirtual))
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
	yc_action(pos, Lvirtual)
	return true
end

function parse_get_command(code, starti)
	i = starti
	s = nil
	while s ~= "" do
		s = string.sub(code, i, i)
		if s == ";" and starti == i then 
			starti = starti + 1
			i = starti
			s = string.sub(code, i, i)
		end
		if s == "(" then
			return string.sub(code, starti, i-1), i + 1 -- i: ( i+1 after (
		end
		i = i + 1
	end
	if starti == i-1 then
		return true, true
	end
	return nil, nil
end

function parse_get_params(code, starti)
	i = starti
	s = nil
	local params = {}
	while s ~= "" do
		s = string.sub(code, i, i)
		if s == ")" then
			table.insert(params, string.sub(code, starti, i-1)) -- i: ) i+1 after )
			return params, i + 1
		end
		if s == "," then
			table.insert(params, string.sub(code, starti, i-1)) -- i: ) i+1 after )
			starti = i + 1
		end
		i = i + 1
	end
	return nil, nil
end

function yc_parse_get_eeprom_param(cond, starti)
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

function yc_command_on(params, L)
	local rules = {}
	for i, port in ipairs(params) do
		L = yc_set_portstate (port, true, L)
	end
	return L
end

function yc_command_off(params, L)
	local rules = {}
	for i, port in ipairs(params) do
		L = yc_set_portstate (port, false, L)
	end
	return L
end

function yc_command_sbi(params, eeprom, L)
	if params[1]==nil or params[2]==nil or params[3] ~=nil or tonumber(params[1])==nil then return nil end
	local status = yc_command_parsecondition(params[2], L, eeprom)
	if tonumber(params[1])>EEPROM_SIZE or tonumber(params[1])<1 or (status ~= "0" and status ~= "1") then return nil end
	new_eeprom = "";
	for i=1, #eeprom do
		if tonumber(params[1])==i then 
			new_eeprom = new_eeprom..status
		else
			new_eeprom = new_eeprom..eeprom:sub(i, i)
		end
	end
	return new_eeprom
end

function yc_command_if(code, starti, L, eeprom)
	local cond, endi = yc_command_if_getcondition(code, starti)
	if cond == nil then return nil end

	cond = yc_command_parsecondition(cond, L, eeprom)

	if cond == "0" then result = false
	elseif cond == "1" then result = true
	else result = nil end
	if result == nil then end
	return result, endi --endi from local cond, endi = yc_command_if_getcondition(code, starti)
end

function yc_command_if_getcondition(code, starti)
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

function yc_command_parsecondition(cond, L, eeprom)
	cond = string.gsub(cond, "A", tonumber(L.a and 1 or 0))
	cond = string.gsub(cond, "B", tonumber(L.b and 1 or 0))
	cond = string.gsub(cond, "C", tonumber(L.c and 1 or 0))
	cond = string.gsub(cond, "D", tonumber(L.d and 1 or 0))

	local i = 1
	local l = string.len(cond)
	while i<=l do
		local s = cond:sub(i,i)
		if s == "#" then
			addr, endi = yc_parse_get_eeprom_param(cond, i+1)
			buf = yc_eeprom_read(tonumber(addr), eeprom)
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

function yc_eeprom_read(number, eeprom)
	if number == nil then return nil, nil end
	value = eeprom:sub(number, number)
	if value  == nil then return nil, nil end
	return value, endi
end

function yc_action(pos, L) --L-->Lvirtual
	yc_action_setports(pos, L)

	local meta = minetest.env:get_meta(pos)
	local code = meta:get_string("code")
	local eeprom = meta:get_string("eeprom")
	local infotext   = meta:get_string("infotext")
	local formspec = meta:get_string("formspec")
	local name = "mesecons_microcontroller:microcontroller"
		..tonumber(L.d and 1 or 0)
		..tonumber(L.c and 1 or 0)
		..tonumber(L.b and 1 or 0)
		..tonumber(L.a and 1 or 0)
	minetest.env:add_node(pos, {name=name})
	local meta = minetest.env:get_meta(pos)
	meta:set_string("code", code)
	meta:set_string("eeprom", eeprom)
	meta:set_string("infotext", infotext)
	meta:set_string("formspec", formspec)
end

function yc_action_setports(pos, L)
	local ps = tonumber(L.d and 1 or 0)
		..tonumber(L.c and 1 or 0)
		..tonumber(L.b and 1 or 0)
		..tonumber(L.a and 1 or 0)

	local rulesps
	local rules
	for i=1, 4 do
		if i == 1 then rulesps = "1000" end
		if i == 2 then rulesps = "0100" end
		if i == 3 then rulesps = "0010" end
		if i == 4 then rulesps = "0001" end
		rules = mesecon:get_rules("mesecons_microcontroller:microcontroller"..rulesps)

		if ps:sub(i, i) == "1" then
			if mesecon:is_power_off({x=pos.x+rules[1].x, y=pos.y+rules[1].y, z=pos.z+rules[1].z}) then
				mesecon:receptor_on(pos, rules)
			end
		else
			if mesecon:is_power_on({x=pos.x+rules[1].x, y=pos.y+rules[1].y, z=pos.z+rules[1].z}) then
				mesecon:receptor_off(pos, rules)
			end
		end
	end
end

function yc_set_portstate(port, state, L)
	if port == "A" then L.a = state
	elseif port == "B" then L.b = state
	elseif port == "C" then L.c = state
	elseif port == "D" then L.d = state
	else return nil end
	return L
end

function yc_get_real_portstates(pos)
	rulesA = mesecon:get_rules("mesecons_microcontroller:microcontroller0001")
	rulesB = mesecon:get_rules("mesecons_microcontroller:microcontroller0010")
	rulesC = mesecon:get_rules("mesecons_microcontroller:microcontroller0100")
	rulesD = mesecon:get_rules("mesecons_microcontroller:microcontroller1000")
	local L = {
		a = mesecon:is_power_on({x=pos.x+rulesA[1].x, y=pos.y+rulesA[1].y, z=pos.z+rulesA[1].z}),
		b = mesecon:is_power_on({x=pos.x+rulesB[1].x, y=pos.y+rulesB[1].y, z=pos.z+rulesB[1].z}),
		c = mesecon:is_power_on({x=pos.x+rulesC[1].x, y=pos.y+rulesC[1].y, z=pos.z+rulesC[1].z}),
		d = mesecon:is_power_on({x=pos.x+rulesD[1].x, y=pos.y+rulesD[1].y, z=pos.z+rulesD[1].z})
	}
	return L
end

function yc_get_virtual_portstates(pos)
	name = minetest.env:get_node(pos).name
	b, a = string.find(name, ":microcontroller")
	if a == nil then return nil end
	a = a + 1

	Lvirtual = {false, false, false, false}
	if name:sub(a  , a  ) == "1" then Lvirtual.d = true end
	if name:sub(a+1, a+1) == "1" then Lvirtual.c = true end
	if name:sub(a+2, a+2) == "1" then Lvirtual.b = true end
	if name:sub(a+2, a+3) == "1" then Lvirtual.a = true end
	return Lvirtual
end

function yc_merge_portstates(Lreal, Lvirtual)
	if Lvirtual.a~=nil then Lreal.a = Lvirtual.a end
	if Lvirtual.b~=nil then Lreal.b = Lvirtual.b end
	if Lvirtual.c~=nil then Lreal.c = Lvirtual.c end
	if Lvirtual.d~=nil then Lreal.d = Lvirtual.d end
	return Lreal
end

function yc_skip_to_endif(code, starti)
	local i = starti
	local s = false
	while s ~= nil and s~= "" do
		s = code:sub(i, i)
		if s == ";" then
			return i + 1
		end
		i = i + 1
	end
	return nil
end

mesecon:register_on_signal_change(function(pos, node)
	if string.find(node.name, "mesecons_microcontroller:microcontroller")~=nil then
		minetest.after(0.5, update_yc, pos)
	end
end)
