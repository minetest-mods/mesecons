function mesecon.move_node(pos, newpos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos):to_table()
	minetest.remove_node(pos)
	minetest.set_node(newpos, node)
	minetest.get_meta(pos):from_table(meta)
end

-- An on_rotate callback for mesecons components.
function mesecon.on_rotate(pos, node, _, _, new_param2)
	local new_node = {name = node.name, param1 = node.param1, param2 = new_param2}
	minetest.swap_node(pos, new_node)
	mesecon.on_dignode(pos, node)
	mesecon.on_placenode(pos, new_node)
	minetest.check_for_falling(pos)
	return true
end

-- An on_rotate callback for components which stay horizontal.
function mesecon.on_rotate_horiz(pos, node, user, mode, new_param2)
	if not minetest.global_exists("screwdriver") or mode ~= screwdriver.ROTATE_FACE then
		return false
	end
	return mesecon.on_rotate(pos, node, user, mode, new_param2)
end

-- Rules rotation Functions:
function mesecon.rotate_rules_right(rules)
	local nr = {}
	for i, rule in ipairs(rules) do
		table.insert(nr, {
			x = -rule.z,
			y =  rule.y,
			z =  rule.x,
			name = rule.name})
	end
	return nr
end

function mesecon.rotate_rules_left(rules)
	local nr = {}
	for i, rule in ipairs(rules) do
		table.insert(nr, {
			x =  rule.z,
			y =  rule.y,
			z = -rule.x,
			name = rule.name})
	end
	return nr
end

function mesecon.rotate_rules_down(rules)
	local nr = {}
	for i, rule in ipairs(rules) do
		table.insert(nr, {
			x = -rule.y,
			y =  rule.x,
			z =  rule.z,
			name = rule.name})
	end
	return nr
end

function mesecon.rotate_rules_up(rules)
	local nr = {}
	for i, rule in ipairs(rules) do
		table.insert(nr, {
			x =  rule.y,
			y = -rule.x,
			z =  rule.z,
			name = rule.name})
	end
	return nr
end
--

function mesecon.flattenrules(allrules)
--[[
	{
		{
			{xyz},
			{xyz},
		},
		{
			{xyz},
			{xyz},
		},
	}
--]]
	if allrules[1] and
	   allrules[1].x then
		return allrules
	end

	local shallowrules = {}
	for _, metarule in ipairs( allrules) do
	for _,     rule in ipairs(metarule ) do
		table.insert(shallowrules, rule)
	end
	end
	return shallowrules
--[[
	{
		{xyz},
		{xyz},
		{xyz},
		{xyz},
	}
--]]
end

function mesecon.rule2bit(findrule, allrules)
	--get the bit of the metarule the rule is in, or bit 1
	if (allrules[1] and
	    allrules[1].x) or
	    not findrule then
		return 1
	end
	for m,metarule in ipairs( allrules) do
	for _,    rule in ipairs(metarule ) do
		if vector.equals(findrule, rule) then
			return m
		end
	end
	end
end

function mesecon.rule2metaindex(findrule, allrules)
	--get the metarule the rule is in, or allrules
	if allrules[1].x then
		return nil
	end

	if not(findrule) then
		return mesecon.flattenrules(allrules)
	end

	for m, metarule in ipairs( allrules) do
	for _,     rule in ipairs(metarule ) do
		if vector.equals(findrule, rule) then
			return m
		end
	end
	end
end

function mesecon.rule2meta(findrule, allrules)
	if #allrules == 0 then return {} end

	local index = mesecon.rule2metaindex(findrule, allrules)
	if index == nil then
		if allrules[1].x then
			return allrules
		else
			return {}
		end
	end
	return allrules[index]
end

function mesecon.dec2bin(n)
	local x, y = math.floor(n / 2), n % 2
	if (n > 1) then
		return mesecon.dec2bin(x)..y
	else
		return ""..y
	end
