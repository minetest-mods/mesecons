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
--	# An off-state node (e.g. mesecons:mesecon_switch_off"
--	# An on-state node (e.g. mesecons:mesecon_switch_on"
--The on-state and off-state nodes should be registered in the mesecon api, 
--so that the Mesecon circuit can be recalculated. This can be done using
--
--mesecon:add_receptor_node(nodename) -- for on-state node
--mesecon:add_receptor_node_off(nodename) -- for off-state node
--example: mesecon:add_receptor_node("mesecons:mesecon_switch_on")
--
--Turning receptors on and off
--Usually the receptor has to turn on and off. For this, you have to
--	# Remove the node and replace it with the node in the other state (e.g. replace on by off)
--	# Send the event to the mesecon circuit by using the api functions
--		mesecon:receptor_on (pos, rules) } These functions take the position of your receptor
--		mesecon:receptor_off(pos, rules) } as their parameter.
--
--You can specify the rules using the rules parameter. If you don't want special rules, just leave it out
--e.g. if you want to use the "pressureplate" rules, you use this command:
--mesecon:receptor_on (pos, mesecon:get_rules("pressureplate"))
--The rules can be manipulated by several rotate functions:
--rules=mesecon:rotate_rules_right/left/up/down(rules)
--
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
--	if node.name=="mesecons:removestone" then -- Check if it really is removestone. If you wouldn't use this, every node next to mesecons would be removed
--		minetest.env:remove_node(pos) -- The action: The removestone is removed
--	end -- end of if
--end) -- end of the function, )=end of the parameters of mesecon:register_on_signal_on

-- INCLUDE SETTINGS
dofile(minetest.get_modpath("mesecons").."/settings.lua")

-- PUBLIC VARIABLES
mesecon={} -- contains all functions and all global variables
mesecon.actions_on={} -- Saves registered function callbacks for mesecon on
mesecon.actions_off={} -- Saves registered function callbacks for mesecon off
mesecon.actions_change={} -- Saves registered function callbacks for mesecon change
mesecon.pwr_srcs={}
mesecon.pwr_srcs_off={}
mesecon.rules={}


-- MESECONS

minetest.register_node("mesecons:mesecon_off", {
	drawtype = "raillike",
	tile_images = {"jeija_mesecon_off.png", "jeija_mesecon_curved_off.png", "jeija_mesecon_t_junction_off.png", "jeija_mesecon_crossing_off.png"},
	inventory_image = "jeija_mesecon_off.png",
	wield_image = "jeija_mesecon_off.png",
	paramtype = "light",
	is_ground_content = true,
	walkable = false,
	selection_box = {
		type = "fixed",
	},
	groups = {dig_immediate=3},
    	description="Mesecons",
})

minetest.register_node("mesecons:mesecon_on", {
	drawtype = "raillike",
	tile_images = {"jeija_mesecon_on.png", "jeija_mesecon_curved_on.png", "jeija_mesecon_t_junction_on.png", "jeija_mesecon_crossing_on.png"},
	paramtype = "light",
	is_ground_content = true,
	walkable = false,
	selection_box = {
		type = "fixed",
	},
	groups = {dig_immediate=3},
	drop = '"mesecons:mesecon_off" 1',
	light_source = LIGHT_MAX-11,
})

minetest.register_craft({
	output = '"mesecons:mesecon_off" 16',
	recipe = {
		{'"default:mese"'},
	}
})

function mesecon:is_power_on(pos)
	local node = minetest.env:get_node(pos)
	if node.name == "mesecons:mesecon_on" or mesecon:is_receptor_node(node.name) then
		return true
	end
	return false
end

function mesecon:is_power_off(pos)
	local node = minetest.env:get_node(pos)
	if node.name == "mesecons:mesecon_off" or mesecon:is_receptor_node_off(node.name) then
		return 1
	end
	return 0
end

function mesecon:turnon(p, x, y, z, firstcall, rules)
	if rules==nil then
		rules=mesecon:get_rules("default")
	end
	local lpos = {}
	lpos.x=p.x+x
	lpos.y=p.y+y
	lpos.z=p.z+z

	mesecon:changesignal(lpos)
	mesecon:activate(lpos)

	local node = minetest.env:get_node(lpos)
	if node.name == "mesecons:mesecon_off" then
		--minetest.env:remove_node(lpos)
		minetest.env:add_node(lpos, {name="mesecons:mesecon_on"})
		nodeupdate(lpos)
	end
	if node.name == "mesecons:mesecon_off" or firstcall then
		local i=1
		while rules[i]~=nil do 
			mesecon:turnon(lpos, rules[i].x, rules[i].y, rules[i].z, false)
			i=i+1
		end
	end
