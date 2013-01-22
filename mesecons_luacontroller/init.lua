-- Reference
-- ports = get_real_portstates(pos): gets if inputs are powered from outside
-- newport = merge_portstates(state1, state2): just does result = state1 or state2 for every port
-- action_setports(pos, ports, vports): activates/deactivates the mesecons according to the portstates (helper for action)
-- action(pos, ports): Applies new portstates to a luacontroller at pos
-- lc_update(pos): updates the controller at pos by executing the code
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
rules.a = {x = -1, y = 0, z =  0, name="A"}
rules.b = {x =  0, y = 0, z =  1, name="B"}
rules.c = {x =  1, y = 0, z =  0, name="C"}
rules.d = {x =  0, y = 0, z = -1, name="D"}

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

local generate_name = function (ports, overwrite)
	local overwrite = overwrite or {}
	local d = overwrite.d or (ports.d and 1 or 0)
	local c = overwrite.d or (ports.c and 1 or 0)
	local b = overwrite.d or (ports.b and 1 or 0)
	local a = overwrite.d or (ports.a and 1 or 0)
	return BASENAME..d..c..b..a
end

local setport = function (pos, rule, ignore, state, ports)
	local ignorename = generate_name(ports, ignore)
	mesecon:swap_node(pos, ignorename)
	if state then
		mesecon:receptor_on(pos, {rule})
	else
		mesecon:receptor_off(pos, {rule})
	end
	if minetest.env:get_node(pos).name ~= ignorename then
		return true -- overridden by second process
	end
	return false -- success
end

local action = function (pos, ports, forcereset)
	local name = minetest.env:get_node(pos).name
	local vports = minetest.registered_nodes[name].virtual_portstates
	local newname = generate_name(ports)

	if name ~= newname and vports then
		local rules_on  = {}
		local rules_off = {}
		local ignore = {}

		local interrupted
		if ports.a ~= vports.a then interrupted = setport(pos, rules.a, {a = 2}, ports.a, ports) end
		if interrupted and not forcereset then return end
		if ports.b ~= vports.b then interrupted = setport(pos, rules.b, {b = 2}, ports.b, ports) end
		if interrupted and not forcereset then return end
		if ports.c ~= vports.c then interrupted = setport(pos, rules.c, {c = 2}, ports.c, ports) end
		if interrupted and not forcereset then return end
		if ports.d ~= vports.d then interrupted = setport(pos, rules.d, {d = 2}, ports.d, ports) end
		if interrupted and not forcereset then return end

		mesecon:swap_node(pos, newname)
	end
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
	if h > 20 then 
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
	local prohibited = {"while", "for", "repeat", "until", "function"}
	for _, p in ipairs(prohibited) do
		if string.find(code, p) then
			return "Prohibited command: "..p
		end
	end
end

local safeprint = function(param)
	print(dump(param))
end

local interrupt = function(params)
	lc_update(params.pos, {type="interrupt", iid = params.iid})
end

local getinterrupt = function(pos)
	local interrupt = function (time, iid) -- iid = interrupt id
		if type(time) ~= "number" then return end
		local meta = minetest.env:get_meta(pos)
		local interrupts = minetest.deserialize(meta:get_string("lc_interrupts")) or {}
		table.insert (interrupts, iid or 0)
		meta:set_string("lc_interrupts", minetest.serialize(interrupts))
		minetest.after(time, interrupt, {pos=pos, iid = iid})
	end
	return interrupt
end

local getdigiline_send = function (pos)
	local digiline_send = function (channel, msg)
		if digiline then
			digiline:receptor_send(pos, digiline.rules.default, channel, msg)
		end
	end
	return digiline_send
end

local create_environment = function(pos, mem, event)
	-- Gather variables for the environment
	local vports = minetest.registered_nodes[minetest.env:get_node(pos).name].virtual_portstates
	vports = {a = vports.a, b = vports.b, c = vports.c, d = vports.d}
	local rports = get_real_portstates(pos)

	return {	print = safeprint,
			pin = merge_portstates(vports, rports),
			port = vports,
			interrupt = getinterrupt(pos),
			digiline_send = getdigiline_send(pos),
			mem = mem,
			tostring = tostring,
			tonumber = tonumber,
			string = string,
			event = event}
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
		return true
	end
