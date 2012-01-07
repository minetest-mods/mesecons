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
	dug_item = 'node "jeija:mesecon_off" 1',
	light_source = LIGHT_MAX-11,
})

minetest.register_craft({
	output = 'node "jeija:mesecon_off" 16',
	recipe = {
		{'node "default:mese"'},
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
	print (dump(rules))
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
	if name=="mesecontorch_x+" then
		table.insert(rules, {x=1,  y=1,  z=0})
		table.insert(rules, {x=1,  y=0,  z=0})
		table.insert(rules, {x=1,  y=-1,  z=0})
	end
	if name=="mesecontorch_x-" then
		table.insert(rules, {x=-1,  y=1,  z=0})
		table.insert(rules, {x=-1,  y=0,  z=0})
		table.insert(rules, {x=-1,  y=-1,  z=0})
	end
	if name=="mesecontorch_z+" then
		table.insert(rules, {x=0,  y=1,  z=1})
		table.insert(rules, {x=0,  y=0,  z=1})
		table.insert(rules, {x=0,  y=-1,  z=1})
	end
	if name=="mesecontorch_z-" then
		table.insert(rules, {x=0,  y=1,  z=-1})
		table.insert(rules, {x=0,  y=0,  z=-1})
		table.insert(rules, {x=0,  y=-1,  z=-1})
	end
	if name=="mesecontorch_y+" then
		table.insert(rules, {x=-1,  y=1,  z=0})
		table.insert(rules, {x=-1,  y=1,  z=1})
		table.insert(rules, {x=-1,  y=1,  z=-1})

		table.insert(rules, {x=1,  y=1,  z=0})
		table.insert(rules, {x=1,  y=1,  z=1})
		table.insert(rules, {x=1,  y=1,  z=-1})

		table.insert(rules, {x=0,  y=1,  z=0})
		table.insert(rules, {x=0,  y=1,  z=1})
		table.insert(rules, {x=0,  y=1,  z=-1})
	end
	if name=="mesecontorch_y-" then
		table.insert(rules, {x=-1,  y=-1,  z=0})
		table.insert(rules, {x=-1,  y=-1,  z=1})
		table.insert(rules, {x=-1,  y=-1,  z=-1})

		table.insert(rules, {x=1,  y=-1,  z=0})
		table.insert(rules, {x=1,  y=-1,  z=1})
		table.insert(rules, {x=1,  y=-1,  z=-1})

		table.insert(rules, {x=0,  y=-1,  z=0})
		table.insert(rules, {x=0,  y=-1,  z=1})
		table.insert(rules, {x=0,  y=-1,  z=-1})
		print ("Y++++++++++")
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
})

minetest.register_craft({
	output = 'node "jeija:power_plant" 1',
	recipe = {
		{'node "jeija:mesecon_off"'},
		{'node "jeija:mesecon_off"'},
		{'node "default:junglegrass"'},
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
})

minetest.register_node("jeija:blinky_plant_on", {
	drawtype = "plantlike",
	visual_scale = 1,
	tile_images = {"jeija_blinky_plant_on.png"},
	inventory_image = "jeija_blinky_plant_off.png",
	paramtype = "light",
	walkable = false,
	material = minetest.digprop_leaveslike(0.2),
	dug_item='node "jeija:blinky_plant_off" 1',
	light_source = LIGHT_MAX-7,
})

minetest.register_craft({
	output = 'node "jeija:blinky_plant_off" 1',
	recipe = {
	{'','node "jeija:mesecon_off"',''},
	{'','node "jeija:mesecon_off"',''},
	{'node "default:junglegrass"','node "default:junglegrass"','node "default:junglegrass"'},
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
})

minetest.register_craft({
	output = 'craft "jeija:silicon" 4',
	recipe = {
		{'node "default:sand"', 'node "default:sand"'},
		{'node "default:sand"', 'craft "default:steel_ingot"'},
	}
})

minetest.register_craft({
	output = 'node "jeija:solar_panel" 1',
	recipe = {
		{'craft "jeija:silicon"', 'craft "jeija:silicon"'},
		{'craft "jeija:silicon"', 'craft "jeija:silicon"'},
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
	wall_mounted = false,
	light_source = LIGHT_MAX,
	selection_box = {
		type = "fixed",
		fixed = {-0.38, -0.5, -0.1, 0.38, -0.2, 0.1},
	},
	material = minetest.digprop_constanttime(0.1),
	dug_item='node "jeija:meselamp_off" 1',
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
})

minetest.register_craft({
	output = 'node "jeija:meselamp_off" 1',
	recipe = {
		{'', 'node "default:glass"', ''},
		{'node "jeija:mesecon_off"', 'craft "default:steel_ingot"', 'node "jeija:mesecon_off"'},
		{'', 'node "default:glass"', ''},
	}
})


--PISTONS
--registration normal one:
minetest.register_node("jeija:piston_normal", {
	tile_images = {"jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_side.png", "jeija_piston_side.png", "jeija_piston_side.png", "jeija_piston_side.png"},
	inventory_image = minetest.inventorycube("jeija_piston_tb.png", "jeija_piston_side.png", "jeija_piston_side.png"),
	material = minetest.digprop_stonelike(0.5),
})

minetest.register_craft({
	output = 'node "jeija:piston_normal" 2',
	recipe = {
		{'node "default:wood"', 'node "default:wood"', 'node "default:wood"'},
		{'node "default:cobble"', 'craft "default:steel_ingot"', 'node "default:cobble"'},
		{'node "default:cobble"', 'node "jeija:mesecon_off"', 'node "default:cobble"'},
	}
})

--registration sticky one:
minetest.register_node("jeija:piston_sticky", {
	tile_images = {"jeija_piston_tb.png", "jeija_piston_tb.png", "jeija_piston_sticky_side.png", "jeija_piston_sticky_side.png", "jeija_piston_sticky_side.png", "jeija_piston_sticky_side.png"},
	inventory_image = minetest.inventorycube("jeija_piston_tb.png", "jeija_piston_sticky_side.png", "jeija_piston_sticky_side.png"),
	material = minetest.digprop_stonelike(0.5),
})

minetest.register_craft({
	output = 'node "jeija:piston_sticky" 1',
	recipe = {
		{'craft "jeija:glue"'},
		{'node "jeija:piston_normal"'},
	}
})

-- get push direction normal
function mesecon:piston_get_direction(pos)
	getactivated=0
	local direction = {x=0, y=0, z=0}
	local lpos={x=pos.x, y=pos.y, z=pos.z}
	local getactivated=0
	local rules=mesecon:get_rules("piston")

	getactivated=getactivated+mesecon:is_power_on(pos, rules[1].x, rules[1].y, rules[1].z)
	if getactivated>0 then direction.y=-1 return direction end
	getactivated=getactivated+mesecon:is_power_on(pos, rules[2].x, rules[2].y, rules[2].z)
	if getactivated>0 then direction.y=1 return direction end

	for k=3, 5 do
		getactivated=getactivated+mesecon:is_power_on(pos, rules[k].x, rules[k].y, rules[k].z)
	end
	if getactivated>0 then direction.z=1 return direction end

	for n=6, 8 do
		getactivated=getactivated+mesecon:is_power_on(pos, rules[n].x, rules[n].y, rules[n].z)
	end

	if getactivated>0 then direction.z=-1 return direction end

	for j=9, 11 do
		getactivated=getactivated+mesecon:is_power_on(pos, rules[j].x, rules[j].y, rules[j].z)
	end

	if getactivated>0 then direction.x=-1 return direction end

	for l=12, 14 do
		getactivated=getactivated+mesecon:is_power_on(pos, rules[l].x, rules[l].y, rules[l].z)
	end
	if getactivated>0 then direction.x=1 return direction end
	return direction
end

-- get pull/push direction sticky
function mesecon:sticky_piston_get_direction(pos)
	getactivated=0
	local direction = {x=0, y=0, z=0}
	local lpos={x=pos.x, y=pos.y, z=pos.z}
	local getactivated=0
	local rules=mesecon:get_rules("piston")

	getactivated=getactivated+mesecon:is_power_off(pos, rules[1].x, rules[1].y, rules[1].z)
	if getactivated>0 then direction.y=-1 return direction end
	getactivated=getactivated+mesecon:is_power_off(pos, rules[2].x, rules[2].y, rules[2].z)
	if getactivated>0 then direction.y=1 return direction end

	for k=3, 5 do
		getactivated=getactivated+mesecon:is_power_off(pos, rules[k].x, rules[k].y, rules[k].z)
	end
	if getactivated>0 then direction.z=1 return direction end

	for n=6, 8 do
		getactivated=getactivated+mesecon:is_power_off(pos, rules[n].x, rules[n].y, rules[n].z)
	end

	if getactivated>0 then direction.z=-1 return direction end

	for j=9, 11 do
		getactivated=getactivated+mesecon:is_power_off(pos, rules[j].x, rules[j].y, rules[j].z)
	end

	if getactivated>0 then direction.x=-1 return direction end

	for l=12, 14 do
		getactivated=getactivated+mesecon:is_power_off(pos, rules[l].x, rules[l].y, rules[l].z)
	end
	if getactivated>0 then direction.x=1 return direction end
	return direction
end

-- Push action
mesecon:register_on_signal_on(function (pos, node)
	if (node.name=="jeija:piston_normal" or node.name=="jeija:piston_sticky") then
		local direction=mesecon:piston_get_direction(pos)

		local checknode={}
		local checkpos={x=pos.x, y=pos.y, z=pos.z}
		repeat -- Check if it collides with a stopper
			checkpos={x=checkpos.x+direction.x, y=checkpos.y+direction.y, z=checkpos.z+direction.z}
			checknode=minetest.env:get_node(checkpos)
			if mesecon:is_mvps_stopper(checknode.name) then 
				return 
			end
		until checknode.name=="air"
		or checknode.name=="ignore" 
		or checknode.name=="default:water" 
		or checknode.name=="default:water_flowing" 

		local obj={}
		if node.name=="jeija:piston_normal" then
			obj=minetest.env:add_entity(pos, "jeija:piston_pusher_normal")
		elseif node.name=="jeija:piston_sticky" then
			obj=minetest.env:add_entity(pos, "jeija:piston_pusher_sticky")
		end
		
		if ENABLE_PISTON_ANIMATION==1 then		
			obj:setvelocity({x=direction.x*4, y=direction.y*4, z=direction.z*4})
		else
			obj:moveto({x=pos.x+direction.x, y=pos.y+direction.y, z=pos.z+direction.z}, false)
		end
		
		local np = {x=pos.x+direction.x, y=pos.y+direction.y, z=pos.z+direction.z}	
		local coln = minetest.env:get_node(np)
		
		or checknode.name=="ignore" 
		or checknode.name=="default:water" 
		or checknode.name=="default:water_flowing" 

		if coln.name ~= "air" and coln.name ~="water" then
			local thisp= {x=np.x, y=np.y, z=np.z}
			local thisnode=minetest.env:get_node(thisp)
			local nextnode={}
			minetest.env:remove_node(thisp)
			repeat
				thisp.x=thisp.x+direction.x
				thisp.y=thisp.y+direction.y
				thisp.z=thisp.z+direction.z
				nextnode=minetest.env:get_node(thisp)
				minetest.env:add_node(thisp, {name=thisnode.name})
				nodeupdate(thisp)
				thisnode=nextnode
			until thisnode.name=="air" 
			or thisnode.name=="ignore" 
			or thisnode.name=="default:water" 
			or thisnode.name=="default:water_flowing" 
		end
	end
end)

--Pull action (sticky only)
mesecon:register_on_signal_off(function (pos, node)
	if node.name=="jeija:piston_sticky" or node.name=="jeija:piston_normal" then
		local objs = minetest.env:get_objects_inside_radius(pos, 2)
		for k, obj in pairs(objs) do
			obj:remove()
		end

		if node.name=="jeija:piston_sticky" then
			local direction=mesecon:sticky_piston_get_direction(pos)
			local np = {x=pos.x+direction.x, y=pos.y+direction.y, z=pos.z+direction.z}	
			local coln = minetest.env:get_node(np)
			if coln.name == "air" or coln.name =="water" then
				local thisp= {x=np.x+direction.x, y=np.y+direction.y, z=np.z+direction.z}
				local thisnode=minetest.env:get_node(thisp)
				if thisnode.name~="air" and thisnode.name~="water" and not mesecon:is_mvps_stopper(thisnode.name) then
					local newpos={}
					local oldpos={}
					minetest.env:add_node(np, {name=thisnode.name})
					minetest.env:remove_node(thisp)
				end		
			end
		end
	end
end)

--Piston Animation
local PISTON_PUSHER_NORMAL={
	physical = false,
	visual = "sprite",
	textures = {"default_wood.png", "default_wood.png", "jeija_piston_pusher_normal.png", "jeija_piston_pusher_normal.png", "jeija_piston_pusher_normal.png", "jeija_piston_pusher_normal.png"},
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	timer=0,
}

function PISTON_PUSHER_NORMAL:on_step(dtime)
	self.timer=self.timer+dtime
	if self.timer>=0.24 then
		self.object:setvelocity({x=0, y=0, z=0})
	end
end

local PISTON_PUSHER_STICKY={
	physical = false,
	visual = "sprite",
	textures = {"default_wood.png", "default_wood.png", "jeija_piston_pusher_sticky.png", "jeija_piston_pusher_sticky.png", "jeija_piston_pusher_sticky.png", "jeija_piston_pusher_sticky.png"},
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	timer=0,
}

function PISTON_PUSHER_STICKY:on_step(dtime)
	self.timer=self.timer+dtime
	if self.timer>=0.24 then
		self.object:setvelocity({x=0, y=0, z=0})
	end
end

minetest.register_entity("jeija:piston_pusher_normal", PISTON_PUSHER_NORMAL)
minetest.register_entity("jeija:piston_pusher_sticky", PISTON_PUSHER_STICKY)

minetest.register_on_dignode(function(pos, node)
	if node.name=="jeija:piston_normal" or node.name=="jeija:piston_sticky" then
		local objs = minetest.env:get_objects_inside_radius(pos, 2)
		for k, obj in pairs(objs) do
			obj:remove()
		end
	end
end)

--GLUE
minetest.register_craftitem("jeija:glue", {
	image = "jeija_glue.png",
	on_place_on_ground = minetest.craftitem_place_item,
})

minetest.register_craft({
	output = 'craft "jeija:glue" 2',
	recipe = {
		{'node "default:junglegrass"', 'node "default:junglegrass"'},
		{'node "default:junglegrass"', 'node "default:junglegrass"'},
	}
})


-- HYDRO_TURBINE

minetest.register_node("jeija:hydro_turbine_off", {
	tile_images = {"jeija_hydro_turbine_off.png", "jeija_hydro_turbine_off.png", "jeija_hydro_turbine_off.png", "jeija_hydro_turbine_off.png", "jeija_hydro_turbine_off.png", "jeija_hydro_turbine_off.png"},
	inventory_image = minetest.inventorycube("jeija_hydro_turbine_off.png", "jeija_hydro_turbine_off.png", "jeija_hydro_turbine_off.png"),
	material = minetest.digprop_constanttime(0.5),
})

minetest.register_node("jeija:hydro_turbine_on", {
	tile_images = {"jeija_hydro_turbine_on.png", "jeija_hydro_turbine_on.png", "jeija_hydro_turbine_on.png", "jeija_hydro_turbine_on.png", "jeija_hydro_turbine_on.png", "jeija_hydro_turbine_on.png"},
	inventory_image = minetest.inventorycube("jeija_hydro_turbine_on.png", "jeija_hydro_turbine_on.png", "jeija_hydro_turbine_on.png"),
	dug_item = 'node "jeija:hydro_turbine_off" 1',
	material = minetest.digprop_constanttime(0.5),
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
	output = 'node "jeija:hydro_turbine_off" 2',
	recipe = {
	{'','craft "default:stick"', ''},
	{'craft "default:stick"', 'craft "default:steel_ingot"', 'craft "default:stick"'},
	{'','craft "default:stick"', ''},
	}
})


-- MESECON_SWITCH

minetest.register_node("jeija:mesecon_switch_off", {
	tile_images = {"jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_off.png"},
	inventory_image = minetest.inventorycube("jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_off.png"),
	paramtype = "facedir_simple",
	material = minetest.digprop_constanttime(0.5),
})

minetest.register_node("jeija:mesecon_switch_on", {
	tile_images = {"jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_on.png"},
	inventory_image = minetest.inventorycube("jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_on.png"),
	paramtype = "facedir_simple",
	material = minetest.digprop_constanttime(0.5),
	dug_item='node "jeija:mesecon_switch_off" 1',
})

mesecon:add_receptor_node("jeija:mesecon_switch_on")
mesecon:add_receptor_node_off("jeija:mesecon_switch_off")

minetest.register_on_punchnode(function(pos, node, puncher)
	if node.name == "jeija:mesecon_switch_on" then
		--local param2=minetest.env:get_node(pos).param2
		--print (param2)
		--minetest.env:remove_node(pos)
		minetest.env:add_node(pos, {name="jeija:mesecon_switch_off"})
		nodeupdate(pos)
		mesecon:receptor_off(pos)
	end
	if node.name == "jeija:mesecon_switch_off" then
		--local param2=minetest.env:get_node(pos).param2
		--print (param2)
		--minetest.env:remove_node(pos)
		minetest.env:add_node(pos, {name="jeija:mesecon_switch_on"})
		nodeupdate(pos)
		mesecon:receptor_on(pos)
	end
end)

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:mesecon_switch_on" then
			mesecon:receptor_off(pos)
		end
	end
)

minetest.register_craft({
	output = 'node "jeija:mesecon_switch_off" 2',
	recipe = {
		{'craft "default:steel_ingot"', 'node "default:cobble"', 'craft "default:steel_ingot"'},
		{'node "jeija:mesecon_off"','', 'node "jeija:mesecon_off"'},
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
})

minetest.register_craft({
	output = 'node "jeija:removestone" 4',
	recipe = {
		{'', 'node "default:cobble"',''},
		{'node "default:cobble"', 'node "jeija:mesecon_off"', 'node "default:cobble"'},
		{'', 'node "default:cobble"',''},
	}
})

mesecon:register_on_signal_on(function(pos, node)
	if node.name=="jeija:removestone" then
		minetest.env:remove_node(pos)
	end
end)

-- IC
minetest.register_craftitem("jeija:ic", {
	image = "jeija_ic.png",
	on_place_on_ground = minetest.craftitem_place_item,
})

minetest.register_craft({
	output = 'craft "jeija:ic" 2',
	recipe = {
		{'craft "jeija:silicon"', 'craft "jeija:silicon"', 'node "jeija:mesecon_off"'},
		{'craft "jeija:silicon"', 'craft "jeija:silicon"', 'node "jeija:mesecon_off"'},
		{'node "jeija:mesecon_off"', 'node "jeija:mesecon_off"', ''},
	}
})

--COMMON WIRELESS FUNCTIONS

function mesecon:read_wlre_from_file()
	print "[MESEcons] Reading Mesecon Data..."
	mesecon_file=io.open(minetest.get_modpath("jeija").."/mesecon_data", "r")
	if mesecon_file==nil then return end
	local row=mesecon_file:read()
	local i=1
	while row~=nil do
		mesecon.wireless_receivers[i]={}
		mesecon.wireless_receivers[i].pos={}
		mesecon.wireless_receivers[i].pos.x=tonumber(mesecon_file:read())
		mesecon.wireless_receivers[i].pos.y=tonumber(mesecon_file:read())
		mesecon.wireless_receivers[i].pos.z=tonumber(mesecon_file:read())
		mesecon.wireless_receivers[i].channel=mesecon_file:read()
		mesecon.wireless_receivers[i].requested_state=tonumber(mesecon_file:read())
		mesecon.wireless_receivers[i].inverting=tonumber(mesecon_file:read())
		i=i+1
		row=mesecon_file:read()
	end
	mesecon_file:close()	
	print "[MESEcons] Finished Reading Mesecon Data..."
end


function mesecon:register_wireless_receiver(pos, inverting)
	local i	= 1	
	repeat
		if mesecon.wireless_receivers[i]==nil then break end
		i=i+1
	until false


	local node_under_pos={}
	node_under_pos.x=pos.x
	node_under_pos.y=pos.y
	node_under_pos.z=pos.z

	node_under_pos.y=node_under_pos.y-1
	local node_under=minetest.env:get_node(node_under_pos)
	mesecon.wireless_receivers[i]={}
	mesecon.wireless_receivers[i].pos={}
	mesecon.wireless_receivers[i].pos.x=pos.x
	mesecon.wireless_receivers[i].pos.y=pos.y
	mesecon.wireless_receivers[i].pos.z=pos.z
	mesecon.wireless_receivers[i].channel=node_under.name
	mesecon.wireless_receivers[i].requested_state=0
	mesecon.wireless_receivers[i].inverting=inverting
end

function mesecon:remove_wireless_receiver(pos)
	local i = 1
	while mesecon.wireless_receivers[i]~=nil do
		if mesecon.wireless_receivers[i].pos.x==pos.x and
		   mesecon.wireless_receivers[i].pos.y==pos.y and
		   mesecon.wireless_receivers[i].pos.z==pos.z then
			mesecon.wireless_receivers[i]=nil
			break
		end
		i=i+1
	end
end

function mesecon:set_wlre_channel(pos, channel)
	--local i = 1
	--while mesecon.wireless_receivers[i]~=nil do
	--	if tonumber(mesecon.wireless_receivers[i].pos.x)==tonumber(pos.x) and
	--	   tonumber(mesecon.wireless_receivers[i].pos.y)==tonumber(pos.y) and
	--	   tonumber(mesecon.wireless_receivers[i].pos.z)==tonumber(pos.z) then
	--		mesecon.wireless_receivers[i].channel=channel
	--		break
	--	end
	--	i=i+1
	--end
	local wlre=mesecon:get_wlre(pos)
	if wlre~=nil then 
		wlre.channel=channel
	end
end

function mesecon:get_wlre(pos)
	local i=1
	while mesecon.wireless_receivers[i]~=nil do
		if mesecon.wireless_receivers[i].pos.x==pos.x and
		   mesecon.wireless_receivers[i].pos.y==pos.y and
		   mesecon.wireless_receivers[i].pos.z==pos.z then
			return mesecon.wireless_receivers[i]
		end
		i=i+1
	end
end

minetest.register_on_placenode(function(pos, newnode, placer)
	pos.y=pos.y+1
	if minetest.env:get_node(pos).name == "jeija:wireless_receiver_off" or
	   minetest.env:get_node(pos).name == "jeija:wireless_receiver_on"  or
	   minetest.env:get_node(pos).name == "jeija:wireless_inverter_off" or
	   minetest.env:get_node(pos).name == "jeija:wireless_inverter_on" then
		mesecon:set_wlre_channel(pos, newnode.name)
	end
end)

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		local channel
		pos.y=pos.y+1
		if minetest.env:get_node(pos).name == "jeija:wireless_receiver_on" or
		   minetest.env:get_node(pos).name == "jeija:wireless_receiver_off" or
		   minetest.env:get_node(pos).name == "jeija:wireless_inverter_on" or
		   minetest.env:get_node(pos).name == "jeija:wireless_inverter_off" then
			mesecon:set_wlre_channel(pos, "air")
		end	
	end
)

minetest.register_abm(
	{nodenames = {"jeija:wireless_receiver_on", "jeija:wireless_receiver_off",
		      "jeija:wireless_inverter_on", "jeija:wireless_inverter_off"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local wlre=mesecon:get_wlre(pos)
		if (wlre==nil) then return end
		
		if node.name=="jeija:wireless_receiver_on" and wlre.requested_state==0  then
			minetest.env:add_node(pos, {name="jeija:wireless_receiver_off"})
			mesecon:receptor_off(pos)
		end
		if node.name=="jeija:wireless_receiver_off" and wlre.requested_state==1  then
			minetest.env:add_node(pos, {name="jeija:wireless_receiver_on"})
			mesecon:receptor_on(pos)
		end
		if node.name=="jeija:wireless_inverter_off" and wlre.requested_state==0 and wlre.inverting==1 then
			minetest.env:add_node(pos, {name="jeija:wireless_inverter_on"})
			mesecon:receptor_on(pos)
		end
		if node.name=="jeija:wireless_inverter_on" and wlre.requested_state==1 and wlre.inverting==1 then
			minetest.env:add_node(pos, {name="jeija:wireless_inverter_off"})
			mesecon:receptor_off(pos)
		end
	end,
})

--WIRELESS RECEIVER

minetest.register_node("jeija:wireless_receiver_off", {
	tile_images = {"jeija_wireless_receiver_tb_off.png", "jeija_wireless_receiver_tb_off.png", "jeija_wireless_receiver_off.png", "jeija_wireless_receiver_off.png", "jeija_wireless_receiver_off.png", "jeija_wireless_receiver_off.png"},
	inventory_image = minetest.inventorycube("jeija_wireless_receiver_off.png"),
	material = minetest.digprop_constanttime(0.8),
})

minetest.register_node("jeija:wireless_receiver_on", {
	tile_images = {"jeija_wireless_receiver_tb_on.png", "jeija_wireless_receiver_tb_on.png", "jeija_wireless_receiver_on.png", "jeija_wireless_receiver_on.png", "jeija_wireless_receiver_on.png", "jeija_wireless_receiver_on.png"},
	inventory_image = minetest.inventorycube("jeija_wireless_receiver_on.png"),
	material = minetest.digprop_constanttime(0.8),
	dug_item = 'node "jeija:wireless_receiver_off" 1'
})

minetest.register_craft({
	output = 'node "jeija:wireless_receiver_off" 2',
	recipe = {
		{'', 'node "jeija:mesecon_off"', ''},
		{'', 'node "jeija:mesecon_off"', ''},
		{'', 'craft "jeija:ic"', ''},
	}
})

minetest.register_on_placenode(function(pos, newnode, placer)
	if newnode.name == "jeija:wireless_receiver_off" then
		mesecon:register_wireless_receiver(pos, 0)
	end
end)

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:wireless_receiver_on" then
			mesecon:remove_wireless_receiver(pos)
			mesecon:receptor_off(pos)
		end	
		if oldnode.name == "jeija:wireless_receiver_off" then
			mesecon:remove_wireless_receiver(pos)		
		end
	end
)

minetest.register_abm( -- SAVE WIRELESS RECEIVERS TO FILE
	{nodenames = {"jeija:wireless_receiver_off", "jeija:wireless_receiver_on", "jeija:wireless_inverter_on", "jeija:wireless_inverter_off"},
	interval = 10,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local mesecon_file = io.open(minetest.get_modpath("jeija").."/mesecon_data", "w")
		local i=1
		while mesecon.wireless_receivers[i]~=nil do
			mesecon_file:write("NEXT\n")
			mesecon_file:write(mesecon.wireless_receivers[i].pos.x.."\n")
			mesecon_file:write(mesecon.wireless_receivers[i].pos.y.."\n")
			mesecon_file:write(mesecon.wireless_receivers[i].pos.z.."\n")
			mesecon_file:write(mesecon.wireless_receivers[i].channel.."\n")
			mesecon_file:write(mesecon.wireless_receivers[i].requested_state.."\n")
			mesecon_file:write(mesecon.wireless_receivers[i].inverting.."\n")
			i=i+1
		end
		mesecon_file:close()
	end, 
})

mesecon:add_receptor_node("jeija:wireless_receiver_on")
mesecon:add_receptor_node_off("jeija:wireless_receiver_off")

-- WIRELESS INVERTER OFF/ON BELONGS TO THE OUTPUT STATE (ON=INPUT OFF)

minetest.register_node("jeija:wireless_inverter_off", {
	tile_images = {"jeija_wireless_inverter_tb.png", "jeija_wireless_inverter_tb.png", "jeija_wireless_inverter_off.png", "jeija_wireless_inverter_off.png", "jeija_wireless_inverter_off.png", "jeija_wireless_inverter_off.png"},
	inventory_image = minetest.inventorycube("jeija_wireless_inverter_off.png"),
	material = minetest.digprop_constanttime(0.8),
	dug_item = 'node "jeija:wireless_inverter_on" 1'
})

minetest.register_node("jeija:wireless_inverter_on", {
	tile_images = {"jeija_wireless_inverter_tb.png", "jeija_wireless_inverter_tb.png", "jeija_wireless_inverter_on.png", "jeija_wireless_inverter_on.png", "jeija_wireless_inverter_on.png", "jeija_wireless_inverter_on.png"},
	inventory_image = minetest.inventorycube("jeija_wireless_inverter_on.png"),
	material = minetest.digprop_constanttime(0.8),
})

minetest.register_craft({
	output = 'node "jeija:wireless_inverter_off" 2',
	recipe = {
		{'', 'craft "default:steel_ingot"', ''},
		{'craft "jeija:ic"', 'node "jeija:mesecon_off"', 'craft "jeija:ic"'},
		{'', 'node "jeija:mesecon_off"', ''},
	}
})

minetest.register_on_placenode(function(pos, newnode, placer)
	if newnode.name == "jeija:wireless_inverter_on" then
		mesecon:register_wireless_receiver(pos, 1)
		mesecon:receptor_on(pos)
	end
end)

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:wireless_inverter_on" then
			mesecon:remove_wireless_receiver(pos)
			mesecon:receptor_off(pos)
		end	
		if oldnode.name == "jeija:wireless_inverter_off" then
			mesecon:remove_wireless_receiver(pos)		
		end
	end
)

mesecon:add_receptor_node("jeija:wireless_inverter_on")
mesecon:add_receptor_node_off("jeija:wireless_inverter_off")

-- WIRELESS TRANSMITTER

function mesecon:wireless_transmit(channel, senderstate)
	local i = 1
	while mesecon.wireless_receivers[i]~=nil do
		if mesecon.wireless_receivers[i].channel==channel then
			if senderstate==1 then
				mesecon.wireless_receivers[i].requested_state=1
			elseif senderstate==0 then
				mesecon.wireless_receivers[i].requested_state=0
			end
		end
		i=i+1
	end
end

minetest.register_node("jeija:wireless_transmitter_on", {
	tile_images = {"jeija_wireless_transmitter_tb.png", "jeija_wireless_transmitter_tb.png", "jeija_wireless_transmitter_on.png", "jeija_wireless_transmitter_on.png", "jeija_wireless_transmitter_on.png", "jeija_wireless_transmitter_on.png"},
	inventory_image = minetest.inventorycube("jeija_wireless_transmitter_on.png"),
	material = minetest.digprop_constanttime(0.8),
	dug_item = 'node "jeija:wireless_transmitter_off" 1',
})

minetest.register_node("jeija:wireless_transmitter_off", {
	tile_images = {"jeija_wireless_transmitter_tb.png", "jeija_wireless_transmitter_tb.png", "jeija_wireless_transmitter_off.png", "jeija_wireless_transmitter_off.png", "jeija_wireless_transmitter_off.png", "jeija_wireless_transmitter_off.png"},
	inventory_image = minetest.inventorycube("jeija_wireless_transmitter_off.png"),
	material = minetest.digprop_constanttime(0.8),
})

minetest.register_craft({
	output = 'node "jeija:wireless_transmitter_off" 2',
	recipe = {
		{'craft "default:steel_ingot"', 'node "jeija:mesecon_off"', 'craft "default:steel_ingot"'},
		{'', 'node "jeija:mesecon_off"', ''},
		{'', 'craft "jeija:ic"', ''},
	}
})

mesecon:register_on_signal_on(function(pos, node)
	if node.name=="jeija:wireless_transmitter_off" then
		minetest.env:add_node(pos, {name="jeija:wireless_transmitter_on"})
		local node_under_pos=pos
		node_under_pos.y=node_under_pos.y-1
		local node_under=minetest.env:get_node(node_under_pos)
		mesecon:wireless_transmit(node_under.name, 1)
	end
end)

mesecon:register_on_signal_off(function(pos, node)
	if node.name=="jeija:wireless_transmitter_on" then
		minetest.env:add_node(pos, {name="jeija:wireless_transmitter_off"})
		local node_under_pos=pos
		node_under_pos.y=node_under_pos.y-1
		local node_under=minetest.env:get_node(node_under_pos)
		mesecon:wireless_transmit(node_under.name, 0)
	end
end)

-- PRESSURE PLATE WOOD

minetest.register_node("jeija:pressure_plate_wood_off", {
	drawtype = "raillike",
	tile_images = {"jeija_pressure_plate_wood_off.png"},
	inventory_image = "jeija_pressure_plate_wood_off.png",
	paramtype = "light",
	is_ground_content = true,
	walkable = false,
	selection_box = {
		type = "fixed",
	},
	material = minetest.digprop_constanttime(0.3),
})

minetest.register_node("jeija:pressure_plate_wood_on", {
	drawtype = "raillike",
	tile_images = {"jeija_pressure_plate_wood_on.png"},
	inventory_image = "jeija_pressure_plate_wood_on.png",
	paramtype = "light",
	is_ground_content = true,
	walkable = false,
	selection_box = {
		type = "fixed",
	},
	material = minetest.digprop_constanttime(0.3),
	dug_item='node "jeija:pressure_plate_wood_off" 1'
})

minetest.register_craft({
	output = 'node "jeija:pressure_plate_wood_off" 1',
	recipe = {
		{'node "default:wood"', 'node "default:wood"'},
	}
})

minetest.register_abm(
	{nodenames = {"jeija:pressure_plate_wood_off"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		for k, obj in pairs(objs) do
			local objpos=obj:getpos()
			if objpos.y>pos.y-1 and objpos.y<pos.y then
				minetest.env:add_node(pos, {name="jeija:pressure_plate_wood_on"})
				mesecon:receptor_on(pos, "pressureplate")
			end
		end	
	end,
})

minetest.register_abm(
	{nodenames = {"jeija:pressure_plate_wood_on"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		if objs[1]==nil then
			minetest.env:add_node(pos, {name="jeija:pressure_plate_wood_off"})
			mesecon:receptor_off(pos, "pressureplate")
		end
	end,
})

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:pressure_plate_wood_on" then
			mesecon:receptor_off(pos, "pressureplate")
		end	
	end
)

mesecon:add_receptor_node("jeija:pressure_plate_wood_on")
mesecon:add_receptor_node_off("jeija:pressure_plate_wood_off")

-- PRESSURE PLATE STONE

minetest.register_node("jeija:pressure_plate_stone_off", {
	drawtype = "raillike",
	tile_images = {"jeija_pressure_plate_stone_off.png"},
	inventory_image = "jeija_pressure_plate_stone_off.png",
	paramtype = "light",
	is_ground_content = true,
	walkable = false,
	selection_box = {
		type = "fixed",
	},
	material = minetest.digprop_constanttime(0.3),
})

minetest.register_node("jeija:pressure_plate_stone_on", {
	drawtype = "raillike",
	tile_images = {"jeija_pressure_plate_stone_on.png"},
	inventory_image = "jeija_pressure_plate_stone_on.png",
	paramtype = "light",
	is_ground_content = true,
	walkable = false,
	selection_box = {
		type = "fixed",
	},
	material = minetest.digprop_constanttime(0.3),
	dug_item='node "jeija:pressure_plate_stone_off" 1'
})

minetest.register_craft({
	output = 'node "jeija:pressure_plate_stone_off" 1',
	recipe = {
		{'node "default:cobble"', 'node "default:cobble"'},
	}
})

minetest.register_abm(
	{nodenames = {"jeija:pressure_plate_stone_off"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		for k, obj in pairs(objs) do
			local objpos=obj:getpos()
			if objpos.y>pos.y-1 and objpos.y<pos.y then
				minetest.env:add_node(pos, {name="jeija:pressure_plate_stone_on"})
				mesecon:receptor_on(pos, "pressureplate")
			end
		end	
	end,
})

minetest.register_abm(
	{nodenames = {"jeija:pressure_plate_stone_on"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		if objs[1]==nil then
			minetest.env:add_node(pos, {name="jeija:pressure_plate_stone_off"})
			mesecon:receptor_off(pos, "pressureplate")
		end
	end,
})

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:pressure_plate_stone_on" then
			mesecon:receptor_off(pos, "pressureplate")
		end	
	end
)

mesecon:add_receptor_node("jeija:pressure_plate_stone_on")
mesecon:add_receptor_node_off("jeija:pressure_plate_stone_off")


--SHORT RANGE DETECTORS
minetest.register_node("jeija:object_detector_off", {
	tile_images = {"default_steel_block.png", "default_steel_block.png", "jeija_object_detector_off.png", "jeija_object_detector_off.png", "jeija_object_detector_off.png", "jeija_object_detector_off.png"},
	inventory_image = minetest.inventorycube("default_steel_block.png", "jeija_object_detector_off.png", "jeija_object_detector_off.png"),
	paramtype = "light",
	walkable = true,
	material = minetest.digprop_stonelike(4),
})

minetest.register_node("jeija:object_detector_on", {
	tile_images = {"default_steel_block.png", "default_steel_block.png", "jeija_object_detector_on.png", "jeija_object_detector_on.png", "jeija_object_detector_on.png", "jeija_object_detector_on.png"},
	inventory_image = minetest.inventorycube("jeija_object_detector_on.png"),
	paramtype = "light",
	walkable = true,
	material = minetest.digprop_stonelike(4),
	dug_item = 'node "jeija:object_detector_off" 1'
})

minetest.register_craft({
	output = 'node "jeija:object_detector_off" 1',
	recipe = {
		{'node "default:steelblock"', '', 'node "default:steelblock"'},
		{'node "default:steelblock"', 'craft "jeija:ic"', 'node "default:steelblock"'},
		{'node "default:steelblock"', 'node "jeija:mesecon_off', 'node "default:steelblock"'},
	}
})

minetest.register_abm(
	{nodenames = {"jeija:object_detector_off"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 6)
		for k, obj in pairs(objs) do
			if obj:get_entity_name()~="jeija:piston_pusher_sticky" and obj:get_entity_name()~="jeija:piston_pusher_normal" and obj:get_player_name()~=nil then -- Detected object is not piston pusher - will be changed if every entity has a type (like entity_type=mob)
				local objpos=obj:getpos()
				minetest.env:add_node(pos, {name="jeija:object_detector_on"})
				mesecon:receptor_on(pos, "pressureplate")
			end
		end	
	end,
})

minetest.register_abm(
	{nodenames = {"jeija:object_detector_on"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 6)
		local objectfound=0
		for k, obj in pairs(objs) do
			if obj:get_entity_name()~="jeija:piston_pusher_sticky" and obj:get_entity_name()~="jeija:piston_pusher_normal" and obj~=nil and obj:get_player_name()~=nil then -- Detected object is not piston pusher - will be changed if every entity has a type (like entity_type=mob)
				objectfound=objectfound + 1
			end
		end	
		if objectfound==0 then
			minetest.env:add_node(pos, {name="jeija:object_detector_off"})
			mesecon:receptor_off(pos, "pressureplate")
		end
	end,
})

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:object_detector_on" then
			mesecon:receptor_off(pos, "pressureplate")
		end	
	end
)

mesecon:add_receptor_node("jeija:object_detector_on")
mesecon:add_receptor_node_off("jeija:object_detector_off")


--MESECON TORCHES

minetest.register_craft({
    output = 'node "jeija:mesecon_torch_on" 4',
    recipe = {
        {'node "jeija:mesecon_off"'},
        {'craft "default:stick"'},
    }
})

minetest.register_node("jeija:mesecon_torch_off", {
    drawtype = "torchlike",
    tile_images = {"jeija_torches_off.png", "jeija_torches_off_ceiling.png", "jeija_torches_off_side.png"},
    inventory_image = "jeija_torches_off.png",
    sunlight_propagates = true,
    walkable = false,
    wall_mounted = true,
    material = minetest.digprop_constanttime(0.5),
    dug_item = 'node "jeija:mesecon_torch_on" 1',
})

minetest.register_node("jeija:mesecon_torch_on", {
    drawtype = "torchlike",
    tile_images = {"jeija_torches_on.png", "jeija_torches_on_ceiling.png", "jeija_torches_on_side.png"},
    inventory_image = "jeija_torches_on.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    wall_mounted = true,
    material = minetest.digprop_constanttime(0.5),
    light_source = LIGHT_MAX-5,
})

--[[minetest.register_on_placenode(function(pos, newnode, placer)
	if (newnode.name=="jeija:mesecon_torch_off" or newnode.name=="jeija:mesecon_torch_on")
	and (newnode.param2==8 or newnode.param2==4) then
		minetest.env:remove_node(pos)
		--minetest.env:add_item(pos, "craft 'jeija:mesecon_torch_on' 1")
	end
end)]]

minetest.register_abm({
    nodenames = {"jeija:mesecon_torch_off","jeija:mesecon_torch_on"},
    interval = 0.2,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local pa = {x=0, y=0, z=0}
	pa.y = 1
	local rules_string=""

	if node.param2 == 32 then
		pa.z = -1
		rules_string="mesecontorch_z+"
	end
	if node.param2 == 2 then
		pa.x = -1
		rules_string="mesecontorch_x+"
	end
	if node.param2 == 16 then
		pa.z = 1
		rules_string="mesecontorch_z-"
	end
	if node.param2 == 1 then
		pa.x = 1
		rules_string="mesecontorch_x-"
	end
	if node.param2 == 4 then
		rules_string="mesecontorch_y-"
		pa.y = 1
		pa.z=0
		pa.x=0
        end
        if node.param2 == 8 then
		rules_string="mesecontorch_y+"
		pa.y = -1
		pa.z=0
		pa.x=0
        end

	local rules=mesecon:get_rules(rules_string)
        if mesecon:is_power_on({x=pos.x, y=pos.y, z=pos.z}, pa.x, pa.y, pa.z)==1 then
            if node.name ~= "jeija:mesecon_torch_off" then
                minetest.env:add_node(pos, {name="jeija:mesecon_torch_off",param2=node.param2})
                mesecon:receptor_off({x=pos.x-pa.x, y=pos.y-pa.y, z=pos.z-pa.z}, rules)
            end
        else
            if node.name ~= "jeija:mesecon_torch_on" then
                minetest.env:add_node(pos, {name="jeija:mesecon_torch_on",param2=node.param2})
                mesecon:receptor_on({x=pos.x-pa.x, y=pos.y-pa.y, z=pos.z-pa.z}, rules)
            end
        end
    end
})

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "jeija:mesecon_torch_on" then
			mesecon:receptor_off(pos)
		end	
	end
)

minetest.register_on_placenode(function(pos, node, placer)
	if node.name == "jeija:mesecon_torch_on" then
		local rules_string=""

		if node.param2 == 32 then
			rules_string="mesecontorch_z+"
		end
		if node.param2 == 2 then
			rules_string="mesecontorch_x+"
		end
		if node.param2 == 16 then
			rules_string="mesecontorch_z-"
		end
		if node.param2 == 1 then
			rules_string="mesecontorch_x-"
		end
		if node.param2 == 4 then
			rules_string="mesecontorch_y-"
	        end
	        if node.param2 == 8 then
			rules_string="mesecontorch_y+"
	        end
		
		local rules=mesecon:get_rules(rules_string)
		mesecon:receptor_on(pos, rules)
	end
end)

mesecon:add_receptor_node("jeija:mesecon_torch_on")
mesecon:add_receptor_node_off("jeija:mesecon_torch_off")

-- Param2 Table (Block Attached To)
-- 32 = z-1
-- 2 = x-1
-- 16 = z+1
-- 1 = x+1
-- 4 = y+1
-- 8 = y-1


-- MOVESTONES
dofile(minetest.get_modpath("jeija").."/movestone.lua")
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
