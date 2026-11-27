-- An on_rotate callback for mesecons components.
function mesecon.on_rotate(pos, node, _, _, new_param2)
	local new_node = {name = node.name, param1 = node.param1, param2 = new_param2}
	new_node.param2 = screwdriver.rotate.facedir(pos, node, screwdriver.ROTATE_FACE)
	minetest.swap_node(pos, new_node)
	mesecon.on_dignode(pos, node)
	mesecon.on_placenode(pos, new_node)
	minetest.check_for_falling(pos)
	return true
end

-- Returns a rules getter function that returns different rules depending on the node's horizontal rotation.
-- If param2 % 4 == 0, then the rules returned by the getter are a copy of base_rules.
function mesecon.horiz_rules_getter(base_rules)
	local rotations = {mesecon.tablecopy(base_rules)}
	print(rotations)
	for i = 2, 4 do
		local right_rules = rotations[i - 1]
		if not right_rules[1] or right_rules[1].x then
			-- flat rules
			rotations[i] = mesecon.rotate_rules_left(right_rules)
		else
			-- not flat
			rotations[i] = {}
			for j, rules in ipairs(right_rules) do
				rotations[i][j] = mesecon.rotate_rules_left(rules)
			end
		end
	end
	return function(node)
		return rotations[node.param2 % 4 + 1]
	end
end

-- Merges two tables, with entries from `replacements` taking precedence over
-- those from `base`. Returns the new table.
-- Values are deep-copied from either table, keys are referenced.
-- Numerical indices aren’t handled specially.
function mesecon.merge_tables(base, replacements)
	local ret = mesecon.tablecopy(replacements) -- these are never overriden so have to be copied in any case
	for k, v in pairs(base) do
		if ret[k] == nil then -- it could be `false`
			ret[k] = mesecon.tablecopy(v)
		end
	end
	return ret
end


--Aliases

minetest.register_alias("mesecons_gamecompat:chest", "mcl_chests:chest")
minetest.register_alias("mesecons_gamecompat:chest_locked", "mcl_chests:chest")
minetest.register_alias("mesecons_gamecompat:coalblock", "mcl_core:coalblock")
minetest.register_alias("mesecons_gamecompat:cobble", "mcl_core:cobble")
minetest.register_alias("mesecons_gamecompat:glass", "mcl_core:glass")
minetest.register_alias("mesecons_gamecompat:lava_source", "mcl_core:lava_source")
minetest.register_alias("mesecons_gamecompat:mese", "mesecons_torch:redstoneblock")
minetest.register_alias("mesecons_gamecompat:mese_crystal", "mesecons:redstone")
minetest.register_alias("mesecons_gamecompat:mese_crystal_fragment", "mesecons:redstone")
minetest.register_alias("mesecons_gamecompat:obsidian_glass", "mcl_core:glass")
minetest.register_alias("mesecons_gamecompat:stone", "mcl_core:stone")
minetest.register_alias("mesecons_gamecompat:steel_ingot", "mcl_core:iron_ingot")
minetest.register_alias("mesecons_gamecompat:steelblock", "mcl_core:ironblock")
minetest.register_alias("mesecons_gamecompat:torch", "mcl_torches:torch")

if minetest.get_modpath("mcl_dye") then
	for _, color in ipairs(mesecon.dye_colors) do
		minetest.register_alias("mesecons_gamecompat:dye_" .. color, "mcl_dye:" .. color)
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
	recipe = {{"mesecons:redstone"}}
})
core.register_craft({
	output = "mesecons:redstone",
	recipe = {{"mesecons:wire_00000000_off"}}
})

