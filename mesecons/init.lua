-- |\    /| ____ ____  ____ _____   ____         _____
-- | \  / | |    |     |    |      |    | |\   | |
-- |  \/  | |___ ____  |___ |      |    | | \  | |____
-- |      | |        | |    |      |    | |  \ |     |
-- |      | |___ ____| |___ |____  |____| |   \| ____|
-- by Jeija, Uberi (Temperest), sfan5, VanessaE, 
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
mesecon.effectors={}
mesecon.conductors={}

-- INCLUDE SETTINGS
dofile(minetest.get_modpath("mesecons").."/settings.lua")

--Presets (eg default rules)
dofile(minetest.get_modpath("mesecons").."/presets.lua");

--Internal API
dofile(minetest.get_modpath("mesecons").."/internal.lua");

--Deprecated stuff
dofile(minetest.get_modpath("mesecons").."/legacy.lua");

-- API API API API API API API API API API API API API API API API API API




print("[OK] mesecons")

--The actual wires
dofile(minetest.get_modpath("mesecons").."/wires.lua");

--Services like turnoff receptor on dignode and so on
dofile(minetest.get_modpath("mesecons").."/services.lua");
