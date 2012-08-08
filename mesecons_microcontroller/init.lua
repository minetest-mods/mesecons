minetest.register_node("mesecons_microcontroller:microcontroller", {
	description = "Microcontroller",
	drawtype = "nodebox",
	tiles = {"jeija_ic.png"},
	inventory_image = {"jeija_ic.png"},
	sunlight_propagates = true,
	paramtype = "light",
	walkable = true,
	groups = {dig_immediate=2},
	material = minetest.digprop_constanttime(1.0),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.35, 0.5},
	},
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.35, 0.5},
	},
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("code", "")
		meta:set_string("formspec", "size[8,2]"..
			"field[0.256,0.5;8,1;code;Code:;]"..
			"button_exit[3,0.5;2,2;program;Program]")
		meta:set_string("infotext", "Unprogrammed Microcontroller")
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

minetest.register_craft({
	output = 'craft "mesecons_microcontroller:microcontroller" 2',
	recipe = {
		{'mesecons_materials:silicon', 'mesecons_materials:silicon', 'mesecons:mesecon_off'},
		{'mesecons_materials:silicon', 'mesecons_materials:silicon', 'mesecons:mesecon_off'},
		{'mesecons:mesecon_off', 'mesecons:mesecon_off', ''},
	}
})

function reset_yc(pos)
	mesecon:receptor_off(pos, mesecon:get_rules("microcontrollerA"))
	mesecon:receptor_off(pos, mesecon:get_rules("microcontrollerB"))
	mesecon:receptor_off(pos, mesecon:get_rules("microcontrollerC"))
	mesecon:receptor_off(pos, mesecon:get_rules("microcontrollerD"))
end

function update_yc(pos)
	local meta = minetest.env:get_meta(pos)
	local code = meta:get_string("code")
	code = string.gsub(code, " ", "")	--Remove all spaces
	code = string.gsub(code, "	", "")	--Remove all tabs
	if parse_yccode(code, pos) == nil then
		meta:set_string("infotext", "Code not valid!")
	else
		meta:set_string("infotext", "Programmed Microcontroller")
	end
end

function parse_yccode(code, pos)
	local endi = 1
	local L = yc_get_portstates(pos)
	local c
	while true do
		command, endi = parse_get_command(code, endi)
		if command == nil then return nil end
		if command == true then break end
		if command == "if" then
			r, endi = yc_command_if(code, endi, L)
			if r == nil then return nil end
			if r == true then -- nothing
			elseif r == false then
				endi = yc_skip_to_endif(code, endi)
				if endi == nil then return nil end
			end
		else
			params, endi = parse_get_params(code, endi)
			if params  == nil then return nil end
		end
		if command == "on" then
			L = yc_command_on (params, L)
		elseif command == "off" then
			L = yc_command_off(params, L)
		elseif command == "if" then --nothing
		else
			return nil
		end
		if L == nil then return nil end
	end
	yc_action(pos, L)
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

function yc_command_if(code, starti, L)
	local cond, endi = yc_command_if_getcondition(code, starti)
	if cond == nil then return nil end

	cond = yc_command_if_parsecondition(cond, L)

	if cond == "0" then result = false
	elseif cond == "1" then result = true
	else result = nil end
	return result, endi --endi from local cond, endi = yc_command_if_getcondition(code, starti)
end

