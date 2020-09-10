
globals = {
	"mesecon",
	"minetest"
}

-- ignore unused vars
unused = false

read_globals = {
	-- Stdlib
	string = {fields = {"split"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"vector", "ItemStack",
	"dump", "VoxelArea",

	-- deps
	"default", "screwdriver",
	"digiline", "doors"
}

ignore = {
	"631", -- line too long
	"621", -- inconsistent indendation
	"542", -- empty if branch
}
