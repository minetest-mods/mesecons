--        ______
--       |
--       |
--       |        __       ___  _   __         _  _
-- |   | |       |  | |\ |  |  |_| |  | |  |  |_ |_|
-- |___| |______ |__| | \|  |  | \ |__| |_ |_ |_ |\
-- |
-- |
--

-- Reference
-- ports = get_real_port_states(pos): gets if inputs are powered from outside
-- newport = merge_port_states(state1, state2): just does result = state1 or state2 for every port
-- set_port(pos, rule, state): activates/deactivates the mesecons according to the port states
-- set_port_states(pos, ports): Applies new port states to a LuaController at pos
-- run(pos): runs the code in the controller at pos
-- reset_meta(pos, code, errmsg): performs a software-reset, installs new code and prints error messages
-- resetn(pos): performs a hardware reset, turns off all ports
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

local rules = {
	a = {x = -1, y = 0, z =  0, name="A"},
	b = {x =  0, y = 0, z =  1, name="B"},
	c = {x =  1, y = 0, z =  0, name="C"},
	d = {x =  0, y = 0, z = -1, name="D"},
}


------------------
-- Action stuff --
------------------
-- These helpers are required to set the port states of the luacontroller

local function update_real_port_states(pos, rule_name, new_state)
	local meta = minetest.get_meta(pos)
	if rule_name == nil then
		meta:set_int("real_portstates", 1)
		return
	end
	local n = meta:get_int("real_portstates") - 1
	local L = {}
	for i = 1, 4 do
		L[i] = n % 2
		n = math.floor(n / 2)
	end
	--                   (0,-1) (-1,0)      (1,0) (0,1)
	local pos_to_side = {  4,	 1,   nil,   3,	2 }
	if rule_name.x == nil then
		for _, rname in ipairs(rule_name) do
			local port = pos_to_side[rname.x + (2 * rname.z) + 3]
			L[port] = (newstate == "on") and 1 or 0
		end
	else
		local port = pos_to_side[rule_name.x + (2 * rule_name.z) + 3]
		L[port] = (new_state == "on") and 1 or 0
	end
	meta:set_int("real_portstates",
		1 +
		1 * L[1] +
		2 * L[2] +
		4 * L[3] +
		8 * L[4])
end


local port_names = {"a", "b", "c", "d"}

local function get_real_port_states(pos)
	-- Determine if ports are powered (by itself or from outside)
	local meta = minetest.get_meta(pos)
	local L = {}
	local n = meta:get_int("real_portstates") - 1
	for _, name in ipairs(port_names) do
		L[name] = ((n % 2) == 1)
		n = math.floor(n / 2)
	end
	return L
end


local function merge_port_states(ports, vports)
	return {
		a = ports.a or vports.a,
		b = ports.b or vports.b,
		c = ports.c or vports.c,
		d = ports.d or vports.d,
	}
end

local function generate_name(ports)
	local d = ports.d and 1 or 0
	local c = ports.c and 1 or 0
	local b = ports.b and 1 or 0
	local a = ports.a and 1 or 0
	return BASENAME..d..c..b..a
end


local function set_port(pos, rule, state)
	if state then
		mesecon.receptor_on(pos, {rule})
	else
		mesecon.receptor_off(pos, {rule})
	end
end


local function clean_port_states(ports)
	ports.a = ports.a and true or false
	ports.b = ports.b and true or false
	ports.c = ports.c and true or false
	ports.d = ports.d and true or false
end


local function set_port_states(pos, ports)
	local node = minetest.get_node(pos)
	local name = node.name
	clean_port_states(ports)
	local vports = minetest.registered_nodes[name].virtual_portstates
	local new_name = generate_name(ports)

	if name ~= new_name and vports then
		-- Problem:
		-- We need to place the new node first so that when turning
		-- off some port, it won't stay on because the rules indicate
		-- there is an onstate output port there.
		-- When turning the output off then, it will however cause feedback
		-- so that the luacontroller will receive an "off" event by turning
		-- its output off.
		-- Solution / Workaround:
		-- Remember which output was turned off and ignore next "off" event.
		local meta = minetest.get_meta(pos)
		local ign = minetest.deserialize(meta:get_string("ignore_offevents")) or {}
		if ports.a and not vports.a and not mesecon.is_powered(pos, rules.a) then ign.A = true end
		if ports.b and not vports.b and not mesecon.is_powered(pos, rules.b) then ign.B = true end
		if ports.c and not vports.c and not mesecon.is_powered(pos, rules.c) then ign.C = true end
		if ports.d and not vports.d and not mesecon.is_powered(pos, rules.d) then ign.D = true end
		meta:set_string("ignore_offevents", minetest.serialize(ign))

		minetest.swap_node(pos, {name = new_name, param2 = node.param2})

		if ports.a ~= vports.a then set_port(pos, rules.a, ports.a) end
		if ports.b ~= vports.b then set_port(pos, rules.b, ports.b) end
		if ports.c ~= vports.c then set_port(pos, rules.c, ports.c) end
		if ports.d ~= vports.d then set_port(pos, rules.d, ports.d) end
	end