end

function mesecon.getstate(nodename, states)
	for state, name in ipairs(states) do
		if name == nodename then
			return state
		end
	end
	error(nodename.." doesn't mention itself in "..dump(states))
end

function mesecon.getbinstate(nodename, states)
	return mesecon.dec2bin(mesecon.getstate(nodename, states)-1)
end

function mesecon.get_bit(binary,bit)
	bit = bit or 1
	local len = binary:len()
	if bit > len then return false end
	local c = len-(bit-1)
	return binary:sub(c,c) == "1"
end

function mesecon.set_bit(binary,bit,value)
	if value == "1" then
		if not mesecon.get_bit(binary,bit) then
			return mesecon.dec2bin(tonumber(binary,2)+math.pow(2,bit-1))
		end
	elseif value == "0" then
		if mesecon.get_bit(binary,bit) then
			return mesecon.dec2bin(tonumber(binary,2)-math.pow(2,bit-1))
		end
	end
	return binary

end

function mesecon.invertRule(r)
	return vector.multiply(r, -1)
end

function mesecon.tablecopy(obj) -- deep copy
	if type(obj) == "table" then
		return table.copy(obj)
	end
	return obj
end

-- Returns whether two values are equal.
-- In tables, keys are compared for identity but values are compared recursively.
-- There is no protection from infinite recursion.
function mesecon.cmpAny(t1, t2)
	if type(t1) ~= type(t2) then return false end
	if type(t1) ~= "table" then return t1 == t2 end

	-- Check that for each key of `t1` both tables have the same value
	for i, e in pairs(t1) do
		if not mesecon.cmpAny(e, t2[i]) then return false end
	end

	-- Check that all keys of `t2` are also keys of `t1` so were checked in the previous loop
	for i, _ in pairs(t2) do
		if t1[i] == nil then return false end
	end

	return true
end

-- Deprecated. Use `merge_tables` or `merge_rule_sets` as appropriate.
function mesecon.mergetable(source, dest)
	minetest.log("warning", debug.traceback("Deprecated call to mesecon.mergetable"))
	local rval = mesecon.tablecopy(dest)

	for k, v in pairs(source) do
		rval[k] = dest[k] or mesecon.tablecopy(v)
	end
	for i, v in ipairs(source) do
		table.insert(rval, mesecon.tablecopy(v))
	end

	return rval
end

-- Merges several rule sets in one. Order may not be preserved. Nil arguments
-- are ignored.
-- The rule sets must be of the same kind (either all single-level or all two-level).
-- The function may be changed to normalize the resulting set in some way.
function mesecon.merge_rule_sets(...)
	local rval = {}
	for _, t in pairs({...}) do -- ignores nils automatically
		table.insert_all(rval, mesecon.tablecopy(t))
	end
	return rval
end

-- Merges two tables, with entries from `replacements` taking precedence over
-- those from `base`. Returns the new table.
-- Values are deep-copied from either table, keys are referenced.
-- Numerical indices aren’t handled specially.
function mesecon.merge_tables(base, replacements)
	local ret = mesecon.tablecopy(replacements) -- these are never overriden so have to be copied in any case
	for k, v in pairs(base) do
		if ret[k] == nil then -- it could be `false`
			ret[k] = mesecon.tablecopy(v)
		end
	end
	return ret
end

function mesecon.register_node(name, spec_common, spec_off, spec_on)
	spec_common.drop = spec_common.drop or name .. "_off"
	spec_common.on_blast = spec_common.on_blast or mesecon.on_blastnode
	spec_common.__mesecon_basename = name
	spec_on.__mesecon_state = "on"
	spec_off.__mesecon_state = "off"

	spec_on = mesecon.merge_tables(spec_common, spec_on);
	spec_off = mesecon.merge_tables(spec_common, spec_off);

	minetest.register_node(name .. "_on", spec_on)
	minetest.register_node(name .. "_off", spec_off)