end

function mesecon:turnoff(pos, x, y, z, firstcall, rules)
	if rules==nil then
		rules=mesecon:get_rules("default")
	end
	local lpos = {}
	lpos.x=pos.x+x
	lpos.y=pos.y+y
	lpos.z=pos.z+z

	local node = minetest.env:get_node(lpos)
	local connected = 0
	local checked = {}

	--Send Signals to effectors:
	mesecon:changesignal(lpos)
	if not mesecon:check_if_turnon(lpos) then
		mesecon:deactivate(lpos)
	end

	if not(firstcall) and connected==0 then
		connected=mesecon:connected_to_pw_src(lpos, 0, 0, 0, checked)	
	end

	if connected == 0 and  node.name == "mesecons:mesecon_on" then
		--minetest.env:remove_node(lpos)
		minetest.env:add_node(lpos, {name="mesecons:mesecon_off"})
		nodeupdate(lpos)
	end


	if node.name == "mesecons:mesecon_on" or firstcall then
		if connected == 0 then
			local i=1
			while rules[i]~=nil do 
				mesecon:turnoff(lpos, rules[i].x, rules[i].y, rules[i].z, false)
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

		if mesecon:is_receptor_node(node.name, lpos, pos) == true then -- receptor nodes (power sources) can be added using mesecon:add_receptor_node
			return 1
		end

		if node.name=="mesecons:mesecon_on" or firstcall then -- add other conductors here
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
	local i=1
	local j=1
	local k=1
	local rcpt
	local rcpt_pos={}
	local rules

	rules=mesecon:get_rules("default")
	while rules[k]~=nil do
		if minetest.env:get_node({x=pos.x+rules[k].x, y=pos.y+rules[k].y, z=pos.z+rules[k].z}).name=="mesecons:mesecon_on" then
			return true
		end
		k=k+1
	end

	while mesecon.rules[i]~=nil do
		j=1
		while mesecon.rules[i].rules[j]~=nil do
			rcpt_pos={x=pos.x-mesecon.rules[i].rules[j].x, y=pos.y-mesecon.rules[i].rules[j].y, z=pos.z-mesecon.rules[i].rules[j].z}
			rcpt=minetest.env:get_node(rcpt_pos)
			if mesecon:is_receptor_node(rcpt.name, rcpt_pos, pos) then 
				return true 
			end
			j=j+1
		end
		i=i+1
	end
	
	return false
end

minetest.register_on_placenode(function(pos, newnode, placer)
	if mesecon:check_if_turnon(pos) then
		if newnode.name == "mesecons:mesecon_off" then
			mesecon:turnon(pos, 0, 0, 0)		
		else
			mesecon:changesignal(pos)
			mesecon:activate(pos)
		end
	end
end)

minetest.register_on_dignode(
	function(pos, oldnode, digger)
		if oldnode.name == "mesecons:mesecon_on" then
			mesecon:turnoff(pos, 0, 0, 0, true)
		end	
	end
)

-- API API API API API API API API API API API API API API API API API API

function mesecon:add_receptor_node(nodename, rules, get_rules) --rules table is optional; if rules depend on param2 pass (nodename, nil, function get_rules)
	local i=1
	repeat
		if mesecon.pwr_srcs[i]==nil then break end
		i=i+1
	until false
	if get_rules==nil and rules==nil then
		rules=mesecon:get_rules("default")
	end
	mesecon.pwr_srcs[i]={}
	mesecon.pwr_srcs[i].name=nodename
	mesecon.pwr_srcs[i].rules=rules
	mesecon.pwr_srcs[i].get_rules=get_rules
end

function mesecon:add_receptor_node_off(nodename, rules, get_rules)
	local i=1
	repeat
		if mesecon.pwr_srcs_off[i]==nil then break end
		i=i+1
	until false
	if get_rules==nil and rules==nil then
		rules=mesecon:get_rules("default")
	end
	mesecon.pwr_srcs_off[i]={}
	mesecon.pwr_srcs_off[i].name=nodename
	mesecon.pwr_srcs_off[i].rules=rules
	mesecon.pwr_srcs_off[i].get_rules=get_rules
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

function mesecon:register_on_signal_change(action)
	local i	= 1	
	repeat
		i=i+1
		if mesecon.actions_change[i]==nil then break end
	until false
	mesecon.actions_change[i]=action
