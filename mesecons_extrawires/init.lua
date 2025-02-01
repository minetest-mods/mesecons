dofile(minetest.get_modpath("mesecons_extrawires").."/crossover.lua");
dofile(minetest.get_modpath("mesecons_extrawires").."/tjunction.lua");
dofile(minetest.get_modpath("mesecons_extrawires").."/corner.lua");
dofile(minetest.get_modpath("mesecons_extrawires").."/doublecorner.lua");
dofile(minetest.get_modpath("mesecons_extrawires").."/vertical.lua");
if core.registered_nodes["mesecons_gamecompat:mese"] then
	dofile(minetest.get_modpath("mesecons_extrawires").."/mesewire.lua");
end
