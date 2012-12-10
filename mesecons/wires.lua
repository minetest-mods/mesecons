-- Oldstyle wires:

if NEW_STYLE_WIRES == false then --old wires
minetest.register_node("mesecons:mesecon_off", {
	drawtype = "raillike",
	tiles = {"jeija_mesecon_off.png", "jeija_mesecon_curved_off.png", "jeija_mesecon_t_junction_off.png", "jeija_mesecon_crossing_off.png"},
	inventory_image = "jeija_mesecon_off.png",
	wield_image = "jeija_mesecon_off.png",
	paramtype = "light",
	is_ground_content = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
	},
	groups = {dig_immediate=3, mesecon=1, mesecon_conductor_craftable=1},
    	description="Mesecons",
})

minetest.register_node("mesecons:mesecon_on", {
	drawtype = "raillike",
	tiles = {"jeija_mesecon_on.png", "jeija_mesecon_curved_on.png", "jeija_mesecon_t_junction_on.png", "jeija_mesecon_crossing_on.png"},
	paramtype = "light",
	is_ground_content = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
	},
	groups = {dig_immediate=3, not_in_creaive_inventory=1, mesecon=1},
	drop = '"mesecons:mesecon_off" 1',
	light_source = LIGHT_MAX-11,
})
mesecon:register_conductor("mesecons:mesecon_on", "mesecons:mesecon_off")
else  -- NEW STYLE WIRES

-- naming scheme: wire:(xp)(zp)(xm)(zm)_on/off
-- The conditions in brackets define whether there is a mesecon at that place or not
-- 1 = there is one; 0 = there is none
-- y always means y+

box_center = {-1/16, -.5, -1/16, 1/16, -.5+1/16, 1/16}
box_bump1 =  { -2/16, -8/16,  -2/16, 2/16, -13/32, 2/16 }

box_xp = {1/16, -.5, -1/16, 8/16, -.5+1/16, 1/16}
box_zp = {-1/16, -.5, 1/16, 1/16, -.5+1/16, 8/16}
box_xm = {-8/16, -.5, -1/16, -1/16, -.5+1/16, 1/16}
box_zm = {-1/16, -.5, -8/16, 1/16, -.5+1/16, -1/16}

box_xpy = {.5-1/16, -.5+1/16, -1/16, .5, .4999+1/16, 1/16}
box_zpy = {-1/16, -.5+1/16, .5-1/16, 1/16, .4999+1/16, .5}
box_xmy = {-.5, -.5+1/16, -1/16, -.5+1/16, .4999+1/16, 1/16}
box_zmy = {-1/16, -.5+1/16, -.5, 1/16, .4999+1/16, -.5+1/16}

