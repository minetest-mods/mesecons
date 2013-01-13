-- Reference
-- ports = get_real_portstates(pos): gets if inputs are powered from outside
-- newport = merge_portstates(state1, state2): just does result = state1 or state2 for every port
-- action_setports(pos, ports, vports): activates/deactivates the mesecons according to the portstates (helper for action)
-- action(pos, ports): Applies new portstates to a luacontroller at pos
-- update(pos): updates the controller at pos by executing the code
-- reset_meta (pos, code, errmsg): performs a software-reset, installs new code and prints error messages
-- reset (pos): performs a hardware reset, turns off all ports
--
-- The Sandbox
-- The whole code of the controller runs in a sandbox,
-- a very restricted environment.
-- However, as this does not prevent you from using e.g. loops,
-- we need to check for these prohibited commands first.
-- Actually the only way to damage the server is to
-- use too much memory from the sandbox.
-- You can add more functions to the environment
-- (see where local env is defined)
-- Something nice to play is is appending minetest.env to it.

local BASENAME = "mesecons_luacontroller:luacontroller"

local rules = {}
rules.a = {x = -1, y = 0, z =  0}
rules.b = {x =  0, y = 0, z =  1}
rules.c = {x =  1, y = 0, z =  0}
rules.d = {x =  0, y = 0, z = -1}

------------------
-- Action stuff --
------------------
-- These helpers are required to set the portstates of the luacontroller

local get_real_portstates = function(pos) -- determine if ports are powered (by itself or from outside)
	ports = {
		a = mesecon:is_power_on(mesecon:addPosRule(pos, rules.a))
			and mesecon:rules_link(mesecon:addPosRule(pos, rules.a), pos),
		b = mesecon:is_power_on(mesecon:addPosRule(pos, rules.b))
			and mesecon:rules_link(mesecon:addPosRule(pos, rules.b), pos),
		c = mesecon:is_power_on(mesecon:addPosRule(pos, rules.c))
			and mesecon:rules_link(mesecon:addPosRule(pos, rules.c), pos),
		d = mesecon:is_power_on(mesecon:addPosRule(pos, rules.d))
			and mesecon:rules_link(mesecon:addPosRule(pos, rules.d), pos),
	}
	return ports
end

local merge_portstates = function (ports, vports)
	local npo = {a=false, b=false, c=false, d=false}
	npo.a = vports.a or ports.a
	npo.b = vports.b or ports.b
	npo.c = vports.c or ports.c
	npo.d = vports.d or ports.d
	return npo
end

local action_setports = function (pos, ports, vports)
	if vports.a ~= ports.a then
		if ports.a then mesecon:receptor_on(pos, {rules.a})
		else mesecon:receptor_off(pos, {rules.a}) end
	end
	if vports.b ~= ports.b then
		if ports.b then mesecon:receptor_on(pos, {rules.b})
		else mesecon:receptor_off(pos, {rules.b}) end
	end
	if vports.c ~= ports.c then
		if ports.c then mesecon:receptor_on(pos, {rules.c})
		else mesecon:receptor_off(pos, {rules.c}) end
	end
	if vports.d ~= ports.d then
		if ports.d then mesecon:receptor_on(pos, {rules.d})
		else mesecon:receptor_off(pos, {rules.d}) end
	end
end

local action = function (pos, ports)
	local vports = minetest.registered_nodes[minetest.env:get_node(pos).name].virtual_portstates;
	local name = BASENAME
		..tonumber(ports.d and 1 or 0)
		..tonumber(ports.c and 1 or 0)
		..tonumber(ports.b and 1 or 0)
		..tonumber(ports.a and 1 or 0)
	mesecon:swap_node(pos, name)

	action_setports (pos, ports, vports)
end

--------------------
-- Overheat stuff --
--------------------

local heat = function (meta) -- warm up
	h = meta:get_int("heat")
	if h ~= nil then
		meta:set_int("heat", h + 1)
	end
end

local cool = function (meta) -- cool down after a while
	h = meta:get_int("heat")
	if h ~= nil then
		meta:set_int("heat", h - 1)
	end
end

local overheat = function (meta) -- determine if too hot
	h = meta:get_int("heat")
	if h == nil then return true end -- if nil then overheat
	if h > 30 then 
		return true
	else 
		return false 
	end
end

local overheat_off = function(pos)
	mesecon:receptor_off(pos, mesecon.rules.flat)
end

-------------------
-- Parsing stuff --
-------------------

local code_prohibited = function(code)
	-- Clean code
	local prohibited = {"while", "for", "repeat", "until"}
	for _, p in ipairs(prohibited) do
		if string.find(code, p) then
			return "Prohibited command: "..p
		end
	end
end

local safeprint = function(param)
	print(dump(param))
end

local create_environment = function(pos, mem)
	-- Gather variables for the environment
	local vports = minetest.registered_nodes[minetest.env:get_node(pos).name].virtual_portstates
	vports = {a = vports.a, b = vports.b, c = vports.c, d = vports.d}
	local rports = get_real_portstates(pos)

	return {	print = safeprint,
			pin = merge_portstates(vports, rports),
			port = vports,
			mem = mem}
end

local create_sandbox = function (code, env)
	-- Create Sandbox
	if code:byte(1) == 27 then
		return _, "You Hacker You! Don't use binary code!"
	end
	f, msg = loadstring(code)
	if not f then return _, msg end
	setfenv(f, env)
	return f
end

