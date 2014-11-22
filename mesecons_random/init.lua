-- REMOVESTONE

minetest.register_node("mesecons_random:removestone", {
	tiles = {"jeija_removestone.png"},
	inventory_image = minetest.inventorycube("jeija_removestone_inv.png"),
	groups = {cracky=3},
	description="Removestone",
	sounds = default.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_on = function (pos, node)
			minetest.remove_node(pos)
			mesecon.update_autoconnect(pos)
		end
	}}
})

minetest.register_craft({
	output = 'mesecons_random:removestone 4',
	recipe = {
		{"", "default:cobble", ""},
		{"default:cobble", "group:mesecon_conductor_craftable", "default:cobble"},
		{"", "default:cobble", ""},
	}
})

-- GHOSTSTONE

local function get_tab(pos, func)
	local tab = {pos}
	local tab_avoid = {[pos.x.." "..pos.y.." "..pos.z] = true}
	local tab_done,num = {pos},2
	while tab[1] do
		for n,p in pairs(tab) do
			for i = -1,1,2 do
				for _,p2 in pairs({
					{x=p.x+i, y=p.y, z=p.z},
					{x=p.x, y=p.y+i, z=p.z},
					{x=p.x, y=p.y, z=p.z+i},
				}) do
					local pstr = p2.x.." "..p2.y.." "..p2.z
					if not tab_avoid[pstr]
					and func(p2) then
						tab_avoid[pstr] = true
						tab_done[num] = p2
						num = num+1
						table.insert(tab, p2)
					end
				end
			end
			tab[n] = nil
		end
	end
	return tab_done
end

local function is_ghoststone(pos)
	return minetest.get_node(pos).name == "mesecons_random:ghoststone"
end

local function is_ghoststone_active(pos)
	return minetest.get_node(pos).name == "mesecons_random:ghoststone_active"
end

local c = {}
local function update_ghoststones(pos, func, name)
	func = func or is_ghoststone
	name = name or "mesecons_random:ghoststone_active"
	local tab = get_tab(pos, func)
	if #tab < 50 then
		for _,p in pairs(tab) do
			minetest.set_node(p, {name=name})
		end
		return
	end

	local p = tab[1]
	local min = vector.new(p)
	local max = vector.new(p)
	for _,p in pairs(tab) do
		for _,coord in pairs({"x", "y", "z"}) do
			min[coord] = math.min(min[coord], p[coord])
			max[coord] = math.max(max[coord], p[coord])
		end
	end

	c[name] = c[name] or minetest.get_content_id(name)
	local c_name = c[name]

	local manip = minetest.get_voxel_manip()
	local emerged_pos1, emerged_pos2 = manip:read_from_map(min, max)
	local area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
	local nodes = manip:get_data()

	for _,p in pairs(tab) do
		nodes[area:indexp(p)] = c_name
	end

	manip:set_data(nodes)
	manip:write_to_map()
	manip:update_map()
	--print(string.format("[mesecons] ghostblocks updated after ca. %.2fs", os.clock() - --t1))
end

minetest.register_node("mesecons_random:ghoststone", {
	description="ghoststone",
	tiles = {"jeija_ghoststone.png"},
	is_ground_content = true,
	inventory_image = minetest.inventorycube("jeija_ghoststone_inv.png"),
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	mesecons = {--[[conductor = {
			state = mesecon.state.off,
			rules = { --axes
				{x = -1, y = 0, z = 0},
				{x = 1, y = 0, z = 0},
				{x = 0, y = -1, z = 0},
				{x = 0, y = 1, z = 0},
				{x = 0, y = 0, z = -1},
				{x = 0, y = 0, z = 1},
			},
			onstate = "mesecons_random:ghoststone_active"
		},]]
		effector = {
			rules = {
				{x = -1, y = 0, z = 0},
				{x = 1, y = 0, z = 0},
				{x = 0, y = -1, z = 0},
				{x = 0, y = 1, z = 0},
				{x = 0, y = 0, z = -1},
				{x = 0, y = 0, z = 1},
			},
			action_on = function(pos)
				update_ghoststones(pos)
			end
		}
	}
})

minetest.register_node("mesecons_random:ghoststone_active", {
	drawtype = "airlike",
	pointable = false,
	walkable = false,
	diggable = false,
	sunlight_propagates = true,
	paramtype = "light",
	mesecons = {--[[conductor = {
			state = mesecon.state.on,
			rules = {
				{x = -1, y = 0, z = 0},
				{x = 1, y = 0, z = 0},
				{x = 0, y = -1, z = 0},
				{x = 0, y = 1, z = 0},
				{x = 0, y = 0, z = -1},
				{x = 0, y = 0, z = 1},
			},
			offstate = "mesecons_random:ghoststone"
		},]]
		effector = {
			rules = {
				{x = -1, y = 0, z = 0},
				{x = 1, y = 0, z = 0},
				{x = 0, y = -1, z = 0},
				{x = 0, y = 1, z = 0},
				{x = 0, y = 0, z = -1},
				{x = 0, y = 0, z = 1},
			},
			action_off = function(pos)
				update_ghoststones(pos, is_ghoststone_active, "mesecons_random:ghoststone")
			end
		}
	},
	on_construct = function(pos)
		--remove shadow
		pos.y = pos.y+1
		if minetest.get_node(pos).name == "air" then
			minetest.dig_node(pos)
		end
	end
})


minetest.register_craft({
	output = 'mesecons_random:ghoststone 4',
	recipe = {
		{"default:steel_ingot", "default:cobble", "default:steel_ingot"},
		{"default:cobble", "group:mesecon_conductor_craftable", "default:cobble"},
		{"default:steel_ingot", "default:cobble", "default:steel_ingot"},
	}
})
