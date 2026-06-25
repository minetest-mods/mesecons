mineunit("core")
mineunit("server")
mineunit("voxelmanip")

mineunit:set_current_modname("mesecons")
mineunit:set_modpath("mesecons", "../mesecons")
sourcefile("../mesecons/init")

-- Utility node: this conductor is used to test the connectivity and state of adjacent wires.
do
	local off_spec = {conductor = {
		state = mesecon.state.off,
		rules = mesecon.rules.alldirs,
		onstate = "mesecons:test_conductor_on",
	}}
	local on_spec = {conductor = {
		state = mesecon.state.on,
		rules = mesecon.rules.alldirs,
		offstate = "mesecons:test_conductor_off",
	}}
	mesecon.register_node("mesecons:test_conductor", {
		description = "Test Conductor",
	}, {mesecons = off_spec}, {mesecons = on_spec})
end

-- Utility node: this receptor is used to test power sources.
do
	local off_spec = {receptor = {
		state = mesecon.state.off,
		rules = mesecon.rules.alldirs,
	}}
	local on_spec = {receptor = {
		state = mesecon.state.on,
		rules = mesecon.rules.alldirs,
	}}
	mesecon.register_node("mesecons:test_receptor", {
		description = "Test Receptor",
	}, {mesecons = off_spec}, {mesecons = on_spec})
end

-- Utility node: this effector is used to test circuit outputs.
do
	-- This is a list of actions in the form {<kind>, <pos>},
	-- where <kind> is "on", "off", or "overheat".
	mesecon._test_effector_events = {}
	local function action_on(pos, node)
		table.insert(mesecon._test_effector_events, {"on", pos})
		node.param2 = node.param2 % 64 + 128 -- Turn on bit 7
		minetest.swap_node(pos, node)
	end
	local function action_off(pos, node)
		table.insert(mesecon._test_effector_events, {"off", pos})
		node.param2 = node.param2 % 64 -- Turn off bit 7
		minetest.swap_node(pos, node)
	end
	local function action_change(pos, node, rule_name, new_state)
		if mesecon.do_overheat(pos) then
			table.insert(mesecon._test_effector_events, {"overheat", pos})
			minetest.remove_node(pos)
			return
		end
		-- Set the value of a bit in param2 according to the rule name and new state.
		local bit = tonumber(rule_name.name, 2)
		local bits_above = node.param2 - node.param2 % (bit * 2)
		local bits_below = node.param2 % bit
		local bits_flipped = new_state == mesecon.state.on and bit or 0
		node.param2 = bits_above + bits_flipped + bits_below
		minetest.swap_node(pos, node)
	end
	minetest.register_node("mesecons:test_effector", {
		description = "Test Effector",
		mesecons = {effector = {
			action_on = action_on,
			action_off = action_off,
			action_change = action_change,
			rules = {
				{x =  1, y =  0, z =  0, name = "000001"},
				{x = -1, y =  0, z =  0, name = "000010"},
				{x =  0, y =  1, z =  0, name = "000100"},
				{x =  0, y = -1, z =  0, name = "001000"},
				{x =  0, y =  0, z =  1, name = "010000"},
				{x =  0, y =  0, z = -1, name = "100000"},
			}
		}},
	})
end

-- Utility node: this conductor is used to test rotation.
do
	local get_rules = mesecon.horiz_rules_getter({{x = 1, y = 0, z = 0}, {x = -1, y = 0, z = 0}})
	local off_spec = {conductor = {
		state = mesecon.state.off,
		rules = get_rules,
		onstate = "mesecons:test_conductor_rot_on",
	}}
	local on_spec = {conductor = {
		state = mesecon.state.on,
		rules = get_rules,
		offstate = "mesecons:test_conductor_rot_off",
	}}
	mesecon.register_node("mesecons:test_conductor_rot", {
		paramtype2 = "4dir",
		description = "Rotatable Test Conductor",
		on_rotate = mesecon.on_rotate,
	}, {mesecons = off_spec}, {mesecons = on_spec})