end



-- INTERNAL API


function mesecon:is_receptor_node(nodename, pos, ownpos) --ownpos must be position of the effector/mesecon NOT of the receptor node; pos is the receptor position
	local i=1
	local j=1
	repeat
		if mesecon.pwr_srcs[i].name==nodename then
			if pos==nil and ownpos==nil then --old usage still possible
				return true
			end
			local rules=mesecon.pwr_srcs[i].rules
			local node=minetest.env:get_node(pos)
			if rules==nil then
				rules=mesecon.pwr_srcs[i].get_rules(node.param2)
			end

			j=1
			while rules[j]~=nil do --Check if dest. position is specified in the receptor's rules
				if pos.x+rules[j].x==ownpos.x
				and pos.y+rules[j].y==ownpos.y
				and pos.z+rules[j].z==ownpos.z then
					return true
				end
				j=j+1
			end
		end
		i=i+1
	until mesecon.pwr_srcs[i]==nil
	return false
end

function mesecon:is_receptor_node_off(nodename, pos, ownpos) --ownpos must be position of the effector/mesecon NOT of the receptor node; pos is the receptor position
	local i=1
	local j=1
	repeat
		if mesecon.pwr_srcs_off[i].name==nodename then
			if pos==nil and ownpos==nil then --old usage still possible
				return true
			end
			local rules=mesecon.pwr_srcs_off[i].rules
			local node=minetest.env:get_node(pos)
			if rules==nil then
				rules=mesecon.pwr_srcs_off[i].get_rules(node.param2)
			end

			j=1
			while rules[j]~=nil do
				if pos.x+rules[j].x==ownpos.x
				and pos.y+rules[j].y==ownpos.y
				and pos.z+rules[j].z==ownpos.z then
					return true
				end
				j=j+1
			end
		end
		i=i+1
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
	repeat
		i=i+1
		if mesecon.actions_off[i]~=nil then mesecon.actions_off[i](pos, node) 
		else break			
		end
	until false
end

function mesecon:changesignal(pos)
	local node = minetest.env:get_node(pos)	
	local i = 1
	repeat
		i=i+1
		if mesecon.actions_change[i]~=nil then mesecon.actions_change[i](pos, node) 
		else break			
		end
	until false
end

function mesecon:add_rules(name, rules)
	local i=0
	while mesecon.rules[i]~=nil do
		i=i+1
	end
	mesecon.rules[i]={}
	mesecon.rules[i].name=name
	mesecon.rules[i].rules=rules
end

function mesecon:get_rules(name)
	local i=0
	while mesecon.rules[i]~=nil do
		if mesecon.rules[i].name==name then
			return mesecon.rules[i].rules
		end
		i=i+1
	end
end

mesecon:add_rules("default", 
{{x=0,  y=0,  z=-1},
{x=1,  y=0,  z=0},
{x=-1, y=0,  z=0},
{x=0,  y=0,  z=1},
{x=1,  y=1,  z=0},
{x=1,  y=-1, z=0},
{x=-1, y=1,  z=0},
{x=-1, y=-1, z=0},
{x=0,  y=1,  z=1},
{x=0,  y=-1, z=1},
{x=0,  y=1,  z=-1},
{x=0,  y=-1, z=-1}})


--Rules rotation Functions:
function mesecon:rotate_rules_right(rules)
	local i=1
	local nr={};
	while rules[i]~=nil do
		nr[i]={}
		nr[i].z=rules[i].x
		nr[i].x=-rules[i].z
		nr[i].y=rules[i].y
		i=i+1
	end
	return nr
end

function mesecon:rotate_rules_left(rules)
	local i=1
	local nr={};
	while rules[i]~=nil do
		nr[i]={}
		nr[i].z=-rules[i].x
		nr[i].x=rules[i].z
		nr[i].y=rules[i].y
		i=i+1
	end
	return nr
end

function mesecon:rotate_rules_down(rules)
	local i=1
	local nr={};
	while rules[i]~=nil do
		nr[i]={}
		nr[i].y=rules[i].x
		nr[i].x=-rules[i].y
		nr[i].z=rules[i].z
		i=i+1
	end
	return nr
end

function mesecon:rotate_rules_up(rules)
	local i=1
	local nr={};
	while rules[i]~=nil do
		nr[i]={}
		nr[i].y=-rules[i].x
		nr[i].x=rules[i].y
		nr[i].z=rules[i].z
		i=i+1
	end
	return nr
end

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
