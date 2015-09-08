-- MOVESTONE
-- Non-sticky:
-- Moves along mesecon lines
-- Pushes all blocks in front of it
--
-- Sticky one
-- Moves along mesecon lines
-- Pushes all block in front of it
-- Pull all blocks in its back

function mesecon.get_movestone_direction(pos)
	local lpos
	local rules = {
		{x=0,  y=1,  z=-1},
		{x=0,  y=0,  z=-1},
		{x=0,  y=-1, z=-1},
		{x=0,  y=1,  z=1},
		{x=0,  y=-1, z=1},
		{x=0,  y=0,  z=1},
		{x=1,  y=0,  z=0},
		{x=1,  y=1,  z=0},
		{x=1,  y=-1, z=0},
		{x=-1, y=1,  z=0},
		{x=-1, y=-1, z=0},
		{x=-1, y=0,  z=0}}

	lpos = {x=pos.x+1, y=pos.y, z=pos.z}
	for n = 1, 3 do
		if mesecon.is_power_on(lpos, rules[n].x, rules[n].y, rules[n].z) then
			return {x=0, y=0, z=-1}
		end
	end

	lpos = {x = pos.x-1, y = pos.y, z = pos.z}
	for n=4, 6 do
		if mesecon.is_power_on(lpos, rules[n].x, rules[n].y, rules[n].z) then
			return {x=0, y=0, z=1}
		end
	end

	lpos = {x = pos.x, y = pos.y, z = pos.z+1}
	for n=7, 9 do
		if mesecon.is_power_on(lpos, rules[n].x, rules[n].y, rules[n].z) then
			return {x=-1, y=0, z=0}
		end
	end

	lpos = {x = pos.x, y = pos.y, z = pos.z-1}
	for n=10, 12 do
		if mesecon.is_power_on(lpos, rules[n].x, rules[n].y, rules[n].z) then
			return {x=1, y=0, z=0}
		end
	end
end

function mesecon.register_movestone(name, def, is_sticky)
	local timer_interval = 1 / mesecon.setting("movestone_speed", 3)
	local name_active = name.."_active"

	local function movestone_move (pos)
		if minetest.get_node(pos).name ~= name_active then
			return
		end

		local direction = mesecon.get_movestone_direction(pos)
		if not direction then
			minetest.set_node(pos, {name = name})
			return
		end
		local frontpos = vector.add(pos, direction)
		local backpos = vector.subtract(pos, direction)

		-- ### Step 1: Push nodes in front ###
		local maxpush = mesecon.setting("movestone_max_push", 50)
		local maxpull = mesecon.setting("movestone_max_pull", 50)
		local success, stack, oldstack = mesecon.mvps_push(frontpos, direction, maxpush)
		if success then
			mesecon.mvps_process_stack(stack)
			mesecon.mvps_move_objects(frontpos, direction, oldstack)
		-- Too large stack/stopper in the way: try again very soon
		else
			minetest.after(0.05, movestone_move, pos)
			return
		end

		-- ### Step 2: Move the movestone ###
		local node = minetest.get_node(pos)
		minetest.set_node(frontpos, node)
		minetest.remove_node(pos)
		mesecon.on_dignode(pos, node)
		mesecon.on_placenode(frontpos, node)
		minetest.after(timer_interval, movestone_move, frontpos)

		-- ### Step 3: If sticky, pull stack behind ###
		if is_sticky then
			mesecon.mvps_pull_all(backpos, direction, maxpull)
		end
	end

	def.mesecons = {effector = {
		action_on = function (pos)
			if minetest.get_node(pos).name ~= name_active then
				minetest.set_node(pos, {name = name_active})
				movestone_move(pos)
			end
		end,
		action_off = function (pos)
			minetest.set_node(pos, {name = name})
		end
	}}

	def.drop = name

	minetest.register_node(name, def)

	-- active node only
	local def_active = table.copy(def)
	def_active.groups.not_in_creative_inventory = 1
	minetest.register_node(name_active, def_active)
end

mesecon.register_movestone("mesecons_movestones:movestone", {
	tiles = {"jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_arrows.png", "jeija_movestone_arrows.png"},
	groups = {cracky=3},
    	description="Movestone",
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
	tiles = {"jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_sticky_movestone.png", "jeija_sticky_movestone.png"},
	inventory_image = minetest.inventorycube("jeija_sticky_movestone.png", "jeija_movestone_side.png", "jeija_movestone_side.png"),
	groups = {cracky=3},
    	description="Sticky Movestone",
	sounds = default.node_sound_stone_defaults(),
}, true)

minetest.register_craft({
	output = "mesecons_movestones:sticky_movestone 2",
	recipe = {
		{"mesecons_materials:glue", "mesecons_movestones:movestone", "mesecons_materials:glue"},
	}
})

-- Don't allow pushing movestones while they're active
mesecon.register_mvps_stopper("mesecons_movestones:movestone_active")
mesecon.register_mvps_stopper("mesecons_movestones:sticky_movestone_active")