end


-----------------
-- Overheating --
-----------------
local function burn_controller(pos)
	local node = minetest.get_node(pos)
	node.name = BASENAME.."_burnt"
	minetest.swap_node(pos, node)
	minetest.get_meta(pos):set_string("lc_memory", "");
	-- Wait for pending operations
	minetest.after(0.2, mesecon.receptor_off, pos, mesecon.rules.flat)
end

local function overheat(pos, meta)
	if mesecon.do_overheat(pos) then -- If too hot
		burn_controller(pos)
		return true
	end
end

------------------------
-- Ignored off events --
------------------------

local function ignore_event(event, meta)
	if event.type ~= "off" then return false end
	local ignore_offevents = minetest.deserialize(meta:get_string("ignore_offevents")) or {}
	if ignore_offevents[event.pin.name] then
		ignore_offevents[event.pin.name] = nil
		meta:set_string("ignore_offevents", minetest.serialize(ignore_offevents))
		return true
	end
end

-------------------------
-- Parsing and running --
-------------------------

local function safe_print(param)
	print(dump(param))
end

local function remove_functions(x)
	local tp = type(x)
	if tp == "table" then
		for key, value in pairs(x) do
			local key_t, val_t = type(key), type(value)
			if key_t == "function" or val_t == "function" then
				x[key] = nil
			else
				if key_t == "table" then
					remove_functions(key)
				end
				if val_t == "table" then
					remove_functions(value)
				end
			end
		end
	elseif tp == "function" then
		return nil
	end
	return x
end

local function get_interrupt(pos)
	-- iid = interrupt id
	local function interrupt(time, iid)
		if type(time) ~= "number" then return end
		local luac_id = minetest.get_meta(pos):get_int("luac_id")
		mesecon.queue:add_action(pos, "lc_interrupt", {luac_id, iid}, time, iid, 1)
	end
	return interrupt
end


local function get_digiline_send(pos)
	if not digiline then return end
	return function(channel, msg)
		minetest.after(0, function()
			digiline:receptor_send(pos, digiline.rules.default, channel, msg)
		end)
	end
end


local safe_globals = {
	"assert", "error", "ipairs", "next", "pairs", "select",
	"tonumber", "tostring", "type", "unpack", "_VERSION", 
}
--This error is used as a signal to pcall, because otherwise someone could deliberately set off a timeout to disable the debug hooks.
local timeout_error="Code timed out!"
local function create_environment(pos, mem, event)
	-- Gather variables for the environment
	local vports = minetest.registered_nodes[minetest.get_node(pos).name].virtual_portstates
	local vports_copy = {}
	for k, v in pairs(vports) do vports_copy[k] = v end
	local rports = get_real_port_states(pos)

	-- Create new library tables on each call to prevent one LuaController
	-- from breaking a library and messing up other LuaControllers.
	local env = {
		pin = merge_port_states(vports, rports),
		port = vports_copy,
		event = event,
		mem = mem,
		heat = minetest.get_meta(pos):get_int("heat"),
		heat_max = mesecon.setting("overheat_max", 20),
		print = safe_print,
		interrupt = get_interrupt(pos),
		digiline_send = get_digiline_send(pos),
		string = {
			byte = string.byte,
			char = string.char,
			format = string.format,
			gsub = string.gsub,
			len = string.len,
			lower = string.lower,
			upper = string.upper,
			rep = string.rep,
			reverse = string.reverse,
			sub = string.sub,
		},
		math = {
			abs = math.abs,
			acos = math.acos,
			asin = math.asin,
			atan = math.atan,
			atan2 = math.atan2,
			ceil = math.ceil,
			cos = math.cos,
			cosh = math.cosh,
			deg = math.deg,
			exp = math.exp,
			floor = math.floor,
			fmod = math.fmod,
			frexp = math.frexp,
			huge = math.huge,
			ldexp = math.ldexp,
			log = math.log,
			log10 = math.log10,
			max = math.max,
			min = math.min,
			modf = math.modf,
			pi = math.pi,
			pow = math.pow,
			rad = math.rad,
			random = math.random,
			sin = math.sin,
			sinh = math.sinh,
			sqrt = math.sqrt,
			tan = math.tan,
			tanh = math.tanh,
		},
		table = {
			concat = table.concat,
			insert = table.insert,
			maxn = table.maxn,
			remove = table.remove,
			sort = table.sort,
		},
		os = {
			clock = os.clock,
			difftime = os.difftime,
			time = os.time,
		},
	}
	env._G = env

	for _, name in pairs(safe_globals) do
		env[name] = _G[name]
	end

	env.pcall=function(...)
		local pcr={pcall(...)}
		if not pcr[1] then
			if pcr[2] ~= timeout_error then
				error(pcr[2])
			end
		end
		return unpack(pcr)
	end
	
	return env