function yc_command_if_getcondition(code, starti)
	i = starti
	s = nil
	while s ~= "" do
		s = string.sub(code, i, i)
		if s == ")" then
			return string.sub(code, starti, i-1), i + 1 -- i: (; i+1 after (;
		end
		i = i + 1
	end
	return nil, nil
end

function yc_command_if_parsecondition(cond, L)
	cond = string.gsub(cond, "A", tostring(L.a and 1 or 0))
	cond = string.gsub(cond, "B", tonumber(L.b and 1 or 0))
	cond = string.gsub(cond, "C", tonumber(L.c and 1 or 0))
	cond = string.gsub(cond, "D", tonumber(L.d and 1 or 0))

	cond = string.gsub(cond, "!0", "1")
	cond = string.gsub(cond, "!1", "0")

	print(cond)
	local i = 2
	local l = string.len(cond)
	while i<=l do
		local s = cond:sub(i,i)
		local b = tonumber(cond:sub(i-1, i-1))
		local a = tonumber(cond:sub(i+1, i+1))
		if a == "" then print ("ERROR") break end
		if s == "=" then
			print(b.."="..a.."?")
			if a == b  then buf = "1" end
			if a ~= b then buf = "0" end
			cond = string.gsub(cond, b..s..a, buf)
			i = 1
			l = string.len(cond)
		end
		i = i + 1
	end
	print(cond)

	local i = 2
	local l = string.len(cond)
	while i<=l do
		local s = cond:sub(i,i)
		local b = tonumber(cond:sub(i-1, i-1))
		local a = tonumber(cond:sub(i+1, i+1))
		if a == "" then break end
		if s == "&" then
			local buf = ((a==1) and (b==1))
			if buf == true  then buf = "1" end
			if buf == false then buf = "0" end
			cond = string.gsub(cond, b..s..a, buf)
			i = 1
			l = string.len(cond)
		end
		if s == "|" then
			local buf = ((a == 1) or (b == 1))
			if buf == true  then buf = "1" end
			if buf == false then buf = "0" end
			cond = string.gsub(cond, b..s..a, buf)
			i = 1
			l = string.len(cond)
		end
		if s == "~" then
			local buf = (((a == 1) or (b == 1)) and not((a==1) and (b==1)))
			if buf == true  then buf = "1" end
			if buf == false then buf = "0" end
			cond = string.gsub(cond, b..s..a, buf)
			i = 1
			l = string.len(cond)
		end
		i = i + 1
	end
	print(cond)
	return cond
end

function yc_get_port_rules(port)
	local rules = nil
	if port == "A" then
		rules = mesecon:get_rules("microcontrollerA")
	elseif port == "B" then
		rules = mesecon:get_rules("microcontrollerB")
	elseif port == "C" then
		rules = mesecon:get_rules("microcontrollerC")
	elseif port == "D" then
		rules = mesecon:get_rules("microcontrollerD")
	end
	return rules
end

function yc_action(pos, L)
	yc_action_setport("A", L.a, pos)
	yc_action_setport("B", L.b, pos)
	yc_action_setport("C", L.c, pos)
	yc_action_setport("D", L.d, pos)
end

function yc_action_setport(port, state, pos)
	local rules = mesecon:get_rules("microcontroller"..port)
	if state == false then
		if mesecon:is_power_on({x=pos.x+rules[1].x, y=pos.y+rules[1].y, z=pos.z+rules[1].z}) then
			mesecon:turnoff(pos, rules[1].x, rules[1].y, rules[1].z, false)
		end
	elseif state == true then
		if mesecon:is_power_off({x=pos.x+rules[1].x, y=pos.y+rules[1].y, z=pos.z+rules[1].z}) then
			mesecon:turnon(pos, rules[1].x, rules[1].y, rules[1].z, false)
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

function yc_get_portstates(pos)
	rulesA = mesecon:get_rules("microcontrollerA")
	rulesB = mesecon:get_rules("microcontrollerB")
	rulesC = mesecon:get_rules("microcontrollerC")
	rulesD = mesecon:get_rules("microcontrollerD")
	local L = {
		a = mesecon:is_power_on({x=pos.x+rulesA[1].x, y=pos.y+rulesA[1].y, z=pos.z+rulesA[1].z}),
		b = mesecon:is_power_on({x=pos.x+rulesB[1].x, y=pos.y+rulesB[1].y, z=pos.z+rulesB[1].z}),
		c = mesecon:is_power_on({x=pos.x+rulesC[1].x, y=pos.y+rulesC[1].y, z=pos.z+rulesC[1].z}),
		d = mesecon:is_power_on({x=pos.x+rulesD[1].x, y=pos.y+rulesD[1].y, z=pos.z+rulesD[1].z})
	}
	return L
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
	if node.name == "mesecons_microcontroller:microcontroller" then
		minetest.after(0.5, update_yc, pos)
	end
end)


mesecon:add_rules("microcontrollerA", {{x = -1, y = 0, z = 0}})
mesecon:add_rules("microcontrollerB", {{x = 0, y = 0, z = 1}})
mesecon:add_rules("microcontrollerC", {{x = 1, y = 0, z = 0}})
mesecon:add_rules("microcontrollerD", {{x = 0, y = 0, z = -1}})
mesecon:add_rules("microcontroller_default", {})
mesecon:add_receptor_node("mesecons_microcontroller:microcontroller", mesecon:get_rules("microcontroller_default"))
mesecon:add_receptor_node("mesecons_microcontroller:microcontroller", mesecon:get_rules("microcontroller_default"))
