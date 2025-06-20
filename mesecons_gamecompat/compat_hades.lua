--Aliases

core.register_alias("mesecons_gamecompat:chest", "hades_chests:chest")
core.register_alias("mesecons_gamecompat:chest_locked", "hades_chests:chest_locked")
core.register_alias("mesecons_gamecompat:coalblock", "hades_core:coalblock")
core.register_alias("mesecons_gamecompat:cobble", "hades_core:cobble")
core.register_alias("mesecons_gamecompat:glass", "hades_core:glass")
core.register_alias("mesecons_gamecompat:lava_source", "hades_core:lava_source")
core.register_alias("mesecons_gamecompat:mese", "hades_core:mese")
core.register_alias("mesecons_gamecompat:mese_crystal", "hades_core:mese_crystal")
core.register_alias("mesecons_gamecompat:mese_crystal_fragment", "hades_core:mese_crystal_fragment")
core.register_alias("mesecons_gamecompat:obsidian_glass", "hades_core:obsidian_glass")
core.register_alias("mesecons_gamecompat:stone", "hades_core:stone")
core.register_alias("mesecons_gamecompat:steel_ingot", "hades_core:steel_ingot")
core.register_alias("mesecons_gamecompat:steelblock", "hades_core:steelblock")
core.register_alias("mesecons_gamecompat:torch", "hades_torches:torch")

if core.get_modpath("hades_dye") then
	for _, color in ipairs(mesecon.dye_colors) do
		core.register_alias("mesecons_gamecompat:dye_" .. color, "hades_dye:" .. color)
	end
end

-- Sounds

mesecon.node_sound.default = hades_sounds.node_sound_defaults()
mesecon.node_sound.glass = hades_sounds.node_sound_glass_defaults()
mesecon.node_sound.leaves = hades_sounds.node_sound_leaves_defaults()
mesecon.node_sound.stone = hades_sounds.node_sound_stone_defaults()
mesecon.node_sound.wood = hades_sounds.node_sound_wood_defaults()

if core.get_modpath("hades_fire") then
	mesecon.sound_name.fire = "fire_fire"
end

if core.get_modpath("hades_tnt") then
	mesecon.sound_name.explode = "tnt_explode"
end

-- Textures

mesecon.texture.steel_block = "default_steel_block.png"

-- MVPS stoppers

if core.get_modpath("mesecons_mvps") then
	-- All of the locked and internal nodes in Hades Revisited
	for _, name in ipairs({
		"hades_chests:chest_locked",
		"hades_chests:chest_locked_open",
		"hades_doors:hidden",
		"hades_doors:hidden_center",
	}) do
		mesecon.register_mvps_stopper(name)
	end
	core.register_on_mods_loaded(function()
		if core.get_modpath("hades_doors") then
			for _,v in pairs(core.registered_nodes) do
				if v.groups and (v.groups.door or v.groups.trapdoor) then
					mesecon.register_mvps_stopper(v.name)
				end
			end
		end
		if core.get_modpath("hades_beds") then
			for _,v in pairs(core.registered_nodes) do
				if v.groups and v.groups.bed then
					mesecon.register_mvps_stopper(v.name)
				end
			end
		end
	end)
end