end


local function timeout()
	debug.sethook()  -- Clear hook
	error(timeout_error)
end

--A VERY minimalistic lexer, does what it needs to for this job and no more.
local function lexLua(code)
	local lexElements = {}
	--Find keywords, whitespace, strings, and then everything else is "cleanup"
	
	--Keywords and numbers.
	function lexElements.keyword(str)
		return str:match("^[%w_]+")
	end
	function lexElements.whitespace(str)
		return str:match("^[\r \t]+")
	end
	--Unimplemented stuff goes here.
	function lexElements.cleanup(str)
		return str:match("^.")
	end
	function lexElements.string(str)
		--Now parse a string.
		local quoteType = str:sub(1,1)
		if quoteType ~= "\"" and quoteType ~= "\'" then return nil end
		local inEscape = true
		local rstr = ""
		for i=1, str:len() do
			local c = str:sub(i,i)
			rstr = rstr..c
			if inEscape then
				inEscape = false
			else
				if c == quoteType then return rstr end
				if c == "\\" then inEscape = true end
			end
		end
		return nil --unfinished string
	end
	function lexElements.blockcomment(str)
		local a = str:match("^%-%-%[%[")
		if not a then return nil end
		local s = str:find("%-%-%]%]")
		if not s then return nil end
		return str:sub(1,s+3)
	end
	function lexElements.linecomment(str)
		return str:match("^%-%-[^\r\n]+")
	end
	-- Note: EOL is not reliable for linecounting purposes, but keeps the code better formatted, if anything
	function lexElements.eol()
		return str:match("^[\n]+")
	end
	local lexElementsOrder = {"keyword", "eol", "whitespace",
		"string", "blockcomment", "linecomment", "cleanup"}
	local lexResults = {}
	while code:len() > 0 do
		--Because break doesn't exist.
		local function parseElem()
			for _,v in ipairs(lexElementsOrder) do
				local t, e=lexElements[v](code)
				if t then
					code=code:sub(t:len() + 1)
					table.insert(lexResults,{v, t})
					return nil
				end
				if e then
					return e
				end
			end
			return "no match"
		end
		local err=parseElem()
		if err then return nil, "Lexer Error:"..err..": "..code:sub(1, 32) end
	end
	return lexResults
end

