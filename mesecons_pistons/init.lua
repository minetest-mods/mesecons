--PISTONS
--registration normal one:
minetest.register_node("mesecons_pistons:piston_normal", {
	tile_images = {"jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_side.png"},
	groups = {cracky=3},
	paramtype2="facedir",
    	description="Piston",
	after_dig_node = function(pos)
		local objs = minetest.env:get_objects_inside_radius(pos, 2)
		for k, obj in pairs(objs) do
			if obj:get_entity_name() == "mesecons_pistons:piston_pusher_normal" then
				obj:remove()
			end
		end
	end
})

minetest.register_craft({
	output = '"mesecons_pistons:piston_normal" 2',
	recipe = {
		{"default:wood", "default:wood", "default:wood"},
		{"default:cobble", "default:steel_ingot", "default:cobble"},
		{"default:cobble", "mesecons:mesecon_off", "default:cobble"},
	}
})

--registration sticky one:
minetest.register_node("mesecons_pistons:piston_sticky", {
	tile_images = {"jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_sticky_side.png"},
	groups = {cracky=3},
	paramtype2="facedir",
    	description="Sticky Piston",
	after_dig_node = function(pos)
		local objs = minetest.env:get_objects_inside_radius(pos, 2)
		for k, obj in pairs(objs) do
			if obj:get_entity_name() == "mesecons_pistons:piston_pusher_sticky" then
				obj:remove()
			end
		end
	end
})

minetest.register_craft({
	output = "mesecons_pistons:piston_sticky",
	recipe = {
		{"mesecons_materials:glue"},
		{"mesecons_pistons:piston_normal"},
	}
})

-- get push direction
function mesecon:piston_get_direction(pos)
	local param2 = minetest.env:get_node(pos).param2
	if param2 == 3 then
		return {x=1, y=0, z=0}
	elseif param2 == 2 then
		return {x=0, y=0, z=1}
	elseif param2 == 1 then
		return {x=-1, y=0, z=0}
	else --param2 == 0
		return {x=0, y=0, z=-1}
	end
end

-- Push action
mesecon:register_on_signal_on(function (pos, node)
	if node.name ~= "mesecons_pistons:piston_normal" and node.name ~= "mesecons_pistons:piston_sticky" then
		return
	end

	local dir = mesecon:piston_get_direction(pos)

	--determine the number of nodes that need to be pushed
	local count = 0
	local checkpos = {x=pos.x + dir.x, y=pos.y + dir.y, z=pos.z + dir.z} --first node being pushed
	local checknode = minetest.env:get_node(checkpos)
	while checknode.name ~= "air"
	and checknode.name ~= "ignore"
	and checknode.name ~= "default:water_source"
	and checknode.name ~= "default:water_flowing"
	and checknode.name ~= "default:lava_source"
	and checknode.name ~= "default:lava_flowing" do
		--limit piston pushing capacity
		count = count + 1
		if count > 15 then
			return
		end

		--check for collision with stopper
		checkpos.x, checkpos.y, checkpos.z = checkpos.x + dir.x, checkpos.y + dir.y, checkpos.z + dir.z
		checknode = minetest.env:get_node(checkpos)
		if mesecon:is_mvps_stopper(checknode.name) then 
			return
		end
	end

	--add pusher entity
	local object
	if node.name == "mesecons_pistons:piston_normal" then --normal piston
		object = minetest.env:add_entity(pos, "mesecons_pistons:piston_pusher_normal")
	else --sticky piston
		object = minetest.env:add_entity(pos, "mesecons_pistons:piston_pusher_sticky")
	end

	--move pusher forward
	if ENABLE_PISTON_ANIMATION then
		object:setvelocity({x=dir.x * 4, y=dir.y * 4, z=dir.z * 4})
	else
		object:moveto(pos, false)
	end

	--move nodes forward
	pos.x, pos.y, pos.z = pos.x + dir.x, pos.y + dir.y, pos.z + dir.z --move to first node being pushed
	checknode = minetest.env:get_node(pos)
	minetest.env:dig_node(pos) --remove the first node
	for i = 1, count do
		--move to the next node
		pos.x, pos.y, pos.z = pos.x + dir.x, pos.y + dir.y, pos.z + dir.z

		--move the node forward
		local nextnode = minetest.env:get_node(pos)
		minetest.env:place_node(pos, checknode)
		checknode = nextnode
	end
end)

--Pull action (sticky only)
mesecon:register_on_signal_off(function(pos, node)
	if node.name ~= "mesecons_pistons:piston_sticky" and node.name ~= "mesecons_pistons:piston_normal" then
		return
	end

	--remove piston pusher
	local found = false --whether or not the piston was extended
	local objects = minetest.env:get_objects_inside_radius(pos, 2)
	for k, object in pairs(objects) do
		local name = object:get_luaentity().name
		if name == "mesecons_pistons:piston_pusher_normal" or name == "mesecons_pistons:piston_pusher_sticky" then
			found = true
			object:remove()
		end
	end

	--retract piston
	if found and node.name == "mesecons_pistons:piston_sticky" then
		local dir = mesecon:piston_get_direction(pos)
		pos.x, pos.y, pos.z = pos.x + dir.x, pos.y + dir.y, pos.z + dir.z --move to the node to be replaced
		local checknode = minetest.env:get_node(pos)
		if checknode.name == "air"
		or checknode.name == "default:water_source"
		or checknode.name == "default:water_flowing"
		or checknode.name == "default:lava_source"
		or checknode.name == "default:lava_flowing" then
			local checkpos = {x=pos.x + dir.x, y=pos.y + dir.y, z=pos.z + dir.z} --move to the node to be retracted
			local checknode = minetest.env:get_node(checkpos)
			if checknode.name ~= "air"
			and checknode.name ~= "ignore"
			and checknode.name ~= "default:water_source"
			and checknode.name ~= "default:water_flowing"
			and checknode.name ~= "default:lava_source"
			and checknode.name ~= "default:lava_flowing" then
				minetest.env:place_node(pos, checknode)
				minetest.env:dig_node(checkpos)
			end		
		end
	end
end)

--Piston Animation
local PISTON_PUSHER_NORMAL = {
	physical = false,
	visual = "sprite",
	textures = {"default_wood.png", "default_wood.png", "jeija_piston_pusher_normal.png", "jeija_piston_pusher_normal.png", "jeija_piston_pusher_normal.png", "jeija_piston_pusher_normal.png"},
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	timer=0,
}

function PISTON_PUSHER_NORMAL:on_step(dtime)
	self.timer = self.timer+dtime
	if self.timer >= 0.24 then
		self.object:setvelocity({x=0, y=0, z=0})
	end
end

local PISTON_PUSHER_STICKY = {
	physical = false,
	visual = "sprite",
	textures = {"default_wood.png", "default_wood.png", "jeija_piston_pusher_sticky.png", "jeija_piston_pusher_sticky.png", "jeija_piston_pusher_sticky.png", "jeija_piston_pusher_sticky.png"},
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	timer = 0,
}

function PISTON_PUSHER_STICKY:on_step(dtime)
	self.timer=self.timer+dtime
	if self.timer >= 0.24 then
		self.object:setvelocity({x=0, y=0, z=0})
	end
end

minetest.register_entity("mesecons_pistons:piston_pusher_normal", PISTON_PUSHER_NORMAL)
minetest.register_entity("mesecons_pistons:piston_pusher_sticky", PISTON_PUSHER_STICKY)
