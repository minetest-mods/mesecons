-- Un-forceload any forceloaded mapblocks from older versions of Mesecons which
-- used forceloading instead of VoxelManipulators.
local old_forceloaded_blocks = mesecon.file2table("mesecon_forceloaded")
for hash, _ in pairs(old_forceloaded_blocks) do
	minetest.forceload_free_block(unhash_blockpos(hash))
end
os.remove(minetest.get_worldpath()..DIR_DELIM.."mesecon_forceloaded")
