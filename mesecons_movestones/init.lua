-- MOVESTONE

function mesecon:get_movestone_direction(pos)
	getactivated=0
	local lpos
	local getactivated=0
	local rules=mesecon:get_rules("movestone")

	lpos={x=pos.x+1, y=pos.y, z=pos.z}
	for n=1, 3 do
		if mesecon:is_power_on(lpos, rules[n].x, rules[n].y, rules[n].z) then
			return {x=0, y=0, z=-1}
		end
	end

	lpos={x=pos.x-1, y=pos.y, z=pos.z}
	for n=4, 6 do
		if mesecon:is_power_on(lpos, rules[n].x, rules[n].y, rules[n].z) then
			return {x=0, y=0, z=1}
		end
	end

	lpos={x=pos.x, y=pos.y, z=pos.z+1}
	for n=7, 9 do
		if mesecon:is_power_on(lpos, rules[n].x, rules[n].y, rules[n].z) then
			return {x=-1, y=0, z=0}
		end
	end

	lpos={x=pos.x, y=pos.y, z=pos.z-1}
	for n=10, 12 do
		if mesecon:is_power_on(lpos, rules[n].x, rules[n].y, rules[n].z) then
			return {x=1, y=0, z=0}
		end
	end
end

minetest.register_node("mesecons_movestones:movestone", {
	tiles = {"jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_arrows.png", "jeija_movestone_arrows.png"},
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	groups = {cracky=3},
    	description="Movestone",
})
mesecon:register_effector("mesecons_movestones:movestone", "mesecons_movestones:movestone")

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
		local direction=mesecon:get_movestone_direction(pos)

		if not direction then
			minetest.env:add_node(pos, {name="mesecons_movestones:movestone"})
			self.object:remove()
			return
		end

		self.object:setvelocity({x=direction.x*3, y=direction.y*3, z=direction.z*3})

		mesecon:mvps_push(pos, direction)
	end
})

minetest.register_craft({
	output = '"mesecons_movestones:movestone" 2',
	recipe = {
		{'"default:stone"', '"default:stone"', '"default:stone"'},
		{'"group:mesecon_conductor_craftable"', '"group:mesecon_conductor_craftable"', '"group:mesecon_conductor_craftable"'},
		{'"default:stone"', '"default:stone"', '"default:stone"'},
	}
})

mesecon:register_on_signal_on(function (pos, node)
	if node.name=="mesecons_movestones:movestone" then
		local direction=mesecon:get_movestone_direction(pos)
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
		or not(minetest.registered_nodes[checknode.name].liquidtype == "none")
		minetest.env:remove_node(pos)
		nodeupdate(pos)
		minetest.env:add_entity(pos, "mesecons_movestones:movestone_entity")
	end
end)




-- STICKY_MOVESTONE

minetest.register_node("mesecons_movestones:sticky_movestone", {
	tiles = {"jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_movestone_side.png", "jeija_sticky_movestone.png", "jeija_sticky_movestone.png"},
	inventory_image = minetest.inventorycube("jeija_sticky_movestone.png", "jeija_movestone_side.png", "jeija_movestone_side.png"),
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	groups = {cracky=3},
    	description="Sticky Movestone",
})
mesecon:register_effector("mesecons_movestones:sticky_movestone", "mesecons_movestones:sticky_movestone")

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

		if not direction then
		--or (minetest.env:get_node_or_nil(pos).name ~="air" 
		--and minetest.env:get_node_or_nil(pos).name ~= nil) then
			minetest.env:add_node(pos, {name="mesecons_movestones:sticky_movestone"})
			self.object:remove()
			return
		end

		self.object:setvelocity({x=direction.x*3, y=direction.y*3, z=direction.z*3})

		mesecon:mvps_push(pos, direction)

		--STICKY
		mesecon:mvps_pull_all(pos, direction)
	end
})

mesecon:register_on_signal_on(function (pos, node)
	if node.name=="mesecons_movestones:sticky_movestone" then
		local direction=mesecon:get_movestone_direction(pos)
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
		or not(minetest.registered_nodes[checknode.name].liquidtype == "none")  
		repeat -- Check if it collides with a stopper (pull direction)
			collpos={x=collpos.x-direction.x, y=collpos.y-direction.y, z=collpos.z-direction.z}
			checknode=minetest.env:get_node(collpos)
			if mesecon:is_mvps_stopper(checknode.name) then
				return 
			end
		until checknode.name=="air"
		or checknode.name=="ignore" 
		or not(minetest.registered_nodes[checknode.name].liquidtype == "none")
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
