-- MOVESTONE
-- Non-sticky:
-- Moves along mesecon lines
-- Pushes all blocks in front of it
--
-- Sticky one
-- Moves along mesecon lines
-- Pushes all block in front of it
-- Pull all blocks in its back

local modname = core.get_current_modname()
local S = core.get_translator(modname)

-- settings:
local timer_interval = 1 / mesecon.setting("movestone_speed", 3)
local max_push = mesecon.setting("movestone_max_push", 50)
local max_pull = mesecon.setting("movestone_max_pull", 50)

local rotations = dofile(core.get_modpath(modname) .. "/rotations.lua")

local alldirs_default = mesecon.merge_rule_sets(mesecon.rules.default, mesecon.rules.alldirs)

-- helper functions:
local function get_movestone_direction(rule, param2, movestone_rules)
	local rulename = rotations.vec_to_dir(rule)
	local facedir = ((param2 % 32) % 24)
	local localrulename = rotations.rotate_dirname_facedir_inverse(rulename, facedir)
	local localmovedirname = movestone_rules[localrulename]
	return localmovedirname and rotations.rotate_dirname_facedir_to_vector(localmovedirname, facedir)
end

-- registration functions:
function mesecon.register_movestone(name, def, is_sticky, movestone_rules)
	local function movestone_move(pos, node, rulename)
		local direction = get_movestone_direction(rulename, node.param2, movestone_rules)
		if not direction then return end
		local frontpos = vector.add(pos, direction)
		local meta = core.get_meta(pos)
		local owner = meta:get_string("owner")

		-- ### Step 1: Push nodes in front ###
		local success, stack, oldstack = mesecon.mvps_push(frontpos, direction, max_push, owner)
		if not success then
			if stack == "protected" then
				meta:set_string("infotext", "Can't move: protected area on the way")
				return
			end
			core.get_node_timer(pos):start(timer_interval)
			return
		end
		mesecon.mvps_move_objects(frontpos, direction, oldstack)

		-- ### Step 2: Move the movestone ###
		core.set_node(frontpos, node)
		local meta2 = core.get_meta(frontpos)
		meta2:set_string("owner", owner)
		core.remove_node(pos)
		mesecon.on_dignode(pos, node)
		mesecon.on_placenode(frontpos, node)
		core.get_node_timer(frontpos):start(timer_interval)
		core.sound_play("movestone", { pos = pos, max_hear_distance = 20, gain = 0.5 }, true)

		-- ### Step 3: If sticky, pull stack behind ###
		if is_sticky then
			local backpos = vector.subtract(pos, direction)
			local success, _, oldstack = mesecon.mvps_pull_all(backpos, direction, max_pull, owner)
			if success then
				mesecon.mvps_move_objects(backpos, vector.multiply(direction, -1), oldstack, -1)
			end
		end

		-- ### Step 4: Let things fall ###
		core.check_for_falling(vector.offset(pos, 0, 1, 0))
	end

	def.is_ground_content = false
	def.paramtype2 = "facedir"

	def.mesecons = {effector = {
		action_on = function(pos, node, rulename)
			if rulename and not core.get_node_timer(pos):is_started() then
				movestone_move(pos, node, rulename)
			end
		end,
		rules = alldirs_default,
	}}

	def.after_place_node = mesecon.mvps_set_owner

	def.on_punch = function(pos, _, player)
		local player_name = player and player.get_player_name and player:get_player_name()
		if mesecon.mvps_claim(pos, player_name) then
			core.get_node_timer(pos):start(timer_interval)
			core.chat_send_player(player_name, "Reclaimed movestone")
		end
	end

	def.on_timer = function(pos)
		local sourcepos = mesecon.is_powered(pos)
		if not sourcepos then
			return
		end
		local rulename = vector.subtract(sourcepos[1], pos)
		mesecon.activate(pos, core.get_node(pos), rulename, 0)
	end

	def.on_blast = mesecon.on_blastnode

	core.register_node(name, def)
end

local vertical_movestone_rules = {
	F = "D",
	R = "D",
	B = "U",
	L = "U",
}

local horizontal_movestone_rules = {
	F = "L",
	B = "R",
	L = "F",
	R = "B",
}

