-- |\    /| ____ ____  ____ _____   ____         _____
-- | \  / | |    |     |    |      |    | |\   | |
-- |  \/  | |___ ____  |___ |      |    | | \  | |____
-- |      | |        | |    |      |    | |  \ |     |
-- |      | |___ ____| |___ |____  |____| |   \| ____|
-- by Jeija and Minerd247
--
--
--
-- This mod adds mesecons[=minecraft redstone] and different receptors/effectors to minetest.
--
-- See the documentation on the forum for additional information, especially about crafting
--
--Quick Developer documentation for the mesecon API
--=================================================
--
--RECEPTORS
--
--A receptor is a node that emits power, e.g. a solar panel, a switch or a power plant.
--Usually you create two blocks per receptor that have to be switched when switching the on/off state: 
--	# An off-state node (e.g. jeija:mesecon_switch_off"
--	# An on-state node (e.g. jeija:mesecon_switch_on"
--The on-state and off-state nodes should be registered in the mesecon api, 
--so that the Mesecon circuit can be recalculated. This can be done using
--
--mesecon:add_receptor_node(nodename) -- for on-state node
--mesecon:add_receptor_node_off(nodename) -- for off-state node
--example: mesecon:add_receptor_node("jeija:mesecon_switch_on")
--
--Turning receptors on and off
--Usually the receptor has to turn on and off. For this, you have to
--	# Remove the node and replace it with the node in the other state (e.g. replace on by off)
--	# Send the event to the mesecon circuit by using the api functions
--		mesecon:receptor_on (pos, rules) } These functions take the position of your receptor
--		mesecon:receptor_off(pos, rules) } as their parameter.
--
--You can specify the rules using the rules parameter. If you don't want special rules, just leave it out
--
--!! If a receptor node is removed, the circuit should be recalculated. This means you have to
--send an mesecon:receptor_off signal to the api when the function in minetest.register_on_dignode
--is called.
--
--EFFECTORS
--
--A receptor is a node that uses power and transfers the signal to a mechanical, optical whatever
--event. e.g. the meselamp, the movestone or the removestone.
--
--There are two callback functions for receptors.
--	# function mesecon:register_on_signal_on (action)
--	# function mesecon:register_on_signal_off(action)
--
--These functions will be called for each block next to a mesecon conductor.
--
--Example: The removestone
--The removestone only uses one callback: The mesecon:register_on_signal_on function
--
--mesecon:register_on_signal_on(function(pos, node) -- As the action prameter you have to use a function
--	if node.name=="jeija:removestone" then -- Check if it really is removestone. If you wouldn't use this, every node next to mesecons would be removed
--		minetest.env:remove_node(pos) -- The action: The removestone is removed
--	end -- end of if
--end) -- end of the function, )=end of the parameters of mesecon:register_on_signal_on

-- SETTINGS
ENABLE_TEMPEREST=0
ENABLE_PISTON_ANIMATION=0
BLINKY_PLANT_INTERVAL=3
OLD_PISTON_DIRECTION=0

-- PUBLIC VARIABLES
mesecon={} -- contains all functions and all global variables
mesecon.actions_on={} -- Saves registered function callbacks for mesecon on
mesecon.actions_off={} -- Saves registered function callbacks for mesecon off
mesecon.pwr_srcs={} -- this is public for now
mesecon.pwr_srcs_off={} -- this is public for now
mesecon.wireless_receivers={}
mesecon.mvps_stoppers={}


-- MESECONS

minetest.register_node("jeija:mesecon_off", {
	drawtype = "raillike",
	tile_images = {"jeija_mesecon_off.png", "jeija_mesecon_curved_off.png", "jeija_mesecon_t_junction_off.png", "jeija_mesecon_crossing_off.png"},
	inventory_image = "jeija_mesecon_off.png",
	paramtype = "light",
	is_ground_content = true,
	walkable = false,
	selection_box = {
		type = "fixed",
	},
	material = minetest.digprop_constanttime(0.1),
    	description="Mesecons",
})

