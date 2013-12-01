-- |\    /| ____ ____  ____ _____   ____         _____
-- | \  / | |    |     |    |      |    | |\   | |
-- |  \/  | |___ ____  |___ |      |    | | \  | |____
-- |      | |        | |    |      |    | |  \ |     |
-- |      | |___ ____| |___ |____  |____| |   \| ____|
-- by Jeija, Uberi (Temperest), sfan5, VanessaE
--
--
--
-- This mod adds mesecons[=minecraft redstone] and different receptors/effectors to minetest.
-- See the documentation on the forum for additional information, especially about crafting
--
--
-- For developer documentation see the Developers' section on mesecons.TK
--
--
--
--Quick draft for the mesecons array in the node's definition
--mesecons =
--{
--	receptor =
--	{
--		state = mesecon.state.on/off
--		rules = rules/get_rules
--	},
--	effector =
--	{
--		action_on = function
--		action_off = function
--		action_change = function
--		rules = rules/get_rules
--	},
--	conductor = 
--	{
--		state = mesecon.state.on/off
--		offstate = opposite state (for state = on only)
--		onstate = opposite state (for state = off only)
--		rules = rules/get_rules
--	}
--}


-- PUBLIC VARIABLES
mesecon={} -- contains all functions and all global variables
mesecon.actions_on={} -- Saves registered function callbacks for mesecon on | DEPRECATED
mesecon.actions_off={} -- Saves registered function callbacks for mesecon off | DEPRECATED
mesecon.actions_change={} -- Saves registered function callbacks for mesecon change | DEPRECATED
mesecon.receptors={} --  saves all information about receptors  | DEPRECATED
mesecon.effectors={} --  saves all information about effectors  | DEPRECATED
mesecon.conductors={} -- saves all information about conductors | DEPRECATED


local wpath = minetest.get_worldpath()
local function read_file(fn)
	local f = io.open(fn, "r")
	if f==nil then return {} end
	local t = f:read("*all")
	f:close()
	if t=="" or t==nil then return {} end
	return minetest.deserialize(t)
end

local function write_file(fn, tbl)
	local f = io.open(fn, "w")
	f:write(minetest.serialize(tbl))
	f:close()
end

mesecon.to_update = read_file(wpath.."/mesecon_to_update")
mesecon.r_to_update = read_file(wpath.."/mesecon_r_to_update")

minetest.register_on_shutdown(function()
	write_file(wpath.."/mesecon_to_update",mesecon.to_update)
	write_file(wpath.."/mesecon_r_to_update",mesecon.r_to_update)
end)

-- Settings
dofile(minetest.get_modpath("mesecons").."/settings.lua")

-- Presets (eg default rules)
dofile(minetest.get_modpath("mesecons").."/presets.lua");


-- Utilities like comparing positions,
-- adding positions and rules,
-- mostly things that make the source look cleaner
dofile(minetest.get_modpath("mesecons").."/util.lua");

-- Internal stuff
-- This is the most important file
-- it handles signal transmission and basically everything else
-- It is also responsible for managing the nodedef things,
-- like calling action_on/off/change
dofile(minetest.get_modpath("mesecons").."/internal.lua");

-- Deprecated stuff
-- To be removed in future releases
-- Currently there is nothing here
dofile(minetest.get_modpath("mesecons").."/legacy.lua");

-- API
-- these are the only functions you need to remember

function mesecon:receptor_on_i(pos, rules)
	rules = rules or mesecon.rules.default

	for _, rule in ipairs(mesecon:flattenrules(rules)) do
		local np = mesecon:addPosRule(pos, rule)
		local link, rulename = mesecon:rules_link(pos, np, rules)
		if link then
			mesecon:turnon(np, rulename)
		end
	end
end

function mesecon:receptor_on(pos, rules)
	if MESECONS_GLOBALSTEP then
		rules = rules or mesecon.rules.default
		mesecon.r_to_update[#mesecon.r_to_update+1]={pos=pos, rules=rules, action="on"}
	else
		mesecon:receptor_on_i(pos, rules)
	end
end

function mesecon:receptor_off_i(pos, rules)
	rules = rules or mesecon.rules.default

	for _, rule in ipairs(mesecon:flattenrules(rules)) do
		local np = mesecon:addPosRule(pos, rule)
		local link, rulename = mesecon:rules_link(pos, np, rules)
		if link then
			if not mesecon:connected_to_receptor(np, mesecon:invertRule(rule)) then
				mesecon:turnoff(np, rulename)
			else
				mesecon:changesignal(np, minetest.get_node(np), rulename, mesecon.state.off)
			end
		end
	end
end

function mesecon:receptor_off(pos, rules)
	if MESECONS_GLOBALSTEP then
		rules = rules or mesecon.rules.default
		mesecon.r_to_update[#mesecon.r_to_update+1]={pos=pos, rules=rules, action="off"}
	else
		mesecon:receptor_off_i(pos, rules)
	end
end


print("[OK] Mesecons")

--The actual wires
dofile(minetest.get_modpath("mesecons").."/wires.lua");

--Services like turnoff receptor on dignode and so on
dofile(minetest.get_modpath("mesecons").."/services.lua");
