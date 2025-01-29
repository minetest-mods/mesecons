mesecon.node_sound = {}

mesecon.sound_name = {}

mesecon.texture = {}

mesecon.dye_colors = {
	"red", "green", "blue", "grey", "dark_grey", "yellow",
	"orange", "white", "pink", "magenta", "cyan", "violet",
}

if minetest.get_modpath("default") then
	minetest.log("info", "Mesecons: detected Minetest Game for game compatibility")
	dofile(minetest.get_modpath("mesecons_gamecompat").."/compat_mtg.lua")
end

if minetest.get_modpath("mcl_core") then
	minetest.log("info", "Mesecons: detected MineClonia Game for game compatibility")
	dofile(minetest.get_modpath("mesecons_gamecompat").."/compat_mcl.lua")
end

if minetest.get_modpath("doors") then
	dofile(minetest.get_modpath("mesecons_gamecompat").."/doors.lua")
end
