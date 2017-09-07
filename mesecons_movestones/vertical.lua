-- MOVESTONE
-- Non-sticky:
-- Moves along mesecon lines
-- Pushes all blocks in front of it
--
-- Sticky one
-- Moves along mesecon lines
-- Pushes all block in front of it
-- Pull all blocks in its back

local function get_movestone_direction(rulename)
	if rulename.z > 0 then
		return {x = 0, y = -1, z = 0}
	elseif rulename.z < 0 then
		return {x = 0, y = 1, z = 0}
	elseif rulename.x > 0 then
		return {x = 0, y = -1, z = 0}
	elseif rulename.x < 0 then
		return {x = 0, y = 1, z = 0}
	end
end

local timer_interval = 1 / mesecon.setting("movestone_speed", 3)
local max_push = mesecon.setting("movestone_max_push", 50)
local max_pull = mesecon.setting("movestone_max_pull", 50)

function mesecon.register_vertical_movestone(name, def, is_sticky)
	local function movestone_move(pos, node, rulename)
		local direction = get_movestone_direction(rulename)
		local frontpos = vector.add(pos, direction)

		-- ### Step 1: Push nodes in front ###
		local success, stack, oldstack = mesecon.mvps_push(frontpos, direction, max_push)
		if not success then
			return
		end
		mesecon.mvps_process_stack(stack)
		mesecon.mvps_move_objects(frontpos, direction, oldstack)

		-- ### Step 2: Move the movestone ###
		minetest.set_node(frontpos, node)
		minetest.remove_node(pos)
		mesecon.on_dignode(pos, node)
		mesecon.on_placenode(frontpos, node)
		minetest.get_node_timer(frontpos):start(timer_interval)

		-- ### Step 3: If sticky, pull stack behind ###
		if is_sticky then
			local backpos = vector.subtract(pos, direction)
			mesecon.mvps_pull_all(backpos, direction, max_pull)
		end
	end

	def.mesecons = {effector = {
		action_on = function(pos, node, rulename)
			if rulename and not minetest.get_node_timer(pos):is_started() then
				movestone_move(pos, node, rulename)
			end
		end,
		rules = mesecon.rules.default,
	}}

	def.on_timer = function(pos, elapsed)
		local sourcepos = mesecon.is_powered(pos)
		if not sourcepos then
			return
		end
		local rulename = vector.subtract(sourcepos[1], pos)
		mesecon.activate(pos, minetest.get_node(pos), rulename, 0)
	end

	def.drop = name

	minetest.register_node(name, def)
end

mesecon.register_vertical_movestone("mesecons_movestones:movestone_vertical", {
	tiles = {
		"jeija_movestone_side.png",
		"jeija_movestone_side.png",
		"jeija_movestone_arrows.png^[transformFXR90",
		"jeija_movestone_arrows.png^[transformR90",
		"jeija_movestone_arrows.png^[transformFXR90",
		"jeija_movestone_arrows.png^[transformR90",
	},
	groups = {cracky = 3},
    description = "Vertical Movestone",
	sounds = default.node_sound_stone_defaults()
}, false)

minetest.register_craft({
	type = "shapeless",
	output = "mesecons_movestones:movestone_vertical",
	recipe = {"mesecons_movestones:movestone"},
})

-- STICKY_MOVESTONE
mesecon.register_vertical_movestone("mesecons_movestones:sticky_movestone_vertical", {
	tiles = {
		"jeija_movestone_side.png",
		"jeija_movestone_side.png",
		"jeija_sticky_movestone.png^[transformFXR90",
		"jeija_sticky_movestone.png^[transformR90",
		"jeija_sticky_movestone.png^[transformFXR90",
		"jeija_sticky_movestone.png^[transformR90",
	},
	groups = {cracky = 3},
    description = "Vertical Sticky Movestone",
	sounds = default.node_sound_stone_defaults(),
}, true)

minetest.register_craft({
	type = "shapeless",
	output = "mesecons_movestones:sticky_movestone_vertical",
	recipe = {"mesecons_movestones:sticky_movestone"},
})

minetest.register_craft({
	output = "mesecons_movestones:sticky_movestone_vertical",
	recipe = {
		{"mesecons_materials:glue"},
		{"mesecons_movestones:movestone_vertical"},
		{"mesecons_materials:glue"},
	}
})