local do_overheat = function (pos, meta)
	-- Overheat protection
	heat(meta)
	minetest.after(0.5, cool, meta)
	if overheat(meta) then
		minetest.env:remove_node(pos)
		minetest.after(0.2, overheat_off, pos) -- wait for pending operations
		minetest.env:add_item(pos, BASENAME.."0000")
		return
	end
end

local load_memory = function(meta)
	return minetest.deserialize(meta:get_string("lc_memory")) or {}
end

local save_memory = function(meta, mem)
	meta:set_string("lc_memory", minetest.serialize(mem))
end

----------------------
-- Parsing function --
----------------------

local update = function (pos)
	local meta = minetest.env:get_meta(pos)

	local mem  = load_memory(meta)
	local code = meta:get_string("code")

	local prohibited = code_prohibited(code)
	if 	prohibited then return prohibited end
	local env = create_environment(pos, mem)

	local chunk, msg = create_sandbox (code, env)
	if not chunk then return msg end
	local success, msg = pcall(f)
	if not success then return msg end

	do_overheat(pos, meta)
	save_memory(meta, mem)

	-- Actually set the ports
	action(pos, env.port)
end

local reset_meta = function(pos, code, errmsg)
	local meta = minetest.env:get_meta(pos)
	code = code or "";
	errmsg = errmsg or "";
	errmsg = string.gsub(errmsg, "%[", "(") -- would otherwise
	errmsg = string.gsub(errmsg, "%]", ")") -- corrupt formspec
	meta:set_string("code", code)
	meta:set_string("formspec", "size[10,8]"..
		"textarea[0.2,0.4;10.2,5;code;Code:;"..code.."]"..
		"button[3.5,7.5;2,0;program;Program]"..
		"image_button_exit[9.62,-0.35;0.7,0.7;jeija_close_window.png;exit;]"..
		"label[0.1,4.5;"..errmsg.."]")
	meta:set_int("heat", 0)
end

local reset = function (pos)
	action(pos, {a=false, b=false, c=false, d=false})
end

--        ______
--       |
-- |   | |
-- |___| |        __       ___  _   __         _  _
-- |     |       |  | |\ |  |  |_| |  | |  |  |_ |_|
-- |     |______ |__| | \|  |  | \ |__| |_ |_ |_ |\
--

-----------------------
-- Node Registration --
-----------------------

for a = 0, 1 do
for b = 0, 1 do
for c = 0, 1 do
for d = 0, 1 do
local nodename = BASENAME..tostring(d)..tostring(c)..tostring(b)..tostring(a)
local top = "jeija_luacontroller_top.png"
if a == 1 then
	top = top.."^jeija_luacontroller_LED_A.png"
end
if b == 1 then
	top = top.."^jeija_luacontroller_LED_B.png"
end
if c == 1 then
	top = top.."^jeija_luacontroller_LED_C.png"
end
if d == 1 then
	top = top.."^jeija_luacontroller_LED_D.png"
end

if a + b + c + d ~= 0 then
	groups = {dig_immediate=2, not_in_creative_inventory=1}
else
	groups = {dig_immediate=2}
end

local output_rules={}
if (a == 1) then table.insert(output_rules, rules.a) end
if (b == 1) then table.insert(output_rules, rules.b) end
if (c == 1) then table.insert(output_rules, rules.c) end
if (d == 1) then table.insert(output_rules, rules.d) end

local input_rules={}
if (a == 0) then table.insert(input_rules, rules.a) end
if (b == 0) then table.insert(input_rules, rules.b) end
if (c == 0) then table.insert(input_rules, rules.c) end
if (d == 0) then table.insert(input_rules, rules.d) end

local mesecons = {effector =
{
	rules = input_rules,
	action_change = function (pos)
		update(pos)
	end
}}
if nodename ~= BASENAME.."0000" then
	mesecons.receptor = {
		state = mesecon.state.on,
		rules = output_rules
	}
end

local nodebox = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 }, -- bottom slab
			{ -5/16, -7/16, -5/16, 5/16, -6/16, 5/16 }, -- circuit board
			{ -3/16, -6/16, -3/16, 3/16, -5/16, 3/16 }, -- IC
		}
	}

local selectionbox = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -5/16, 8/16 },
	}

minetest.register_node(nodename, {
	description = "Luacontroller",
	drawtype = "nodebox",
	tiles = {
		top,
		"jeija_microcontroller_bottom.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png"
		},

	paramtype = "light",
	groups = groups,
	drop = BASENAME.."0000",
	sunlight_propagates = true,
	selection_box = selectionbox,
	node_box = nodebox,
	on_construct = reset_meta,
	on_receive_fields = function(pos, formname, fields)
		reset(pos)
		reset_meta(pos, fields.code)
		local err = update(pos)
		if err then print(err) end
		reset_meta(pos, fields.code, err)
	end,
	mesecons = mesecons,
	virtual_portstates = {	a = a == 1, -- virtual portstates are
					b = b == 1, -- the ports the the
					c = c == 1, -- controller powers itself
					d = d == 1},-- so those that light up
	after_dig_node = function (pos, node)
		mesecon:receptor_off(pos, output_rules)
	end,
})
end
end
end
end

------------------------
-- Craft Registration --
------------------------

minetest.register_craft({
	output = BASENAME.."0000 2",
	recipe = {
		{'mesecons_materials:silicon', 'mesecons_materials:silicon', 'group:mesecon_conductor_craftable'},
		{'mesecons_materials:silicon', 'mesecons_materials:silicon', 'group:mesecon_conductor_craftable'},
		{'group:mesecon_conductor_craftable', 'group:mesecon_conductor_craftable', ''},
	}
})