end

-- swap onstate and offstate nodes, returns new state
function mesecon.flipstate(pos, node)
	local nodedef = minetest.registered_nodes[node.name]
	local newstate
	if (nodedef.__mesecon_state == "on") then newstate = "off" end
	if (nodedef.__mesecon_state == "off") then newstate = "on" end

	minetest.swap_node(pos, {name = nodedef.__mesecon_basename .. "_" .. newstate,
		param2 = node.param2})

	return newstate
end

-- File writing / reading utilities
local wpath = minetest.get_worldpath()
function mesecon.file2table(filename)
	local f = io.open(wpath.."/"..filename, "r")
	if f == nil then return {} end
	local t = f:read("*all")
	f:close()
	if t == "" or t == nil then return {} end
	return minetest.deserialize(t)
end

function mesecon.table2file(filename, table)
	local f = io.open(wpath.."/"..filename, "w")
	f:write(minetest.serialize(table))
	f:close()
end

-- Block position "hashing" (convert to integer) functions for voxelmanip cache
local BLOCKSIZE = 16

-- convert node position --> block hash
local function hash_blockpos(pos)
	return minetest.hash_node_position({
		x = math.floor(pos.x/BLOCKSIZE),
		y = math.floor(pos.y/BLOCKSIZE),
		z = math.floor(pos.z/BLOCKSIZE)
	})
end

-- Maps from a hashed mapblock position (as returned by hash_blockpos) to a
-- table.
--
-- Contents of the table are:
-- “vm” → the VoxelManipulator
-- “dirty” → true if data has been modified
--
-- Nil if no VM-based transaction is in progress.
local vm_cache = nil

-- Cache from node position hashes to nodes (represented as tables).
local vm_node_cache = nil

-- Whether the current transaction will need a light update afterward.
local vm_update_light = false

-- Starts a VoxelManipulator-based transaction.
--
-- During a VM transaction, calls to vm_get_node and vm_swap_node operate on a
-- cached copy of the world loaded via VoxelManipulators. That cache can later
-- be committed to the real map by means of vm_commit or discarded by means of
-- vm_abort.
function mesecon.vm_begin()
	vm_cache = {}
	vm_node_cache = {}
	vm_update_light = false
end

-- Finishes a VoxelManipulator-based transaction, freeing the VMs and map data
-- and writing back any modified areas.
function mesecon.vm_commit()
	for hash, tbl in pairs(vm_cache) do
		if tbl.dirty then
			local vm = tbl.vm
			vm:write_to_map(vm_update_light)
			vm:update_map()
		end
	end
	vm_cache = nil
	vm_node_cache = nil
end

-- Finishes a VoxelManipulator-based transaction, freeing the VMs and throwing
-- away any modified areas.
function mesecon.vm_abort()
	vm_cache = nil
	vm_node_cache = nil
end

-- Gets the cache entry covering a position, populating it if necessary.
local function vm_get_or_create_entry(pos)
	local hash = hash_blockpos(pos)
	local tbl = vm_cache[hash]
	if not tbl then
		tbl = {vm = minetest.get_voxel_manip(pos, pos), dirty = false}
		vm_cache[hash] = tbl
	end
	return tbl
end

local function vm_get_node_nocopy(pos)
	local hash = minetest.hash_node_position(pos)
	local node = vm_node_cache[hash]
	if not node then
		node = vm_get_or_create_entry(pos).vm:get_node_at(pos)
		vm_node_cache[hash] = node
	end
	return node.name ~= "ignore" and node or nil
end

-- Gets the node at a given position during a VoxelManipulator-based
-- transaction.
function mesecon.vm_get_node(pos)
	local node = vm_get_node_nocopy(pos)
	return node and {name = node.name, param1 = node.param1, param2 = node.param2}
end

