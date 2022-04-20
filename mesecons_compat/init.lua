if minetest.get_modpath("default") then
	minetest.register_alias("mesecons_compat:chest", "default:chest")
	minetest.register_alias("mesecons_compat:chest_locked", "default:chest_locked")
	minetest.register_alias("mesecons_compat:coalblock", "default:coalblock")
	minetest.register_alias("mesecons_compat:cobble", "default:cobble")
	minetest.register_alias("mesecons_compat:glass", "default:glass")
	minetest.register_alias("mesecons_compat:lava_source", "default:lava_source")
	minetest.register_alias("mesecons_compat:mese", "default:mese")
	minetest.register_alias("mesecons_compat:mese_crystal", "default:mese_crystal")
	minetest.register_alias("mesecons_compat:mese_crystal_fragment", "default:mese_crystal_fragment")
	minetest.register_alias("mesecons_compat:obsidian_glass", "default:obsidian_glass")
	minetest.register_alias("mesecons_compat:stone", "default:stone")
	minetest.register_alias("mesecons_compat:steel_ingot", "default:steel_ingot")
	minetest.register_alias("mesecons_compat:steelblock", "default:steelblock")
	minetest.register_alias("mesecons_compat:torch", "default:torch")

	mesecon.node_sound_defaults = default.node_sound_defaults()
	mesecon.node_sound_glass_defaults = default.node_sound_glass_defaults()
	mesecon.node_sound_leaves_defaults = default.node_sound_leaves_defaults()
	mesecon.node_sound_stone_defaults = default.node_sound_stone_defaults()
	mesecon.node_sound_wood_defaults = default.node_sound_wood_defaults()

	mesecon.steel_block_texture = "default_steel_block.png"
end

if minetest.get_modpath("fire") then
	mesecon.sound_name_fire = "fire_fire"
end

if minetest.get_modpath("tnt") then
	mesecon.sound_name_explode = "tnt_explode"
end