minetest.register_node("jeija:mesecon_on", {
	drawtype = "raillike",
	tile_images = {"jeija_mesecon_on.png", "jeija_mesecon_curved_on.png", "jeija_mesecon_t_junction_on.png", "jeija_mesecon_crossing_on.png"},
	inventory_image = "jeija_mesecon_on.png",
	paramtype = "light",
	is_ground_content = true,
	walkable = false,
	selection_box = {
		type = "fixed",
	},
	material = minetest.digprop_constanttime(0.1),
	drop = '"jeija:mesecon_off" 1',
	light_source = LIGHT_MAX-11,
    	description="Mesecons",
})

minetest.register_craft({
	output = '"jeija:mesecon_off" 16',
	recipe = {
		{'"default:mese"'},
	}
})

function mesecon:is_power_on(p, x, y, z)
	local lpos = {}
	lpos.x=p.x+x
	lpos.y=p.y+y
	lpos.z=p.z+z
	local node = minetest.env:get_node(lpos)
	if node.name == "jeija:mesecon_on" or mesecon:is_receptor_node(node.name) then
		return 1
	end
	return 0
end

function mesecon:is_power_off(p, x, y, z)
	local lpos = {}
	lpos.x=p.x+x
	lpos.y=p.y+y
	lpos.z=p.z+z
	local node = minetest.env:get_node(lpos)
	if node.name == "jeija:mesecon_off" or mesecon:is_receptor_node_off(node.name) then
		return 1
	end
	return 0
end

function mesecon:turnon(p, x, y, z, firstcall, rules)
	if rules==nil then
		rules="default"
	end
	local lpos = {}
	lpos.x=p.x+x
	lpos.y=p.y+y
	lpos.z=p.z+z

	mesecon:activate(lpos)

	local node = minetest.env:get_node(lpos)
	if node.name == "jeija:mesecon_off" then
		--minetest.env:remove_node(lpos)
		minetest.env:add_node(lpos, {name="jeija:mesecon_on"})
		nodeupdate(lpos)
	end
	if node.name == "jeija:mesecon_off" or firstcall then
		local rules=mesecon:get_rules(rules)
		local i=1
		while rules[i]~=nil do 
			mesecon:turnon(lpos, rules[i].x, rules[i].y, rules[i].z, false, "default")
			i=i+1
		end
	end
end

function mesecon:turnoff(pos, x, y, z, firstcall, rules)
	if rules==nil then
		rules="default"
	end
	local lpos = {}
	lpos.x=pos.x+x
	lpos.y=pos.y+y
	lpos.z=pos.z+z

	local node = minetest.env:get_node(lpos)
	local connected = 0
	local checked = {}

	if not mesecon:check_if_turnon(lpos) then
		mesecon:deactivate(lpos)
	end

	if not(firstcall) and connected==0 then
		connected=mesecon:connected_to_pw_src(lpos, 0, 0, 0, checked)	
	end

	if connected == 0 and  node.name == "jeija:mesecon_on" then
		--minetest.env:remove_node(lpos)
		minetest.env:add_node(lpos, {name="jeija:mesecon_off"})
		nodeupdate(lpos)
	end


	if node.name == "jeija:mesecon_on" or firstcall then
		if connected == 0 then
			local rules=mesecon:get_rules(rules)
			local i=1
			while rules[i]~=nil do 
				mesecon:turnoff(lpos, rules[i].x, rules[i].y, rules[i].z, false, "default")
				i=i+1
			end
		end
	end
end


function mesecon:connected_to_pw_src(pos, x, y, z, checked, firstcall)
	local i=1
	local lpos = {}

	lpos.x=pos.x+x
	lpos.y=pos.y+y
	lpos.z=pos.z+z

	
	local node = minetest.env:get_node_or_nil(lpos)

	if not(node==nil) then
		repeat
			i=i+1
			if checked[i]==nil then checked[i]={} break end
			if  checked[i].x==lpos.x and checked[i].y==lpos.y and checked[i].z==lpos.z then 
				return 0
			end
		until false

		checked[i].x=lpos.x
		checked[i].y=lpos.y
		checked[i].z=lpos.z

		if mesecon:is_receptor_node(node.name) == true then -- receptor nodes (power sources) can be added using mesecon:add_receptor_node
			return 1
		end

		if node.name=="jeija:mesecon_on" or firstcall then -- add other conductors here
				local pw_source_found=0				
				local rules=mesecon:get_rules("default")
				local i=1
				while rules[i]~=nil do 
					pw_source_found=pw_source_found+mesecon:connected_to_pw_src(lpos, rules[i].x, rules[i].y, rules[i].z, checked, false)
					i=i+1
				end
			if pw_source_found > 0 then
				return 1
			end 
		end
	end
	return 0
