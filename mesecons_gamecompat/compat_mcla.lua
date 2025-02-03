
--Aliases

minetest.register_alias("mesecons_gamecompat:chest", "mcl_chests:chest")
minetest.register_alias("mesecons_gamecompat:chest_locked", "mcl_chests:chest")
minetest.register_alias("mesecons_gamecompat:coalblock", "mcl_core:coalblock")
minetest.register_alias("mesecons_gamecompat:cobble", "mcl_core:cobble")
minetest.register_alias("mesecons_gamecompat:glass", "mcl_core:glass")
minetest.register_alias("mesecons_gamecompat:lava_source", "mcl_core:lava_source")
minetest.register_alias("mesecons_gamecompat:mese", "mcl_redstone_torch:redstoneblock")
minetest.register_alias("mesecons_gamecompat:mese_crystal", "mcl_redstone:redstone")
minetest.register_alias("mesecons_gamecompat:mese_crystal_fragment", "mcl_redstone:redstone")
minetest.register_alias("mesecons_gamecompat:obsidian_glass", "mcl_core:glass")
minetest.register_alias("mesecons_gamecompat:stone", "mcl_core:stone")
minetest.register_alias("mesecons_gamecompat:steel_ingot", "mcl_core:iron_ingot")
minetest.register_alias("mesecons_gamecompat:steelblock", "mcl_core:ironblock")
minetest.register_alias("mesecons_gamecompat:torch", "mcl_torches:torch")

if minetest.get_modpath("mcl_dyes") then
	for color, def in ipairs(mcl_dyes.colors) do
		minetest.register_alias("mesecons_gamecompat:dye_" .. def.mcl2, "mcl_dyes:" .. color)
	end
end

-- Sounds

mesecon.node_sound.default = mcl_sounds.node_sound_defaults()
mesecon.node_sound.glass = mcl_sounds.node_sound_glass_defaults()
mesecon.node_sound.leaves = mcl_sounds.node_sound_leaves_defaults()
mesecon.node_sound.stone = mcl_sounds.node_sound_stone_defaults()
mesecon.node_sound.wood = mcl_sounds.node_sound_wood_defaults()

if minetest.get_modpath("mcl_fire") then
	mesecon.sound_name.fire = "fire_fire"
end

if minetest.get_modpath("mcl_tnt") then
	mesecon.sound_name.explode = "tnt_explode"
end

-- Textures

mesecon.texture.steel_block = "default_steel_block.png"

if minetest.get_modpath("mesecons_mvps") then
	for k,v in pairs(core.registered_nodes) do
		local is_stopper = mesecon.mvps_stoppers[k]
		if v.groups and v.groups.unmovable_by_piston then
			mesecon.register_mvps_stopper(k)
		end
		if is_stopper then
			local groups = table.copy(v.groups or {})
			groups.unmovable_by_piston = 1
			v.groups = groups
			core.register_node(":"..k, v)
		end
	end
	for k,v in pairs(core.registered_entities) do
		local is_unmov = mesecon.mvps_unmov[k]
		if v._mcl_pistons_unmovable then
			mesecon.register_mvps_unmov(k)
		end
		if is_unmov then
			v._mcl_pistons_unmovable = true
			core.register_entity(":"..k, v)
		end
	end

	core.register_on_mods_loaded(function()
		for _,v in pairs(core.registered_nodes) do
			if v.groups and v.groups.bed then
				mesecon.register_mvps_stopper(v.name)
			end
			if v.groups and v.groups.door then
				mesecon.register_mvps_stopper(v.name)
			end
		end
	end)
end

core.register_craft({
	output = "mesecons:wire_00000000_off",
	recipe = {{"mcl_redstone:redstone"}}
})
core.register_craft({
	output = "mcl_redstone:redstone",
	recipe = {{"mesecons:wire_00000000_off"}}
})
