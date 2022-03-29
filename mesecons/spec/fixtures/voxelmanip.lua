mineunit("world")
mineunit("common/vector")
mineunit("game/misc")

local VoxelManip = {}

local function create(p1, p2)
	local vm = setmetatable({nodes = {}}, VoxelManip)

	if type(p1) == "table" and type(p2) == "table" then
		vm:read_from_map(p1, p2)
	end

	return vm
end

function VoxelManip:read_from_map(p1, p2)
	assert.same(p1, p2)
	assert.is_nil(self.emin)

	local blockpos = vector.floor(vector.divide(p1, minetest.MAP_BLOCKSIZE))
	local emin = vector.multiply(blockpos, minetest.MAP_BLOCKSIZE)
	local emax = vector.add(emin, minetest.MAP_BLOCKSIZE - 1)
	self.emin, self.emax = emin, emax

	local p = vector.new(emin)
	while p.z <= emax.z do
		while p.y <= emax.y do
			while p.x <= emax.x do
				local node = world.get_node(p)
				if node then
					self.nodes[minetest.hash_node_position(p)] = node
				end
				p.x = p.x + 1
			end
			p.x = emin.x
			p.y = p.y + 1
		end
		p.y = emin.y
		p.z = p.z + 1
	end
end

function VoxelManip:get_node_at(pos)
	local node = self.nodes[minetest.hash_node_position(pos)]
	if node then
		return {name = node.name, param1 = node.param1, param2 = node.param2}
	else
		return {name = "ignore", param1 = 0, param2 = 0}
	end
end

function VoxelManip:set_node_at(pos, node)
	local emin, emax = self.emin, self.emax
	if pos.x < emin.x or pos.y < emin.y or pos.z < emin.z or pos.x > emax.x or pos.y > emax.y or pos.z > emax.z then
		return
	end
	self.nodes[minetest.hash_node_position(pos)] = {name = node.name, param1 = node.param1, param2 = node.param2}
end

function VoxelManip:write_to_map()
	local emin, emax = self.emin, self.emax
	local p = vector.new(emin)
	while p.z <= emax.z do
		while p.y <= emax.y do
			while p.x <= emax.x do
				local node = self.nodes[minetest.hash_node_position(p)]
				if node ~= nil or world.get_node(p) ~= nil then
					world.swap_node(p, node)
				end
				p.x = p.x + 1
			end
			p.x = emin.x
			p.y = p.y + 1
		end
		p.y = emin.y
		p.z = p.z + 1
	end
end

function VoxelManip.update_map()
end

function minetest.get_voxel_manip(p1, p2)
	return create(p1, p2)
end

mineunit.export_object(VoxelManip, {
	name = "VoxelManip",
	constructor = create,
})