-- registration:
mesecon.register_movestone("mesecons_movestones:movestone", {
	tiles = {
		"jeija_movestone_side.png",
		"jeija_movestone_side.png",
		"jeija_movestone_arrows.png^[transformFX",
		"jeija_movestone_arrows.png^[transformFX",
		"jeija_movestone_arrows.png",
		"jeija_movestone_arrows.png",
	},
	groups = {cracky = 3},
    description = S("Movestone"),
	sounds = mesecon.node_sound.stone
}, false, horizontal_movestone_rules)

mesecon.register_movestone("mesecons_movestones:sticky_movestone", {
	tiles = {
		"jeija_movestone_side.png",
		"jeija_movestone_side.png",
		"jeija_sticky_movestone.png^[transformFX",
		"jeija_sticky_movestone.png^[transformFX",
		"jeija_sticky_movestone.png",
		"jeija_sticky_movestone.png",
	},
	groups = {cracky = 3},
    description = S("Sticky Movestone"),
	sounds = mesecon.node_sound.stone,
}, true, horizontal_movestone_rules)

mesecon.register_movestone("mesecons_movestones:movestone_vertical", {
	tiles = {
		"jeija_movestone_side.png",
		"jeija_movestone_side.png",
		"jeija_movestone_arrows.png^[transformFXR90",
		"jeija_movestone_arrows.png^[transformR90",
		"jeija_movestone_arrows.png^[transformFXR90",
		"jeija_movestone_arrows.png^[transformR90",
	},
	groups = {cracky = 3},
    description = S("Vertical Movestone"),
	sounds = mesecon.node_sound.stone
}, false, vertical_movestone_rules)

mesecon.register_movestone("mesecons_movestones:sticky_movestone_vertical", {
	tiles = {
		"jeija_movestone_side.png^(mesecons_glue.png^[opacity:127)",
		"jeija_movestone_side.png^(mesecons_glue.png^[opacity:127)",
		"jeija_movestone_arrows.png^[transformFXR90",
		"jeija_movestone_arrows.png^[transformR90",
		"jeija_movestone_arrows.png^[transformFXR90",
		"jeija_movestone_arrows.png^[transformR90",
	},
	groups = {cracky = 3},
    description = S("Vertical Sticky Movestone"),
	sounds = mesecon.node_sound.stone,
}, true, vertical_movestone_rules)


-- crafting:
-- base recipe:
core.register_craft({
	output = "mesecons_movestones:movestone 2",
	recipe = {
		{"mesecons_gamecompat:stone", "mesecons_gamecompat:stone", "mesecons_gamecompat:stone"},
		{"group:mesecon_conductor_craftable", "group:mesecon_conductor_craftable", "group:mesecon_conductor_craftable"},
		{"mesecons_gamecompat:stone", "mesecons_gamecompat:stone", "mesecons_gamecompat:stone"},
	}
})

-- conversation:
core.register_craft({
	type = "shapeless",
	output = "mesecons_movestones:movestone",
	recipe = {"mesecons_movestones:movestone_vertical"},
})

core.register_craft({
	type = "shapeless",
	output = "mesecons_movestones:movestone_vertical",
	recipe = {"mesecons_movestones:movestone"},
})

core.register_craft({
	type = "shapeless",
	output = "mesecons_movestones:sticky_movestone",
	recipe = {"mesecons_movestones:sticky_movestone_vertical"},
})

core.register_craft({
	type = "shapeless",
	output = "mesecons_movestones:sticky_movestone_vertical",
	recipe = {"mesecons_movestones:sticky_movestone"},
})

-- make sticky:
core.register_craft({
	output = "mesecons_movestones:sticky_movestone",
	recipe = {
		{"mesecons_materials:glue", "mesecons_movestones:movestone", "mesecons_materials:glue"},
	}
})

core.register_craft({
	output = "mesecons_movestones:sticky_movestone_vertical",
	recipe = {
		{"mesecons_materials:glue"},
		{"mesecons_movestones:movestone_vertical"},
		{"mesecons_materials:glue"},
	}
})


-- legacy code:
core.register_alias("mesecons_movestones:movestone_active",
		"mesecons_movestones:movestone")
core.register_alias("mesecons_movestones:sticky_movestone_active",
		"mesecons_movestones:sticky_movestone")
