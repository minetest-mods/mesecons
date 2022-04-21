local mese_nodename = minetest.registered_aliases["mesecons_gamecompat:mese"]
if mese_nodename then
	-- Convert placeholders.
	minetest.register_alias("mesecons_extrawires:mese", mese_nodename)
else
	-- Register placeholder.
	mese_nodename = "mesecons_extrawires:mese"
	minetest.register_node("mesecons_extrawires:mese", {
		description = "Mese Wire",
		tiles = {"mesecons_wire_off.png"},
		paramtype = "light",
		light_source = 3,
		groups = {cracky = 1},
		sounds = mesecon.node_sound.stone,
	})
end

local mesewire_rules =
{
	{x = 1, y = 0, z = 0},
	{x =-1, y = 0, z = 0},
	{x = 0, y = 1, z = 0},
	{x = 0, y =-1, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z =-1},
}

minetest.override_item(mese_nodename, {
	mesecons = {conductor = {
		state = mesecon.state.off,
		onstate = "mesecons_extrawires:mese_powered",
		rules = mesewire_rules
	}}
})

-- Copy node definition of powered mese from normal mese
-- and brighten texture tiles to indicate mese is powered
local unpowered_def = minetest.registered_nodes[mese_nodename]
local powered_def = mesecon.merge_tables(unpowered_def, {
	drop = mese_nodename,
	paramtype = "light",
	light_source = math.min(unpowered_def.light_source + 2, minetest.LIGHT_MAX),
	mesecons = {conductor = {
		state = mesecon.state.on,
		offstate = mese_nodename,
		rules = mesewire_rules
	}},
	groups = mesecon.merge_tables(unpowered_def.groups or {}, {not_in_creative_inventory = 1}),
	on_blast = mesecon.on_blastnode,
})

for i, v in pairs(powered_def.tiles) do
	powered_def.tiles[i] = v .. "^[brighten"
end

minetest.register_node("mesecons_extrawires:mese_powered", powered_def)