end

function mesecon:check_if_turnon(pos)
	local getactivated=0
	local rules=mesecon:get_rules("default")
	local i=1
	while rules[i]~=nil do 
		getactivated=getactivated+mesecon:is_power_on(pos, rules[i].x, rules[i].y, rules[i].z)
		i=i+1
	end
	if getactivated > 0 then
		return true
	end
	return false
end

minetest.register_on_placenode(function(pos, newnode, placer)
	if mesecon:check_if_turnon(pos) then
		if newnode.name == "jeija:mesecon_off" then
			mesecon:turnon(pos, 0, 0, 0)		
		else
			mesecon:activate(pos)
		end
	end
end)

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:mesecon_on" then
			mesecon:turnoff(pos, 0, 0, 0, true)
		end	
	end
)

-- API API API API API API API API API API API API API API API API API API

function mesecon:add_receptor_node(nodename)
	local i=1
	repeat
		i=i+1
		if mesecon.pwr_srcs[i]==nil then break end
	until false
	mesecon.pwr_srcs[i]=nodename
end

function mesecon:add_receptor_node_off(nodename)
	local i=1
	repeat
		i=i+1
		if mesecon.pwr_srcs_off[i]==nil then break end
	until false
	mesecon.pwr_srcs_off[i]=nodename
end

function mesecon:receptor_on(pos, rules)
	mesecon:turnon(pos, 0, 0, 0, true, rules)
end

function mesecon:receptor_off(pos, rules)
	mesecon:turnoff(pos, 0, 0, 0, true, rules)
end

function mesecon:register_on_signal_on(action)
	local i	= 1	
	repeat
		i=i+1
		if mesecon.actions_on[i]==nil then break end
	until false
	mesecon.actions_on[i]=action
end

function mesecon:register_on_signal_off(action)
	local i	= 1	
	repeat
		i=i+1
		if mesecon.actions_off[i]==nil then break end
	until false
	mesecon.actions_off[i]=action
end



-- INTERNAL API


function mesecon:is_receptor_node(nodename)
	local i=1
	repeat
		i=i+1
		if mesecon.pwr_srcs[i]==nodename then return true end
	until mesecon.pwr_srcs[i]==nil
	return false
end

function mesecon:is_receptor_node_off(nodename)
	local i=1
	repeat
		i=i+1
		if mesecon.pwr_srcs_off[i]==nodename then return true end
	until mesecon.pwr_srcs_off[i]==nil
	return false
end


function mesecon:activate(pos)
	local node = minetest.env:get_node(pos)	
	local i = 1
	repeat
		i=i+1
		if mesecon.actions_on[i]~=nil then mesecon.actions_on[i](pos, node) 
		else break			
		end
	until false
end

function mesecon:deactivate(pos)
	local node = minetest.env:get_node(pos)	
	local i = 1
	local checked={}		
	repeat
		i=i+1
		if mesecon.actions_off[i]~=nil then mesecon.actions_off[i](pos, node) 
		else break			
		end
	until false
end


mesecon:register_on_signal_on(function(pos, node)
	if node.name=="jeija:meselamp_off" then
		--minetest.env:remove_node(pos)
		minetest.env:add_node(pos, {name="jeija:meselamp_on"})
		nodeupdate(pos)
	end
end)

mesecon:register_on_signal_off(function(pos, node)
	if node.name=="jeija:meselamp_on" then
		--minetest.env:remove_node(pos)
		minetest.env:add_node(pos, {name="jeija:meselamp_off"})
		nodeupdate(pos)
	end
end)