local function code_prohibited(code)
	-- LuaJIT doesn't increment the instruction counter when running
	-- loops, so we have to sanitize inputs if we're using LuaJIT.
	if not jit then
		return code
	end
	--Find the following constructs, and place dummies where (dummy) is:
	--while ... do (dummy)
	--for ... do (dummy)
	--repeat (dummy)
	
	-- This only exists in Lua 5.2
	--(dummy) goto
	
	local lexed, err=lexLua(code)
	local rcode = ""
	if err then
		return nil, "Couldn't lex code:"..err
	end
	for _, v in ipairs(lexed) do
		--remove/reduce useless stuff since we're going over it anyway.
		if v[1] == "whitespace" then v[2] = " " end
		if v[1] == "eol" then v[2] = "\r\n" end -- Windows users may like the \r
		if v[1] == "blockcomment" then v[2] = "" end
		if v[1] == "linecomment" then v[2] = "" end
		--Code injection so we can safely use every feature in Lua. The only purpose of the lexer is to filter stuff that would break this, really.
		--(the old method would stop you from using keywords in strings.)
		--You can also replace this with coroutine.yield, but that's best left to a computercraft-style mod.
		local dummy = "(function() end)()"
		if v[2] == "do" then
			v[2] = "do "..dummy
		end
		if v[2] == "repeat" then
			v[2] = "repeat "..dummy
		end
		if v[2] == "goto" then
			v[2] = dummy.." goto"
		end
		rcode = rcode..v[2]
	end
	return rcode
end


local function create_sandbox(code, env)
	if code:byte(1) == 27 then
		return nil, "Binary code prohibited."
	end
	local f, msg = loadstring(code)
	if not f then return nil, msg end
	setfenv(f, env)

	return function(...)
		debug.sethook(timeout, "", 10000)
		local ok, ret = pcall(f, ...)
		debug.sethook()  -- Clear hook
		if not ok then error(ret) end
		return ret
	end
end


local function load_memory(meta)
	return minetest.deserialize(meta:get_string("lc_memory")) or {}
end


