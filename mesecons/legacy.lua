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