-- mesecon rules
function mesecon:get_rules(name)
	local rules={}
	rules[0]="dummy"
	if name=="default" then	
		table.insert(rules, {x=0,  y=0,  z=-1})
		table.insert(rules, {x=1,  y=0,  z=0})
		table.insert(rules, {x=-1, y=0,  z=0})
		table.insert(rules, {x=0,  y=0,  z=1})
		table.insert(rules, {x=1,  y=1,  z=0})
		table.insert(rules, {x=1,  y=-1, z=0})
		table.insert(rules, {x=-1, y=1,  z=0})
		table.insert(rules, {x=-1, y=-1, z=0})
		table.insert(rules, {x=0,  y=1,  z=1})
		table.insert(rules, {x=0,  y=-1, z=1})
		table.insert(rules, {x=0,  y=1,  z=-1})
		table.insert(rules, {x=0,  y=-1, z=-1})
	end
	if name=="movestone" then
		table.insert(rules, {x=0,  y=1,  z=-1})
		table.insert(rules, {x=0,  y=0,  z=-1})
		table.insert(rules, {x=0,  y=-1, z=-1})
		table.insert(rules, {x=0,  y=1,  z=1})
		table.insert(rules, {x=0,  y=-1, z=1})
		table.insert(rules, {x=0,  y=0,  z=1})
		table.insert(rules, {x=1,  y=0,  z=0})
		table.insert(rules, {x=1,  y=1,  z=0})
		table.insert(rules, {x=1,  y=-1, z=0})
		table.insert(rules, {x=-1, y=1,  z=0})
		table.insert(rules, {x=-1, y=-1, z=0})
		table.insert(rules, {x=-1, y=0,  z=0})
	end
	if name=="piston" then
		table.insert(rules, {x=0,  y=1,  z=0})
		table.insert(rules, {x=0,  y=-1,  z=0})
		table.insert(rules, {x=0,  y=1,  z=-1})
		table.insert(rules, {x=0,  y=0,  z=-1})
		table.insert(rules, {x=0,  y=-1, z=-1})
		table.insert(rules, {x=0,  y=1,  z=1})
		table.insert(rules, {x=0,  y=-1, z=1})
		table.insert(rules, {x=0,  y=0,  z=1})
		table.insert(rules, {x=1,  y=0,  z=0})
		table.insert(rules, {x=1,  y=1,  z=0})
		table.insert(rules, {x=1,  y=-1, z=0})
		table.insert(rules, {x=-1, y=1,  z=0})
		table.insert(rules, {x=-1, y=-1, z=0})
		table.insert(rules, {x=-1, y=0,  z=0})
	end
	if name=="pressureplate" then
		table.insert(rules, {x=0,  y=1,  z=-1})
		table.insert(rules, {x=0,  y=0,  z=-1})
		table.insert(rules, {x=0,  y=-1, z=-1})
		table.insert(rules, {x=0,  y=1,  z=1})
		table.insert(rules, {x=0,  y=-1, z=1})
		table.insert(rules, {x=0,  y=0,  z=1})
		table.insert(rules, {x=1,  y=0,  z=0})
		table.insert(rules, {x=1,  y=1,  z=0})
		table.insert(rules, {x=1,  y=-1, z=0})
		table.insert(rules, {x=-1, y=1,  z=0})
		table.insert(rules, {x=-1, y=-1, z=0})
		table.insert(rules, {x=-1, y=0,  z=0})
		table.insert(rules, {x=0, y=-1,  z=0})
		table.insert(rules, {x=0, y=1,  z=0})
	end
	if name=="mesecontorch_x-" then
		table.insert(rules, {x=1,  y=0,  z=0})
		table.insert(rules, {x=0,  y=0,  z=1})
		table.insert(rules, {x=0,  y=0,  z=-1})
	end
	if name=="mesecontorch_x+" then
		table.insert(rules, {x=-1,  y=0,  z=0})
		table.insert(rules, {x=0,  y=0,  z=1})
		table.insert(rules, {x=0,  y=0,  z=-1})
	end
	if name=="mesecontorch_z-" then
		table.insert(rules, {x=0,  y=0,  z=1})
		table.insert(rules, {x=1,  y=0,  z=0})
		table.insert(rules, {x=-1,  y=0,  z=0})
	end
	if name=="mesecontorch_z+" then
		table.insert(rules, {x=0,  y=0,  z=-1})
		table.insert(rules, {x=1,  y=0,  z=0})
		table.insert(rules, {x=-1,  y=0,  z=0})
	end
	if name=="mesecontorch_y-" then
	    table.insert(rules, {x=0,  y=1,  z=0})
		table.insert(rules, {x=1,  y=1,  z=0})
		table.insert(rules, {x=-1,  y=1,  z=0})
		table.insert(rules, {x=0,  y=1,  z=1})
		table.insert(rules, {x=0,  y=1,  z=-1})
	end
	if name=="mesecontorch_y+" then
	    table.insert(rules, {x=0,  y=-1,  z=0})
		table.insert(rules, {x=1,  y=-1,  z=0})
		table.insert(rules, {x=-1,  y=-1,  z=0})
		table.insert(rules, {x=0,  y=-1,  z=1})
		table.insert(rules, {x=0,  y=-1,  z=-1})
	end

	if name=="button_x+" or name=="button_x-"
	or name=="button_z-" or name=="button_z+" then --Is any button
