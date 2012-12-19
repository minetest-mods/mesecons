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
dofile(minetest.get_modpath("mesecons").."/legacy.lua");

-- API
-- these are the only functions you need to remember

function mesecon:receptor_on(pos, rules)
	rules = rules or mesecon.rules.default

	for _, rule in ipairs(rules) do
		local np = mesecon:addPosRule(pos, rule)
		local link, rulename = mesecon:rules_link(pos, np, rules)
		if link then
			mesecon:turnon(np, rulename)
		end
	end
end

function mesecon:receptor_off(pos, rules)
	rules = rules or mesecon.rules.default

	for _, rule in ipairs(rules) do
		local np = mesecon:addPosRule(pos, rule)
		local link, rulename = mesecon:rules_link(pos, np, rules)
		if link then
			mesecon:turnoff(np, rulename)
		end
	end
end


print("[OK] mesecons")

--The actual wires
dofile(minetest.get_modpath("mesecons").."/wires.lua");

--Services like turnoff receptor on dignode and so on
dofile(minetest.get_modpath("mesecons").."/services.lua");
