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

function mesecon.register_movestone_entity(is_sticky)
	local node_name = "mesecons_movestones:"..(is_sticky and "sticky_" or "").."movestone"
	local texture_png = (is_sticky and "jeija_sticky_movestone.png" or "jeija_movestone_arrows.png")
	local roundpos = function(pos)
		return {x=math.floor(pos.x+0.5), y=math.floor(pos.y+0.5), z=math.floor(pos.z+0.5)}
	end
	--this method returns oldpos, changed by less than 1.5
	local addmaxone = function(oldpos, roundedpos, pos)
		local fraction = pos - roundedpos
		--oldpos was rounded, so we add the newest fraction we know (may be negative)
		local ret = oldpos + fraction
		--the rounded difference.
		local diff = roundedpos - oldpos
		if diff >= 1 then
			diff = 1
		end
		if diff <= -1 then
			diff = -1
		end
		--in no-lag situations, we return
		-- ret + diff
		-- = oldpos + fraction + roundedpos - oldpos
		-- = fraction + roundedpos
		-- = pos - roundedpos + roundedpos = pos
		return ret + diff
	end
	local vecaddmaxone = function(oldpos, pos)
		local rpos = roundpos(pos)
		return {
			x=addmaxone(oldpos.x, rpos.x, pos.x),
			y=addmaxone(oldpos.y, rpos.y, pos.y),
			z=addmaxone(oldpos.z, rpos.z, pos.z)}
	end
	minetest.register_entity(node_name.."_entity", {
		physical = false,
		visual = "sprite",
		textures = {"jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", texture_png, texture_png},
		collisionbox = {-0.5,-0.5,-0.5, 0.5, 0.5, 0.5},
		visual = "cube",
		lastdir = {x=0, y=0, z=0},
		lastpos = {x=0, y=0, z=0},

		on_activate = function(self, staticdata, dtime_s)
			self.lastpos = roundpos(self.object:getpos())
		end,

		on_punch = function(self, hitter)
			self.object:remove()
			hitter:get_inventory():add_item("main", node_name)
		end,

		on_step = function(self, dtime)
			local pos = self.object:getpos()
			local unroundedpos = vecaddmaxone(self.lastpos, pos)
			pos = roundpos(unroundedpos)

			self.lastpos = pos
			local direction = mesecon.get_movestone_direction(pos)

			local maxpush = mesecon.setting("movestone_max_push", 50)
			if not direction then -- no mesecon power
				--push only solid nodes
				local name = minetest.get_node(pos).name
				if  name ~= "air" and name ~= "ignore"
				and ((not minetest.registered_nodes[name])
				or minetest.registered_nodes[name].liquidtype == "none") then
					mesecon.mvps_push(pos, self.lastdir, maxpush)
					if is_sticky then
						mesecon.mvps_pull_all(pos, self.lastdir)
					end
				end
				local nn = {name=node_name}
				minetest.add_node(pos, nn)
				self.object:remove()
				mesecon.on_placenode(pos, nn)
				return
			end

			local success, stack, oldstack =
				mesecon.mvps_push(pos, direction, maxpush)
			if not success then -- Too large stack/stopper in the way
				local nn = {name=node_name}
				minetest.add_node(pos, nn)
				self.object:remove()
				mesecon.on_placenode(pos, nn)
				return
			else
				mesecon.mvps_process_stack (stack)
				mesecon.mvps_move_objects  (pos, direction, oldstack)
				self.lastdir = direction
			end

			self.object:setpos(unroundedpos)
			self.object:setvelocity({x=direction.x*2, y=direction.y*2, z=direction.z*2})

			if is_sticky then
				mesecon.mvps_pull_all(pos, direction)
			end
		end
	})
end

minetest.register_node("mesecons_movestones:movestone", {
	tiles = {"jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_arrows.png", "jeija_movestone_arrows.png"},
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	groups = {cracky=3},
    	description="Movestone",
	sounds = default.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_on = function (pos, node)
			local direction=mesecon.get_movestone_direction(pos)
			if not direction then return end
			minetest.remove_node(pos)
			mesecon.on_dignode(pos, node)
			minetest.add_entity(pos, "mesecons_movestones:movestone_entity")
		end
	}}
})

mesecon.register_movestone_entity(false)

minetest.register_craft({
	output = "mesecons_movestones:movestone 2",
	recipe = {
		{"default:stone", "default:stone", "default:stone"},
		{"group:mesecon_conductor_craftable", "group:mesecon_conductor_craftable", "group:mesecon_conductor_craftable"},
		{"default:stone", "default:stone", "default:stone"},
	}
})



-- STICKY_MOVESTONE

minetest.register_node("mesecons_movestones:sticky_movestone", {
	tiles = {"jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_sticky_movestone.png", "jeija_sticky_movestone.png"},
	inventory_image = minetest.inventorycube("jeija_sticky_movestone.png", "jeija_movestone_side.png", "jeija_movestone_side.png"),
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	groups = {cracky=3},
    	description="Sticky Movestone",
	sounds = default.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_on = function (pos, node)
			local direction=mesecon.get_movestone_direction(pos)
			if not direction then return end
			minetest.remove_node(pos)
			mesecon.on_dignode(pos, node)
			minetest.add_entity(pos, "mesecons_movestones:sticky_movestone_entity")
		end
	}}
})

minetest.register_craft({
	output = "mesecons_movestones:sticky_movestone 2",
	recipe = {
		{"mesecons_materials:glue", "mesecons_movestones:movestone", "mesecons_materials:glue"},
	}
})

mesecon.register_movestone_entity(true)


mesecon.register_mvps_unmov("mesecons_movestones:movestone_entity")
mesecon.register_mvps_unmov("mesecons_movestones:sticky_movestone_entity")