table.insert(rules, {x=0,  y=0,  z=-1})
		table.insert(rules, {x=1,  y=0,  z=0})
		table.insert(rules, {x=-1, y=0,  z=0})
		table.insert(rules, {x=0,  y=0,  z=1})
		table.insert(rules, {x=1,  y=1,  z=0})
		table.insert(rules, {x=1,  y=-1, z=0})
		table.insert(rules, {x=-1, y=1,  z=0})
		table.insert(rules, {x=-1, y=-1, z=0})
		table.insert(rules, {x=0,  y=1,  z=1})
		table.insert(rules, {x=0,  y=-1, z=1})
		table.insert(rules, {x=0,  y=1,  z=-1})
		table.insert(rules, {x=0,  y=-1, z=-1})
		table.insert(rules, {x=0,  y=-1, z=0})
	end
	if name=="button_x+" then	
		table.insert(rules, {x=-2,  y=0,  z=0})	
	end
	if name=="button_x-" then	
		table.insert(rules, {x=2,  y=0,  z=0})	
	end
	if name=="button_z+" then	
		table.insert(rules, {x=0,  y=0,  z=-2})	
	end
	if name=="button_z-" then	
		table.insert(rules, {x=0,  y=0,  z=2})	
	end
	return rules
end






-- The POWER_PLANT

minetest.register_node("jeija:power_plant", {
	drawtype = "plantlike",
	visual_scale = 1,
	tile_images = {"jeija_power_plant.png"},
	inventory_image = "jeija_power_plant.png",
	paramtype = "light",
	walkable = false,
	material = minetest.digprop_leaveslike(0.2),
	light_source = LIGHT_MAX-9,
    	description="Power Plant",
})

minetest.register_craft({
	output = '"jeija:power_plant" 1',
	recipe = {
		{'"jeija:mesecon_off"'},
		{'"jeija:mesecon_off"'},
		{'"default:junglegrass"'},
	}
})

minetest.register_on_placenode(function(pos, newnode, placer)
	if newnode.name == "jeija:power_plant" then
		mesecon:receptor_on(pos)
	end
end)

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:power_plant" then
			mesecon:receptor_off(pos)
		end	
	end
)

mesecon:add_receptor_node("jeija:power_plant")


-- The BLINKY_PLANT

minetest.register_node("jeija:blinky_plant_off", {
	drawtype = "plantlike",
	visual_scale = 1,
	tile_images = {"jeija_blinky_plant_off.png"},
	inventory_image = "jeija_blinky_plant_off.png",
	paramtype = "light",
	walkable = false,
	material = minetest.digprop_leaveslike(0.2),
    	description="Blinky Plant",
})

minetest.register_node("jeija:blinky_plant_on", {
	drawtype = "plantlike",
	visual_scale = 1,
	tile_images = {"jeija_blinky_plant_on.png"},
	inventory_image = "jeija_blinky_plant_off.png",
	paramtype = "light",
	walkable = false,
	material = minetest.digprop_leaveslike(0.2),
	drop='"jeija:blinky_plant_off" 1',
	light_source = LIGHT_MAX-7,
    	description="Blinky Plant",
})

minetest.register_craft({
	output = '"jeija:blinky_plant_off" 1',
	recipe = {
	{'','"jeija:mesecon_off"',''},
	{'','"jeija:mesecon_off"',''},
	{'"default:junglegrass"','"default:junglegrass"','"default:junglegrass"'},
	}
})

minetest.register_abm(
	{nodenames = {"jeija:blinky_plant_off"},
	interval = BLINKY_PLANT_INTERVAL,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		--minetest.env:remove_node(pos)
		minetest.env:add_node(pos, {name="jeija:blinky_plant_on"})
		nodeupdate(pos)	
		mesecon:receptor_on(pos)
	end,
})

