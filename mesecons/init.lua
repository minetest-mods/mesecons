-- |\    /| ____ ____  ____ _____   ____         _____
-- | \  / | |    |     |    |      |    | |\   | |
-- |  \/  | |___ ____  |___ |      |    | | \  | |____
-- |      | |        | |    |      |    | |  \ |     |
-- |      | |___ ____| |___ |____  |____| |   \| ____|
-- by Jeija and Minerd247
--
--
--
-- This mod adds mesecons[=minecraft redstone] and different receptors/effectors to minetest.
--
-- See the documentation on the forum for additional information, especially about crafting
--
-- For developer documentation see the Developers' section on mesecons.tk 


-- PUBLIC VARIABLES
mesecon={} -- contains all functions and all global variables
mesecon.actions_on={} -- Saves registered function callbacks for mesecon on
mesecon.actions_off={} -- Saves registered function callbacks for mesecon off
mesecon.actions_change={} -- Saves registered function callbacks for mesecon change
mesecon.receptors={}
mesecon.receptors_off={}
mesecon.effectors={}
mesecon.rules={}
mesecon.conductors={}

-- INCLUDE SETTINGS
dofile(minetest.get_modpath("mesecons").."/settings.lua")

--Internal API
dofile(minetest.get_modpath("mesecons").."/internal.lua");

-- API API API API API API API API API API API API API API API API API API

function mesecon:add_receptor_node(name, rules, get_rules) --rules table is optional; if rules depend on param2 pass (nodename, nil, function get_rules)
	if get_rules==nil and rules==nil then
		rules=mesecon:get_rules("default")
	end
	table.insert(mesecon.receptors, {name = name, rules = rules, get_rules = get_rules})
end

function mesecon:add_receptor_node_off(name, rules, get_rules)
	if get_rules==nil and rules==nil then
		rules=mesecon:get_rules("default")
	end
	table.insert(mesecon.receptors_off, {name = name, rules = rules, get_rules = get_rules})
end

function mesecon:register_effector(onstate, offstate, input_rules, get_input_rules)
	if get_input_rules==nil and input_rules==nil then
		rules=mesecon:get_rules("default")
	end
	table.insert(mesecon.effectors, {onstate = onstate, offstate = offstate, input_rules = input_rules, get_input_rules = get_input_rules})
end

function mesecon:receptor_on(pos, rules)
	if rules == nil then
		rules = mesecon:get_rules("default")
	end

	for i, rule in ipairs(rules) do
		local np = {}
		np.x = pos.x + rule.x
		np.y = pos.y + rule.y
		np.z = pos.z + rule.z
		if mesecon:rules_link(pos, np, rules) then
			mesecon:turnon(np, pos)
		end
		i=i+1
	end
end

function mesecon:receptor_off(pos, rules)
	if rules == nil then
		rules = mesecon:get_rules("default")
	end

	local connected = false

	for i, rule in ipairs(rules) do
		local np = {}
		np.x = pos.x + rule.x
		np.y = pos.y + rule.y
		np.z = pos.z + rule.z
		if mesecon:rules_link(pos, np, rules) and mesecon:connected_to_pw_src(np) == false then
			mesecon:turnoff(np, pos)
		end
		i=i+1
	end
end

function mesecon:register_on_signal_on(action)
	table.insert(mesecon.actions_on, action)
end

function mesecon:register_on_signal_off(action)
	table.insert(mesecon.actions_off, action)
end

function mesecon:register_on_signal_change(action)
	table.insert(mesecon.actions_change, action)
end

function mesecon:register_conductor (onstate, offstate, rules, get_rules)
	if rules == nil then
		rules = mesecon:get_rules("default")
	end
	table.insert(mesecon.conductors, {onstate = onstate, offstate = offstate, rules = rules, get_rules = get_rules})
end

mesecon:add_rules("default", 
{{x=0,  y=0,  z=-1},
{x=1,  y=0,  z=0},
{x=-1, y=0,  z=0},
{x=0,  y=0,  z=1},
{x=1,  y=1,  z=0},
{x=1,  y=-1, z=0},
{x=-1, y=1,  z=0},
{x=-1, y=-1, z=0},
{x=0,  y=1,  z=1},
{x=0,  y=-1, z=1},
{x=0,  y=1,  z=-1},
{x=0,  y=-1, z=-1}})

print("[MESEcons] Main mod Loaded!")

--The actual wires
dofile(minetest.get_modpath("mesecons").."/wires.lua");

--Services like turnoff receptor on dignode and so on
dofile(minetest.get_modpath("mesecons").."/services.lua");
