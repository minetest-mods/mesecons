-- MOVESTONE

function mesecon:get_movestone_direction(pos)
	getactivated=0
	local direction = {x=0, y=0, z=0}
	local lpos

	local getactivated=0
	local rules=mesecon:get_rules("movestone")

	lpos={x=pos.x+1, y=pos.y, z=pos.z}
	for n=1, 3 do
		if mesecon:is_power_on(lpos, rules[n].x, rules[n].y, rules[n].z) then
			direction.z=-1
			return direction
		end
	end

	lpos={x=pos.x-1, y=pos.y, z=pos.z}
	for n=4, 6 do
		if mesecon:is_power_on(lpos, rules[n].x, rules[n].y, rules[n].z) then
			direction.z=1
			return direction
		end
	end

	lpos={x=pos.x, y=pos.y, z=pos.z+1}
	for n=7, 9 do
		if mesecon:is_power_on(lpos, rules[n].x, rules[n].y, rules[n].z) then
			direction.x=-1
			return direction
		end
	end

	lpos={x=pos.x, y=pos.y, z=pos.z-1}
	for n=10, 12 do
		if mesecon:is_power_on(lpos, rules[n].x, rules[n].y, rules[n].z) then
			direction.x=1
			return direction
		end
	end
end

minetest.register_node("mesecons_movestones:movestone", {
	tile_images = {"jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_arrows.png", "jeija_movestone_arrows.png"},
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	groups = {cracky=3},
    	description="Movestone",
})

minetest.register_entity("mesecons_movestones:movestone_entity", {
	physical = false,
	visual = "sprite",
	textures = {"jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_arrows.png", "jeija_movestone_arrows.png"},
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	--on_activate = function(self, staticdata)
		--self.object:setsprite({x=0,y=0}, 1, 0, true)
		--self.object:setvelocity({x=-3, y=0, z=0})
	--end,

	on_punch = function(self, hitter)
		self.object:remove()
		hitter:get_inventory():add_item("main", "mesecons_movestones:movestone")
	end,

	on_step = function(self, dtime)
		local pos = self.object:getpos()
		local colp = pos
		local velocity={}
		local direction=mesecon:get_movestone_direction(colp)

		--colp.x=colp.x-(direction.x/2.01)
		--colp.y=colp.y-direction.y
		--colp.z=colp.z-(direction.z/2.01)

		if not direction
		or (minetest.env:get_node_or_nil(pos).name ~="air" 
		and minetest.env:get_node_or_nil(pos).name ~= nil) then
			minetest.env:add_node(pos, {name="mesecons_movestones:movestone"})
			self.object:remove()
			return
		end 
		--if not mesecon:check_if_turnon(colp) then
		--	minetest.env:add_node(pos, {name="mesecons_movestones:movestone"})
		--	self.object:remove()
		--	return
		--end

		velocity.x=direction.x*3
		velocity.y=direction.y*3
		velocity.z=direction.z*3

		self.object:setvelocity(velocity)

		local np = {x=pos.x+direction.x, y=pos.y+direction.y, z=pos.z+direction.z}	
		local coln = minetest.env:get_node(np)
		if coln.name ~= "air" and coln.name ~="water" then
			local thisp= {x=pos.x, y=pos.y, z=pos.z}
			local thisnode=minetest.env:get_node(thisp)
			local nextnode={}
			minetest.env:dig_node(thisp)
			repeat
				thisp.x=thisp.x+direction.x
				thisp.y=thisp.y+direction.y
				thisp.z=thisp.z+direction.z
				nextnode=minetest.env:get_node(thisp)
				minetest.env:place_node(thisp, {name=thisnode.name})
				nodeupdate(thisp)
				thisnode=nextnode
			until thisnode.name=="air" or thisnode.name=="ignore" or thisnode.name=="default:water" or thisnode.name=="default:water_flowing"
		end
	end
})

minetest.register_craft({
	output = '"mesecons_movestones:movestone" 2',
	recipe = {
		{'"default:stone"', '"default:stone"', '"default:stone"'},
		{'"mesecons:mesecon_off"', '"mesecons:mesecon_off"', '"mesecons:mesecon_off"'},
		{'"default:stone"', '"default:stone"', '"default:stone"'},
	}
})

mesecon:register_on_signal_on(function (pos, node)
	if node.name=="mesecons_movestones:movestone" then
		local direction=mesecon:get_movestone_direction({x=pos.x, y=pos.y, z=pos.z})
		if not direction then return end
		local checknode={}
		local collpos={x=pos.x, y=pos.y, z=pos.z}
		repeat -- Check if it collides with a stopper
			collpos={x=collpos.x+direction.x, y=collpos.y+direction.y, z=collpos.z+direction.z}
			checknode=minetest.env:get_node(collpos)
			if mesecon:is_mvps_stopper(checknode.name) then 
				return
			end
		until checknode.name=="air"
		or checknode.name=="ignore" 
		or checknode.name=="default:water"
		or checknode.name=="default:water_flowing"
		minetest.env:remove_node(pos)
		nodeupdate(pos)
		minetest.env:add_entity(pos, "mesecons_movestones:movestone_entity")
	end
end)




-- STICKY_MOVESTONE