minetest.register_abm({
	nodenames = {"jeija:blinky_plant_on"},
	interval = BLINKY_PLANT_INTERVAL,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		--minetest.env:remove_node(pos)
		minetest.env:add_node(pos, {name="jeija:blinky_plant_off"})
		nodeupdate(pos)	
		mesecon:receptor_off(pos)
	end,
})

mesecon:add_receptor_node("jeija:blinky_plant_on")
mesecon:add_receptor_node_off("jeija:blinky_plant_off")

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:blinky_plant_on" then
			mesecon:receptor_off(pos)
		end
	end
)


-- Solar Panel

minetest.register_craftitem("jeija:silicon", {
	image = "jeija_silicon.png",
	on_place_on_ground = minetest.craftitem_place_item,
    	description="Silicon",
})


minetest.register_node("jeija:solar_panel", {
	drawtype = "raillike",
	tile_images = {"jeija_solar_panel.png"},
	inventory_image = "jeija_solar_panel.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	selection_box = {
		type = "fixed",
	},
	furnace_burntime = 5,
	material = minetest.digprop_dirtlike(0.1),
    	description="Solar Panel",
})

minetest.register_craft({
	output = '"jeija:silicon" 4',
	recipe = {
		{'"default:sand"', '"default:sand"'},
		{'"default:sand"', '"default:steel_ingot"'},
	}
})

minetest.register_craft({
	output = '"jeija:solar_panel" 1',
	recipe = {
		{'"jeija:silicon"', '"jeija:silicon"'},
		{'"jeija:silicon"', '"jeija:silicon"'},
	}
})

minetest.register_abm(
	{nodenames = {"jeija:solar_panel"},
	interval = 0.1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local light = minetest.env:get_node_light(pos, nil)
		if light == nil then light = 0 end
		if light >= 13 then
			mesecon:receptor_on(pos)
		else
			mesecon:receptor_off(pos)
		end
	end,
})


-- MESELAMPS
minetest.register_node("jeija:meselamp_on", {
	drawtype = "torchlike",
	tile_images = {"jeija_meselamp_on_floor_on.png", "jeija_meselamp_on_ceiling_on.png", "jeija_meselamp_on.png"},
	inventory_image = "jeija_meselamp_on_floor_on.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	legacy_wallmounted = true,
	paramtype2 = "wallmounted",
	light_source = LIGHT_MAX,
	selection_box = {
		type = "wallmounted",
		type = "fixed",
		fixed = {-0.38, -0.5, -0.1, 0.38, -0.2, 0.1},
	},
	material = minetest.digprop_constanttime(0.1),
	drop='"jeija:meselamp_off" 1',
    	description="Meselamp",
})

minetest.register_node("jeija:meselamp_off", {
	drawtype = "torchlike",
	tile_images = {"jeija_meselamp_on_floor_off.png", "jeija_meselamp_on_ceiling_off.png", "jeija_meselamp_off.png"},
	inventory_image = "jeija_meselamp_on_floor_off.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	wall_mounted = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.38, -0.5, -0.1, 0.38, -0.2, 0.1},
	},
	material = minetest.digprop_constanttime(0.1),
    	description="Meselamp",
})

minetest.register_craft({
	output = '"jeija:meselamp_off" 1',
	recipe = {
		{'', '"default:glass"', ''},
		{'"jeija:mesecon_off"', '"default:steel_ingot"', '"jeija:mesecon_off"'},
		{'', '"default:glass"', ''},
	}
})

--GLUE
minetest.register_craftitem("jeija:glue", {
	image = "jeija_glue.png",
	on_place_on_ground = minetest.craftitem_place_item,
    	description="Glue",
})

minetest.register_craft({
	output = '"jeija:glue" 2',
	recipe = {
		{'"default:junglegrass"', '"default:junglegrass"'},
		{'"default:junglegrass"', '"default:junglegrass"'},
	}
})


-- HYDRO_TURBINE

minetest.register_node("jeija:hydro_turbine_off", {
	tile_images = {"jeija_hydro_turbine_off.png", "jeija_hydro_turbine_off.png", "jeija_hydro_turbine_off.png", "jeija_hydro_turbine_off.png", "jeija_hydro_turbine_off.png", "jeija_hydro_turbine_off.png"},
	material = minetest.digprop_constanttime(0.5),
    	description="Water Turbine",
})