end

local load_memory = function(meta)
	return minetest.deserialize(meta:get_string("lc_memory")) or {}
end

local save_memory = function(meta, mem)
	meta:set_string("lc_memory", minetest.serialize(mem))
end

local interrupt_allow = function (meta, event)
	if event.type ~= "interrupt" then return true end

	local interrupts = minetest.deserialize(meta:get_string("lc_interrupts")) or {}
	for _, i in ipairs(interrupts) do
		if minetest.serialize(i) == minetest.serialize(event.iid) then
			return true
		end
	end

	return false
end

local ports_invalid = function (var)
	if type(var) == "table" then
		return false
	end
	return "The ports you set are invalid"
end

----------------------
-- Parsing function --
----------------------

lc_update = function (pos, event)
	local meta = minetest.env:get_meta(pos)
	if not interrupt_allow(meta, event) then return end
	if do_overheat(pos, meta) then return end

	-- load code & mem from memory
	local mem  = load_memory(meta)
	local code = meta:get_string("code")

	-- make sure code is ok and create environment
	local prohibited = code_prohibited(code)
	if 	prohibited then return prohibited end
	local env = create_environment(pos, mem, event)

	-- create the sandbox and execute code
	local chunk, msg = create_sandbox (code, env)
	if not chunk then return msg end
	local success, msg = pcall(f)
	if not success then return msg end
	if ports_invalid(env.port) then return ports_invalid(env.port) end

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
		"background[-0.2,-0.25;10.4,8.75;jeija_luac_background.png]"..
		"textarea[0.2,0.6;10.2,5;code;;"..code.."]"..
		"image_button[3.75,6;2.5,1;jeija_luac_runbutton.png;program;]"..
		"image_button_exit[9.72,-0.25;0.425,0.4;jeija_close_window.png;exit;]"..
		"label[0.1,5;"..errmsg.."]")
	meta:set_int("heat", 0)
end

local reset = function (pos)
	action(pos, {a=false, b=false, c=false, d=false}, true)
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

local output_rules={}
local input_rules={}

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

local digiline = {
	receptor = {},
	effector = {
		action = function (pos, node, channel, msg)
			lc_update (pos, {type = "digiline", channel = channel, msg = msg})
		end
	}
}

for a = 0, 2 do -- 0 = off; 1 = on; 2 = ignore
for b = 0, 2 do
for c = 0, 2 do
for d = 0, 2 do

local cid = tostring(d)..tostring(c)..tostring(b)..tostring(a)
local nodename = BASENAME..cid
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

output_rules[cid] = {}
input_rules[cid] = {}
if (a == 1) then table.insert(output_rules[cid], rules.a) end
if (b == 1) then table.insert(output_rules[cid], rules.b) end
if (c == 1) then table.insert(output_rules[cid], rules.c) end
if (d == 1) then table.insert(output_rules[cid], rules.d) end

if (a == 0) then table.insert(input_rules[cid], rules.a) end
if (b == 0) then table.insert(input_rules[cid], rules.b) end
if (c == 0) then table.insert(input_rules[cid], rules.c) end
if (d == 0) then table.insert(input_rules[cid], rules.d) end

local mesecons = {
	effector =
	{
		rules = input_rules[cid],
		action_change = function (pos, _, rulename, newstate)
			lc_update(pos, {type=newstate,  pin=rulename})
		end,
	},
	receptor =
	{
		state = mesecon.state.on,
		rules = output_rules[cid]
	}
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
		local err = lc_update(pos, {type="program"})
		if err then print(err) end
		reset_meta(pos, fields.code, err)
	end,
	mesecons = mesecons,
	digiline = digiline,
	is_luacontroller = true,
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