for xp=0, 1 do
for zp=0, 1 do
for xm=0, 1 do
for zm=0, 1 do
for xpy=0, 1 do
for zpy=0, 1 do
for xmy=0, 1 do
for zmy=0, 1 do
	if (xpy == 1 and xp == 0) or (zpy == 1 and zp == 0) 
	or (xmy == 1 and xm == 0) or (zmy == 1 and zm == 0) then break end

	local groups
	local nodeid = 	tostring(xp )..tostring(zp )..tostring(xm )..tostring(zm )..
			tostring(xpy)..tostring(zpy)..tostring(xmy)..tostring(zmy)

	if nodeid == "00000000" then
		groups = {dig_immediate = 3, mesecon_conductor_craftable=1}
		wiredesc = "Mesecon"
	else
		groups = {dig_immediate = 3, not_in_creative_inventory = 1}
		wiredesc = "Mesecons Wire (ID: "..nodeid..")"
	end

	local nodebox = {}
	local adjx = false
	local adjz = false
	if xp == 1 then table.insert(nodebox, box_xp) adjx = true end
	if zp == 1 then table.insert(nodebox, box_zp) adjz = true end
	if xm == 1 then table.insert(nodebox, box_xm) adjx = true end
	if zm == 1 then table.insert(nodebox, box_zm) adjz = true end
	if xpy == 1 then table.insert(nodebox, box_xpy) end
	if zpy == 1 then table.insert(nodebox, box_zpy) end
	if xmy == 1 then table.insert(nodebox, box_xmy) end
	if zmy == 1 then table.insert(nodebox, box_zmy) end

	if adjx and adjz and (xp + zp + xm + zm > 2) then
		table.insert(nodebox, box_bump1)
		tiles_off = {
			"wires_bump_off.png",
			"wires_bump_off.png",
			"wires_vertical_off.png",
			"wires_vertical_off.png",
			"wires_vertical_off.png",
			"wires_vertical_off.png"
		}
		tiles_on = {
			"wires_bump_on.png",
			"wires_bump_on.png",
			"wires_vertical_on.png",
			"wires_vertical_on.png",
			"wires_vertical_on.png",
			"wires_vertical_on.png"
		}
	else
		table.insert(nodebox, box_center)
		tiles_off = {
			"wires_off.png",
			"wires_off.png",
			"wires_vertical_off.png",
			"wires_vertical_off.png",
			"wires_vertical_off.png",
			"wires_vertical_off.png"
		}
		tiles_on = {
			"wires_on.png",
			"wires_on.png",
			"wires_vertical_on.png",
			"wires_vertical_on.png",
			"wires_vertical_on.png",
			"wires_vertical_on.png"
		}
	end

	if nodeid == "00000000" then
		nodebox = {-8/16, -.5, -1/16, 8/16, -.5+1/16, 1/16}
	end

	minetest.register_node("mesecons:wire_"..nodeid.."_off", {
		description = wiredesc,
		drawtype = "nodebox",
		tiles = tiles_off,
--		inventory_image = "wires_inv.png",
--		wield_image = "wires_inv.png",
		inventory_image = "jeija_mesecon_off.png",
		wield_image = "jeija_mesecon_off.png",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		selection_box = {
              		type = "fixed",
			fixed = {-.5, -.5, -.5, .5, -.5+1/16, .5}
		},
		node_box = {
			type = "fixed",
			fixed = nodebox
		},
		groups = groups,
		walkable = false,
		stack_max = 99,
		drop = "mesecons:wire_00000000_off",
		mesecons = {conductor={
			state = mesecon.state.off,
			onstate = "mesecons:wire_"..nodeid.."_on"
		}}
	})

	minetest.register_node("mesecons:wire_"..nodeid.."_on", {
		description = "Wire ID:"..nodeid,
		drawtype = "nodebox",
		tiles = tiles_on,
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		selection_box = {
              		type = "fixed",
			fixed = {-.5, -.5, -.5, .5, -.5+1/16, .5}
		},
		node_box = {
			type = "fixed",
			fixed = nodebox
		},
		groups = {dig_immediate = 3, mesecon = 2, not_in_creative_inventory = 1},
		walkable = false,
		stack_max = 99,
		drop = "mesecons:wire_00000000_off",
		mesecons = {conductor={
			state = mesecon.state.on,
			offstate = "mesecons:wire_"..nodeid.."_off"
		}}
	})
end
end
end
end
end
end
end
end

minetest.register_on_placenode(function(pos, node)
	if minetest.registered_nodes[node.name].mesecons then
		mesecon:update_autoconnect(pos)
	end
end)

minetest.register_on_dignode(function(pos, node)
	if minetest.registered_nodes[node.name].mesecons then
		mesecon:update_autoconnect(pos)
	end
end)