end

-- Utility node: this is used to test multiple conductors within a single node.
do
	local mesecons_spec = {conductor = {
		rules = {
			{{x = 1, y = 0, z = 0}, {x = 0, y = -1, z = 0}},
			{{x = 0, y = 1, z = 0}, {x = 0, y = 0, z = -1}},
			{{x = 0, y = 0, z = 1}, {x = -1, y = 0, z = 0}},
		},
		states = {
			"mesecons:test_multiconductor_off", "mesecons:test_multiconductor_001",
			"mesecons:test_multiconductor_010", "mesecons:test_multiconductor_011",
			"mesecons:test_multiconductor_100", "mesecons:test_multiconductor_101",
			"mesecons:test_multiconductor_110", "mesecons:test_multiconductor_on",
		},
	}}
	for _, state in ipairs(mesecons_spec.conductor.states) do
		minetest.register_node(state, {
			description = "Test Multiconductor",
			mesecons = mesecons_spec,
		})
	end
end

-- Utility node: this effector with conductor is used to test outputs.
do
	local _rules = {
		{x =  1, y =  0, z =  0, name = "000001"},
		{x = -1, y =  0, z =  0, name = "000010"},
		{x =  0, y =  1, z =  0, name = "000100"},
		{x =  0, y = -1, z =  0, name = "001000"},
		{x =  0, y =  0, z =  1, name = "010000"},
		{x =  0, y =  0, z = -1, name = "100000"},
}
	-- This is a list of actions in the form {<kind>, <pos>},
	-- where <kind> is "on", "off", or "overheat".
	mesecon._test_eff_conductor_events = {}
	local function action_on(pos, node)
		table.insert(mesecon._test_eff_conductor_events, {"on", pos})
		minetest.swap_node(pos, {name = "mesecons:test_effect_conductor_on", param2 = node.param2})
	end
	local function action_off(pos, node)
		table.insert(mesecon._test_eff_conductor_events, {"off", pos})
		minetest.swap_node(pos, {name = "mesecons:test_effect_conductor_off", param2 = node.param2})
	end
	local function action_change(pos, _node, _rule_name, _new_state)
		if mesecon.do_overheat(pos) then
			table.insert(mesecon._test_eff_conductor_events, {"overheat", pos})
			minetest.remove_node(pos)
			return
		end
		-- minetest.swap_node(pos, node)
	end
	local off_spec = {
		effector = {
			rules = _rules,
			action_on = action_on,
			action_off = action_off,
			action_change = action_change,
		},
		conductor = {
			state = mesecon.state.off,
			rules = _rules,
			onstate = "mesecons:test_effect_conductor_on",
		}
	}
	local on_spec = {
		effector = {
			rules = _rules,
			action_on = action_on,
			action_off = action_off,
			action_change = action_change,
		},
		conductor = {
			state = mesecon.state.on,
			rules = _rules,
			offstate = "mesecons:test_effect_conductor_off",
		}
	}
	mesecon.register_node("mesecons:test_effect_conductor", {
		description = "Test Effector With Conductor",
	}, {mesecons = off_spec}, {mesecons = on_spec})
end


mesecon._test_autoconnects = {}
mesecon.register_autoconnect_hook("test", function(pos, node)
	table.insert(mesecon._test_autoconnects, {pos, node})
end)

function mesecon._test_dig(pos)
	local node = minetest.get_node(pos)
	minetest.remove_node(pos)
	mesecon.on_dignode(pos, node)
end

function mesecon._test_place(pos, node)
	world.set_node(pos, node)
	mesecon.on_placenode(pos, minetest.get_node(pos))
end

function mesecon._test_reset()
	-- First let circuits settle by simulating many globalsteps.
	for i = 1, 10 do
		mineunit:execute_globalstep(60)
	end
	mesecon.queue.actions = {}
	mesecon._test_effector_events = {}
	mesecon._test_autoconnects = {}
end

mineunit:execute_globalstep(mesecon.setting("resumetime", 4) + 1)
