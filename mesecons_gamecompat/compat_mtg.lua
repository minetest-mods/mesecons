--Aliases

minetest.register_alias("mesecons_gamecompat:chest", "default:chest")
minetest.register_alias("mesecons_gamecompat:chest_locked", "default:chest_locked")
minetest.register_alias("mesecons_gamecompat:coalblock", "default:coalblock")
minetest.register_alias("mesecons_gamecompat:cobble", "default:cobble")
minetest.register_alias("mesecons_gamecompat:glass", "default:glass")
minetest.register_alias("mesecons_gamecompat:lava_source", "default:lava_source")
minetest.register_alias("mesecons_gamecompat:mese", "default:mese")
minetest.register_alias("mesecons_gamecompat:mese_crystal", "default:mese_crystal")
minetest.register_alias("mesecons_gamecompat:mese_crystal_fragment", "default:mese_crystal_fragment")
minetest.register_alias("mesecons_gamecompat:obsidian_glass", "default:obsidian_glass")
minetest.register_alias("mesecons_gamecompat:stone", "default:stone")
minetest.register_alias("mesecons_gamecompat:steel_ingot", "default:steel_ingot")
minetest.register_alias("mesecons_gamecompat:steelblock", "default:steelblock")
minetest.register_alias("mesecons_gamecompat:torch", "default:torch")

if minetest.get_modpath("dye") then
	for _, color in ipairs(mesecon.dye_colors) do
		minetest.register_alias("mesecons_gamecompat:dye_" .. color, "dye:" .. color)
	end
end

-- Sounds

mesecon.node_sound.default = default.node_sound_defaults()
mesecon.node_sound.glass = default.node_sound_glass_defaults()
mesecon.node_sound.leaves = default.node_sound_leaves_defaults()
mesecon.node_sound.stone = default.node_sound_stone_defaults()
mesecon.node_sound.wood = default.node_sound_wood_defaults()

if minetest.get_modpath("fire") then
	mesecon.sound_name.fire = "fire_fire"
end

if minetest.get_modpath("tnt") then
	mesecon.sound_name.explode = "tnt_explode"
end

-- Textures

mesecon.texture.steel_block = "default_steel_block.png"

-- MVPS stoppers

if minetest.get_modpath("mesecons_mvps") then
	-- All of the locked and internal nodes in Minetest Game
	for _, name in ipairs({
		"default:chest_locked",
		"default:chest_locked_open",
		"doors:hidden",
	}) do
		mesecon.register_mvps_stopper(name)
	end
	core.register_on_mods_loaded(function()
		if minetest.get_modpath("doors") then
			for k,_ in pairs(doors.registered_doors) do
				mesecon.register_mvps_stopper(k)
			end
		end
		if minetest.get_modpath("beds") then
			for _,v in pairs(core.registered_nodes) do
				if v.groups and v.groups.bed then
					mesecon.register_mvps_stopper(v.name)
				end
			end
		end
	end)
end