function mesecon:update_autoconnect(pos, secondcall, replace_old)
	local xppos = {x=pos.x+1, y=pos.y, z=pos.z}
	local zppos = {x=pos.x, y=pos.y, z=pos.z+1}
	local xmpos = {x=pos.x-1, y=pos.y, z=pos.z}
	local zmpos = {x=pos.x, y=pos.y, z=pos.z-1}

	local xpympos = {x=pos.x+1, y=pos.y-1, z=pos.z}
	local zpympos = {x=pos.x, y=pos.y-1, z=pos.z+1}
	local xmympos = {x=pos.x-1, y=pos.y-1, z=pos.z}
	local zmympos = {x=pos.x, y=pos.y-1, z=pos.z-1}

	local xpypos = {x=pos.x+1, y=pos.y+1, z=pos.z}
	local zpypos = {x=pos.x, y=pos.y+1, z=pos.z+1}
	local xmypos = {x=pos.x-1, y=pos.y+1, z=pos.z}
	local zmypos = {x=pos.x, y=pos.y+1, z=pos.z-1}

	if secondcall == nil then
		mesecon:update_autoconnect(xppos, true)
		mesecon:update_autoconnect(zppos, true)
		mesecon:update_autoconnect(xmpos, true)
		mesecon:update_autoconnect(zmpos, true)

		mesecon:update_autoconnect(xpypos, true)
		mesecon:update_autoconnect(zpypos, true)
		mesecon:update_autoconnect(xmypos, true)
		mesecon:update_autoconnect(zmypos, true)

		mesecon:update_autoconnect(xpympos, true)
		mesecon:update_autoconnect(zpympos, true)
		mesecon:update_autoconnect(xmympos, true)
		mesecon:update_autoconnect(zmympos, true)
	end

	nodename = minetest.env:get_node(pos).name
	if string.find(nodename, "mesecons:wire_") == nil and not replace_old then return nil end

	if mesecon:rules_link_bothdir(pos, xppos) then xp = 1 else xp = 0 end
	if mesecon:rules_link_bothdir(pos, xmpos) then xm = 1 else xm = 0 end
	if mesecon:rules_link_bothdir(pos, zppos) then zp = 1 else zp = 0 end
	if mesecon:rules_link_bothdir(pos, zmpos) then zm = 1 else zm = 0 end

	if mesecon:rules_link_bothdir(pos, xpympos) then xp = 1 end
	if mesecon:rules_link_bothdir(pos, xmympos) then xm = 1 end
	if mesecon:rules_link_bothdir(pos, zpympos) then zp = 1 end
	if mesecon:rules_link_bothdir(pos, zmympos) then zm = 1 end

	if mesecon:rules_link(pos, xpypos) then xpy = 1 else xpy = 0 end
	if mesecon:rules_link(pos, zpypos) then zpy = 1 else zpy = 0 end
	if mesecon:rules_link(pos, xmypos) then xmy = 1 else xmy = 0 end
	if mesecon:rules_link(pos, zmypos) then zmy = 1 else zmy = 0 end

	-- Backward compatibility
	if replace_old then
		xp = 	(xp == 1 or	(string.find(minetest.env:get_node(xppos  ).name, "mesecons:mesecon_") ~= nil or
					 string.find(minetest.env:get_node(xpympos).name, "mesecons:mesecon_") ~= nil)) and 1 or 0
		zp = 	(zp == 1 or	(string.find(minetest.env:get_node(zppos  ).name, "mesecons:mesecon_") ~= nil or
			 		 string.find(minetest.env:get_node(zpympos).name, "mesecons:mesecon_") ~= nil)) and 1 or 0
		xm = 	(xm == 1 or	(string.find(minetest.env:get_node(xmpos  ).name, "mesecons:mesecon_") ~= nil or
					 string.find(minetest.env:get_node(xmympos).name, "mesecons:mesecon_") ~= nil)) and 1 or 0
		zm = 	(zm == 1 or 	(string.find(minetest.env:get_node(zmpos  ).name, "mesecons:mesecon_") ~= nil or
					 string.find(minetest.env:get_node(zmympos).name, "mesecons:mesecon_") ~= nil)) and 1 or 0

		xpy = (xpy == 1 or string.find(minetest.env:get_node(xpypos).name, "mesecons:mesecon_") ~=nil) and 1 or 0
		zpy = (zpy == 1 or string.find(minetest.env:get_node(zpypos).name, "mesecons:mesecon_") ~=nil) and 1 or 0
		xmy = (xmy == 1 or string.find(minetest.env:get_node(xmypos).name, "mesecons:mesecon_") ~=nil) and 1 or 0
		zmy = (zmy == 1 or string.find(minetest.env:get_node(zmypos).name, "mesecons:mesecon_") ~=nil) and 1 or 0
	end

	if xpy == 1 then xp = 1 end
	if zpy == 1 then zp = 1 end
	if xmy == 1 then xm = 1 end
	if zmy == 1 then zm = 1 end

	local nodeid = 	tostring(xp )..tostring(zp )..tostring(xm )..tostring(zm )..
			tostring(xpy)..tostring(zpy)..tostring(xmy)..tostring(zmy)

	
	if string.find(nodename, "_off") ~= nil then
		minetest.env:set_node(pos, {name = "mesecons:wire_"..nodeid.."_off"})
	else
		minetest.env:set_node(pos, {name = "mesecons:wire_"..nodeid.."_on" })
	end
end

minetest.register_craft({
	output = '"mesecons:wire_00000000_off" 16',
	recipe = {
		{'"default:mese"'},
	}
})

minetest.register_abm(
	{nodenames = {"mesecons:mesecon_off", "mesecons:mesecon_on"},
	interval = 2,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		mesecon:update_autoconnect(pos, false, true)
	end,
})
end