-- Sets a node’s name during a VoxelManipulator-based transaction.
--
-- Existing param1, param2, and metadata are left alone.
--
-- The swap will necessitate a light update unless update_light equals false.
function mesecon.vm_swap_node(pos, name, update_light)
	-- If one node needs a light update, all VMs should use light updates to
	-- prevent newly calculated light from being overwritten by other VMs.
	vm_update_light = vm_update_light or update_light ~= false

	local tbl = vm_get_or_create_entry(pos)
	local hash = minetest.hash_node_position(pos)
	local node = vm_node_cache[hash]
	if not node then
		node = tbl.vm:get_node_at(pos)
		vm_node_cache[hash] = node
	end
	node.name = name
	tbl.vm:set_node_at(pos, node)
	tbl.dirty = true
end

-- Get node, loading map if necessary.
local function get_node_load(pos)
	local node = minetest.get_node_or_nil(pos)
	if node == nil then
		-- Node is not currently loaded; use a VoxelManipulator to prime
		-- the mapblock cache and try again.
		minetest.get_voxel_manip(pos, pos)
		node = minetest.get_node_or_nil(pos)
	end
	return node
end

-- Gets the node at a given position, regardless of whether it is loaded or
-- not, respecting a transaction if one is in progress.
--
-- Outside a VM transaction, if the mapblock is not loaded, it is pulled into
-- the server’s main map data cache and then accessed from there.
--
-- Inside a VM transaction, the transaction’s VM cache is used.
function mesecon.get_node_force(pos)
	if vm_cache then
		return mesecon.vm_get_node(pos)
	else
		return get_node_load(pos)
	end
end

-- Same without copying the internal node. Not part of public API.
function mesecon.get_node_force_nocopy(pos)
	if vm_cache then
		return vm_get_node_nocopy(pos)
	else
		return get_node_load(pos)
	end
end

-- Swaps the node at a given position, regardless of whether it is loaded or
-- not, respecting a transaction if one is in progress.
--
-- Outside a VM transaction, if the mapblock is not loaded, it is pulled into
-- the server’s main map data cache and then accessed from there.
--
-- Inside a VM transaction, the transaction’s VM cache is used.
--
-- This function can only be used to change the node’s name, not its parameters
-- or metadata.
--
-- The swap will necessitate a light update unless update_light equals false.
function mesecon.swap_node_force(pos, name, update_light)
	if vm_cache then
		return mesecon.vm_swap_node(pos, name, update_light)
	else
		-- This serves to both ensure the mapblock is loaded and also hand us
		-- the old node table so we can preserve param2.
		local node = get_node_load(pos)
		node.name = name
		minetest.swap_node(pos, node)
	end
end

-- Autoconnect Hooks
-- Nodes like conductors may change their appearance and their connection rules
-- right after being placed or after being dug, e.g. the default wires use this
-- to automatically connect to linking nodes after placement.
-- After placement, the update function will be executed immediately so that the
-- possibly changed rules can be taken into account when recalculating the circuit.
-- After digging, the update function will be queued and executed after
-- recalculating the circuit. The update function must take care of updating the
-- node at the given position itself, but also all of the other nodes the given
-- position may have (had) a linking connection to.
mesecon.autoconnect_hooks = {}

-- name: A unique name for the hook, e.g. "foowire". Used to name the actionqueue function.
-- fct: The update function with parameters function(pos, node)
function mesecon.register_autoconnect_hook(name, fct)
	mesecon.autoconnect_hooks[name] = fct
	mesecon.queue:add_function("autoconnect_hook_"..name, fct)
end

function mesecon.execute_autoconnect_hooks_now(pos, node)
	for _, fct in pairs(mesecon.autoconnect_hooks) do
		fct(pos, node)
	end
end

function mesecon.execute_autoconnect_hooks_queue(pos, node)
	for name in pairs(mesecon.autoconnect_hooks) do
		mesecon.queue:add_action(pos, "autoconnect_hook_"..name, {node})
	end
end
