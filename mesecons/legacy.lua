-- Un-forceload any forceloaded mapblocks from older versions of Mesecons which
-- used forceloading instead of VoxelManipulators.
local BLOCKSIZE = 16

-- convert block hash --> node position
local function unhash_blockpos(hash)
	return vector.multiply(minetest.get_position_from_hash(hash), BLOCKSIZE)
end

local old_forceloaded_blocks = mesecon.file2table("mesecon_forceloaded")
for hash, _ in pairs(old_forceloaded_blocks) do
	minetest.forceload_free_block(unhash_blockpos(hash))
end
os.remove(minetest.get_worldpath()..DIR_DELIM.."mesecon_forceloaded")

-- LBMs to convert old pistons to use facedir instead of separate up/down nodes
minetest.register_lbm({
	label = "Convert up pistons to use facedir",
	name = ":mesecons_pistons:update_up_pistons",
	nodenames = {"mesecons_pistons:piston_up_normal_on","mesecons_pistons:piston_up_normal_off",
			"mesecons_pistons:piston_up_sticky_on","mesecons_pistons:piston_up_sticky_off"},
	action = function(pos, node)
		if string.find(node.name, "sticky") then
			if string.sub(node.name, -3, -1) == "_on" then
				node.name = "mesecons_pistons:piston_sticky_on"
			else
				node.name = "mesecons_pistons:piston_sticky_off"
			end
		else
			if string.sub(node.name, -3, -1) == "_on" then
				node.name = "mesecons_pistons:piston_normal_on"
			else
				node.name = "mesecons_pistons:piston_normal_off"
			end
		end
		local dir = {x=0, y=-1, z=0}
		node.param2 = minetest.dir_to_facedir(dir, true)
		minetest.swap_node(pos, node)
	end
})

minetest.register_lbm({
	label = "Convert down pistons to use facedir",
	name = ":mesecons_pistons:update_down_pistons",
	nodenames = {"mesecons_pistons:piston_down_normal_on","mesecons_pistons:piston_down_normal_off",
			"mesecons_pistons:piston_down_sticky_on","mesecons_pistons:piston_down_sticky_off"},
	action = function(pos, node)
		if string.find(node.name, "sticky") then
			if string.sub(node.name, -3, -1) == "_on" then
				node.name = "mesecons_pistons:piston_sticky_on"
			else
				node.name = "mesecons_pistons:piston_sticky_off"
			end
		else
			if string.sub(node.name, -3, -1) == "_on" then
				node.name = "mesecons_pistons:piston_normal_on"
			else
				node.name = "mesecons_pistons:piston_normal_off"
			end
		end
		local dir = {x=0, y=1, z=0}
		node.param2 = minetest.dir_to_facedir(dir, true)
		minetest.swap_node(pos, node)
	end
})

minetest.register_lbm({
	label = "Convert up piston pushers to use facedir",
	name = ":mesecons_pistons:update_up_pushers",
	nodenames = {"mesecons_pistons:piston_up_pusher_normal", "mesecons_pistons:piston_up_pusher_sticky"},
	action = function(pos, node)
		if string.find(node.name, "sticky") then
			node.name = "mesecons_pistons:piston_pusher_sticky"
		else
			node.name = "mesecons_pistons:piston_pusher_normal"
		end
		local dir = {x=0, y=-1, z=0}
		node.param2 = minetest.dir_to_facedir(dir, true)
		minetest.swap_node(pos, node)
	end
})

minetest.register_lbm({
	label = "Convert down piston pushers to use facedir",
	name = ":mesecons_pistons:update_down_pushers",
	nodenames = {"mesecons_pistons:piston_down_pusher_normal", "mesecons_pistons:piston_down_pusher_sticky"},
	action = function(pos, node)
		if string.find(node.name, "sticky") then
			node.name = "mesecons_pistons:piston_pusher_sticky"
		else
			node.name = "mesecons_pistons:piston_pusher_normal"
		end
		local dir = {x=0, y=1, z=0}
		node.param2 = minetest.dir_to_facedir(dir, true)
		minetest.swap_node(pos, node)
	end
})