minetest.register_node("mesecons_movestones:sticky_movestone", {
	tile_images = {"jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_sticky_movestone.png", "jeija_sticky_movestone.png"},
	inventory_image = minetest.inventorycube("jeija_sticky_movestone.png", "jeija_movestone_side.png", "jeija_movestone_side.png"),
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	groups = {cracky=3},
    	description="Sticky Movestone",
})

minetest.register_craft({
	output = '"mesecons_movestones:sticky_movestone" 2',
	recipe = {
		{'"mesecons_materials:glue"', '"mesecons_movestones:movestone"', '"mesecons_materials:glue"'},
	}
})

minetest.register_entity("mesecons_movestones:sticky_movestone_entity", {
	physical = false,
	visual = "sprite",
	textures = {"jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_sticky_movestone.png", "jeija_sticky_movestone.png"},
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",

	on_punch = function(self, hitter)
		self.object:remove()
		hitter:get_inventory():add_item("main", 'mesecons_movestones:sticky_movestone')
	end,

	on_step = function(self, dtime)
		local pos = self.object:getpos()
		local colp = pos
		local direction=mesecon:get_movestone_direction(colp)
		local velocity={x=direction.x*3, y=direction.y*3, z=direction.z*3}

		if not direction then
		--or (minetest.env:get_node_or_nil(pos).name ~="air" 
		--and minetest.env:get_node_or_nil(pos).name ~= nil) then
			minetest.env:add_node(pos, {name="mesecons_movestones:sticky_movestone"})
			self.object:remove()
			return
		end 

		self.object:setvelocity(velocity)

		local np = {x=pos.x+direction.x, y=pos.y+direction.y, z=pos.z+direction.z}	
		local coln = minetest.env:get_node(np)
		if coln.name ~= "air" and coln.name ~="water" then
			local thisp= {x=pos.x, y=pos.y, z=pos.z}
			local thisnode=minetest.env:get_node(thisp)
			local nextnode={}
			minetest.env:dig_node(thisp)
			repeat
				thisp.x=thisp.x+direction.x
				thisp.y=thisp.y+direction.y
				thisp.z=thisp.z+direction.z
				nextnode=minetest.env:get_node(thisp)
				minetest.env:place_node(thisp, {name=thisnode.name})
				nodeupdate(thisp)
				thisnode=nextnode
			until thisnode.name=="air" or thisnode.name=="ignore" or thisnode.name=="default:water" or thisnode.name=="default:water_flowing"
		end

		--STICKY:
		local np1 = {x=pos.x-direction.x*0.5, y=pos.y-direction.y*0.5, z=pos.z-direction.z*0.5} -- 1 away
		local coln1 = minetest.env:get_node(np1)
		local np2 = {x=pos.x-direction.x*1.5, y=pos.y-direction.y*1.5, z=pos.z-direction.z*1.5} -- 2 away
		local coln2 = minetest.env:get_node(np2)

		if (coln1.name == "air" or coln1.name =="water") and (coln2.name~="air" and coln2.name ~= water) then
			thisp= np2
			local newpos={}
			local oldpos={}
			repeat
				newpos.x=thisp.x+direction.x
				newpos.y=thisp.y+direction.y
				newpos.z=thisp.z+direction.z
				minetest.env:place_node(newpos, {name=minetest.env:get_node(thisp).name})
				nodeupdate(newpos)
				oldpos={x=thisp.x, y=thisp.y, z=thisp.z}
				thisp.x=thisp.x-direction.x
				thisp.y=thisp.y-direction.y
				thisp.z=thisp.z-direction.z
			until minetest.env:get_node(thisp).name=="air" or minetest.env:get_node(thisp).name=="ignore" or minetest.env:get_node(thisp).name=="default:water" or minetest.env:get_node(thisp).name=="default:water_flowing"
			minetest.env:dig_node(oldpos)
		end
	end
})

mesecon:register_on_signal_on(function (pos, node)
	if node.name=="mesecons_movestones:sticky_movestone" then
		local direction=mesecon:get_movestone_direction({x=pos.x, y=pos.y, z=pos.z})
		if not direction then return end
		local checknode={}
		local collpos={x=pos.x, y=pos.y, z=pos.z}
		repeat -- Check if it collides with a stopper
			collpos={x=collpos.x+direction.x, y=collpos.y+direction.y, z=collpos.z+direction.z}
			checknode=minetest.env:get_node(collpos)
			if mesecon:is_mvps_stopper(checknode.name) then 
				return 
			end
		until checknode.name=="air"
		or checknode.name=="ignore" 
		or checknode.name=="default:water" 
		or checknode.name=="default:water_flowing" 
		repeat -- Check if it collides with a stopper (pull direction)
			collpos={x=collpos.x-direction.x, y=collpos.y-direction.y, z=collpos.z-direction.z}
			checknode=minetest.env:get_node(collpos)
			if mesecon:is_mvps_stopper(checknode.name) then
				return 
			end
		until checknode.name=="air"
		or checknode.name=="ignore" 
		or checknode.name=="default:water" 
		or checknode.name=="default:water_flowing" 

		minetest.env:remove_node(pos)
		nodeupdate(pos)
		minetest.env:add_entity(pos, "mesecons_movestones:sticky_movestone_entity")
	end
end)

mesecon:add_rules("movestone", {
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
{x=-1, y=0,  z=0}})