local function save_memory(pos, meta, mem)
	local memstring = minetest.serialize(remove_functions(mem))
	local memsize_max = mesecon.setting("luacontroller_memsize", 100000)

	if (#memstring <= memsize_max) then
		meta:set_string("lc_memory", memstring)
	else
		print("Error: Luacontroller memory overflow. "..memsize_max.." bytes available, "
				..#memstring.." required. Controller overheats.")
		burn_controller(pos)
	end
end


local function run(pos, event)
	local meta = minetest.get_meta(pos)
	if overheat(pos) then return end
	if ignore_event(event, meta) then return end

	-- Load code & mem from meta
	local mem  = load_memory(meta)
	local code = meta:get_string("code")
	local err
	code, err = code_prohibited(code)
	if not code then return err end

	-- Create environment
	local env = create_environment(pos, mem, event)

	-- Create the sandbox and execute code
	local f, msg = create_sandbox(code, env)
	if not f then return msg end
	local success, msg = pcall(f)
	if not success then return msg end
	if type(env.port) ~= "table" then
		return "Ports set are invalid."
	end

	-- Actually set the ports
	set_port_states(pos, env.port)

	-- Save memory. This may burn the luacontroller if a memory overflow occurs.
	save_memory(pos, meta, env.mem)
end

mesecon.queue:add_function("lc_interrupt", function (pos, luac_id, iid)
	-- There is no luacontroller anymore / it has been reprogrammed / replaced / burnt
	if (minetest.get_meta(pos):get_int("luac_id") ~= luac_id) then return end
	if (minetest.registered_nodes[minetest.get_node(pos).name].is_burnt) then return end
	run(pos, {type="interrupt", iid = iid})
end)

local function reset_meta(pos, code, errmsg)
	local meta = minetest.get_meta(pos)
	meta:set_string("code", code)
	code = minetest.formspec_escape(code or "")
	errmsg = minetest.formspec_escape(errmsg or "")
	meta:set_string("formspec", "size[10,8]"..
		"background[-0.2,-0.25;10.4,8.75;jeija_luac_background.png]"..
		"textarea[0.2,0.6;10.2,5;code;;"..code.."]"..
		"image_button[3.75,6;2.5,1;jeija_luac_runbutton.png;program;]"..
		"image_button_exit[9.72,-0.25;0.425,0.4;jeija_close_window.png;exit;]"..
		"label[0.1,5;"..errmsg.."]")
	meta:set_int("heat", 0)
	meta:set_int("luac_id", math.random(1, 65535))
end

local function reset(pos)
	set_port_states(pos, {a=false, b=false, c=false, d=false})
end


-----------------------
-- Node Registration --
-----------------------

local output_rules = {}
local input_rules = {}

local node_box = {
	type = "fixed",
	fixed = {
		{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16}, -- Bottom slab
		{-5/16, -7/16, -5/16, 5/16, -6/16, 5/16}, -- Circuit board
		{-3/16, -6/16, -3/16, 3/16, -5/16, 3/16}, -- IC
	}
}

local selection_box = {
	type = "fixed",
	fixed = { -8/16, -8/16, -8/16, 8/16, -5/16, 8/16 },
}

local digiline = {
	receptor = {},
	effector = {
		action = function(pos, node, channel, msg)
			run(pos, {type = "digiline", channel = channel, msg = msg})
		end
	}
}
local function on_receive_fields(pos, form_name, fields)
	if not fields.program then
		return
	end
	reset(pos)
	reset_meta(pos, fields.code)
	local err = run(pos, {type="program"})
	if err then
		print(err)
		reset_meta(pos, fields.code, err)
	end
end

for a = 0, 1 do -- 0 = off  1 = on
for b = 0, 1 do
for c = 0, 1 do
for d = 0, 1 do
	local cid = tostring(d)..tostring(c)..tostring(b)..tostring(a)
	local node_name = BASENAME..cid
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

	local groups
	if a + b + c + d ~= 0 then
		groups = {dig_immediate=2, not_in_creative_inventory=1, overheat = 1}
	else
		groups = {dig_immediate=2, overheat = 1}
	end

	output_rules[cid] = {}
	input_rules[cid] = {}
	if a == 1 then table.insert(output_rules[cid], rules.a) end
	if b == 1 then table.insert(output_rules[cid], rules.b) end
	if c == 1 then table.insert(output_rules[cid], rules.c) end
	if d == 1 then table.insert(output_rules[cid], rules.d) end

	if a == 0 then table.insert( input_rules[cid], rules.a) end
	if b == 0 then table.insert( input_rules[cid], rules.b) end
	if c == 0 then table.insert( input_rules[cid], rules.c) end
	if d == 0 then table.insert( input_rules[cid], rules.d) end

	local mesecons = {
		effector = {
			rules = input_rules[cid],
			action_change = function (pos, _, rule_name, new_state)
				update_real_port_states(pos, rule_name, new_state)
				run(pos, {type=new_state, pin=rule_name})
			end,
		},
		receptor = {
			state = mesecon.state.on,
			rules = output_rules[cid]
		}
	}

	minetest.register_node(node_name, {
		description = "LuaController",
		drawtype = "nodebox",
		tiles = {
			top,
			"jeija_microcontroller_bottom.png",
			"jeija_microcontroller_sides.png",
			"jeija_microcontroller_sides.png",
			"jeija_microcontroller_sides.png",
			"jeija_microcontroller_sides.png"
		},
		inventory_image = top,
		paramtype = "light",
		groups = groups,
		drop = BASENAME.."0000",
		sunlight_propagates = true,
		selection_box = selection_box,
		node_box = node_box,
		on_construct = reset_meta,
		on_receive_fields = on_receive_fields,
		sounds = default.node_sound_stone_defaults(),
		mesecons = mesecons,
		digiline = digiline,
		-- Virtual portstates are the ports that
		-- the node shows as powered up (light up).
		virtual_portstates = {
			a = a == 1,
			b = b == 1,
			c = c == 1,
			d = d == 1,
		},
		after_dig_node = function (pos, node)
			mesecon.receptor_off(pos, output_rules)
		end,
		is_luacontroller = true,
	})
end
end
end
end

------------------------------
-- Overheated LuaController --
------------------------------

minetest.register_node(BASENAME .. "_burnt", {
	drawtype = "nodebox",
	tiles = {
		"jeija_luacontroller_burnt_top.png",
		"jeija_microcontroller_bottom.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png"
	},
	inventory_image = "jeija_luacontroller_burnt_top.png",
	is_burnt = true,
	paramtype = "light",
	groups = {dig_immediate=2, not_in_creative_inventory=1},
	drop = BASENAME.."0000",
	sunlight_propagates = true,
	selection_box = selection_box,
	node_box = node_box,
	on_construct = reset_meta,
	on_receive_fields = on_receive_fields,
	sounds = default.node_sound_stone_defaults(),
	virtual_portstates = {a = false, b = false, c = false, d = false},
	mesecons = {
		effector = {
			rules = mesecon.rules.flat,
			action_change = function(pos, _, rule_name, new_state)
				update_real_port_states(pos, rule_name, new_state)
			end,
		},
	},
})

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