minetest.register_node("jeija:hydro_turbine_on", {
	tile_images = {"jeija_hydro_turbine_on.png", "jeija_hydro_turbine_on.png", "jeija_hydro_turbine_on.png", "jeija_hydro_turbine_on.png", "jeija_hydro_turbine_on.png", "jeija_hydro_turbine_on.png"},
	drop = '"jeija:hydro_turbine_off" 1',
	material = minetest.digprop_constanttime(0.5),
    	description="Water Turbine",
})


minetest.register_abm({
nodenames = {"jeija:hydro_turbine_off"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local waterpos={x=pos.x, y=pos.y+1, z=pos.z}
		if minetest.env:get_node(waterpos).name=="default:water_flowing" then
			--minetest.env:remove_node(pos)
			minetest.env:add_node(pos, {name="jeija:hydro_turbine_on"})
			nodeupdate(pos)
			mesecon:receptor_on(pos)
		end
	end,
})

minetest.register_abm({
nodenames = {"jeija:hydro_turbine_on"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local waterpos={x=pos.x, y=pos.y+1, z=pos.z}
		if minetest.env:get_node(waterpos).name~="default:water_flowing" then
			--minetest.env:remove_node(pos)
			minetest.env:add_node(pos, {name="jeija:hydro_turbine_off"})
			nodeupdate(pos)
			mesecon:receptor_off(pos)
		end
	end,
})

mesecon:add_receptor_node("jeija:hydro_turbine_on")
mesecon:add_receptor_node_off("jeija:hydro_turbine_off")

minetest.register_craft({
	output = '"jeija:hydro_turbine_off" 2',
	recipe = {
	{'','"default:stick"', ''},
	{'"default:stick"', '"default:steel_ingot"', '"default:stick"'},
	{'','"default:stick"', ''},
	}
})

--Launch TNT

mesecon:register_on_signal_on(function(pos, node)
	if node.name=="experimental:tnt" then
		minetest.env:remove_node(pos)
		minetest.env:add_entity(pos, "experimental:tnt")
		nodeupdate(pos)
	end
end)

-- REMOVE_STONE

minetest.register_node("jeija:removestone", {
	tile_images = {"jeija_removestone.png"},
	inventory_image = minetest.inventorycube("jeija_removestone_inv.png"),
	material = minetest.digprop_stonelike(1.0),
    	description="Removestone",
})

minetest.register_craft({
	output = '"jeija:removestone" 4',
	recipe = {
		{'', '"default:cobble"',''},
		{'"default:cobble"', '"jeija:mesecon_off"', '"default:cobble"'},
		{'', '"default:cobble"',''},
	}
})

mesecon:register_on_signal_on(function(pos, node)
	if node.name=="jeija:removestone" then
		minetest.env:remove_node(pos)
	end
end)


-- Include other files
dofile(minetest.get_modpath("jeija").."/movestone.lua")
dofile(minetest.get_modpath("jeija").."/button.lua")
dofile(minetest.get_modpath("jeija").."/torches.lua")
dofile(minetest.get_modpath("jeija").."/detector.lua")
dofile(minetest.get_modpath("jeija").."/pressureplates.lua")
dofile(minetest.get_modpath("jeija").."/wireless.lua")
dofile(minetest.get_modpath("jeija").."/alias.lua")
dofile(minetest.get_modpath("jeija").."/switch.lua")
dofile(minetest.get_modpath("jeija").."/pistons.lua")
--TEMPEREST's STUFF
if ENABLE_TEMPEREST==1 then
	dofile(minetest.get_modpath("jeija").."temperest.lua")
end

--INIT
mesecon:read_wlre_from_file()
--register stoppers for movestones/pistons
mesecon:register_mvps_stopper("default:chest")
mesecon:register_mvps_stopper("default:chest_locked")
mesecon:register_mvps_stopper("default:furnace")

print("[MESEcons] Loaded!")

--minetest.register_on_newplayer(function(player)
	--local i=1
	--while mesecon.wireless_receivers[i]~=nil do
	--	pos=mesecon.wireless_receivers[i].pos
	--	request=mesecon.wireless_receivers[i].requested_state
	--	inverting=mesecon.wireless_receivers[i].inverting
	--	if request==inverting then
	--		mesecon:receptor_off(pos)
	--	end
	--	if request~=inverting  then
	--		mesecon:receptor_on(pos)
	--	end
	--end
--end)
