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
		return {x = -1, y = 0, z = 0}
	elseif rulename.z < 0 then
		return {x = 1, y = 0, z = 0}
	elseif rulename.x > 0 then
		return {x = 0, y = 0, z = -1}
	elseif rulename.x < 0 then
		return {x = 0, y = 0, z = 1}
	end
end

local timer_interval = 1 / mesecon.setting("movestone_speed", 3)
local max_push = mesecon.setting("movestone_max_push", 50)
local max_pull = mesecon.setting("movestone_max_pull", 50)

function mesecon.register_movestone(name, def, is_sticky)
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
			print(dump(rulename))
			if rulename and not minetest.get_node_timer(pos):is_started() then
				movestone_move(pos, node, rulename)
			end
		end,
		rules = mesecon.rules.default,
	}}

	def.on_timer = function(pos, elapsed)
		local rulenames = mesecon.is_powered(pos)
		if not rulenames then
			return
		end
		for i = 1, #rulenames do
			mesecon.activate(pos, minetest.get_node(pos), rulenames[1], 0)
		end
	end

	def.drop = name

	minetest.register_node(name, def)
end

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
    description = "Movestone",
	sounds = default.node_sound_stone_defaults()
}, false)

minetest.register_craft({
	output = "mesecons_movestones:movestone 2",
	recipe = {
		{"default:stone", "default:stone", "default:stone"},
		{"group:mesecon_conductor_craftable", "group:mesecon_conductor_craftable", "group:mesecon_conductor_craftable"},
		{"default:stone", "default:stone", "default:stone"},
	}
})

-- STICKY_MOVESTONE
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
    description = "Sticky Movestone",
	sounds = default.node_sound_stone_defaults(),
}, true)

minetest.register_craft({
	output = "mesecons_movestones:sticky_movestone",
	recipe = {
		{"mesecons_materials:glue", "mesecons_movestones:movestone", "mesecons_materials:glue"},
	}
})
