function mesecon.move_node(pos, newpos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos):to_table()
	minetest.remove_node(pos)
	minetest.set_node(newpos, node)
	minetest.get_meta(pos):from_table(meta)
end

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
	local c = binary:len()-(bit-1)
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

function mesecon.tablecopy(table) -- deep table copy
	if type(table) ~= "table" then return table end -- no need to copy
	local newtable = {}

	for idx, item in pairs(table) do
		if type(item) == "table" then
			newtable[idx] = mesecon.tablecopy(item)
		else
			newtable[idx] = item
		end
	end

	return newtable
end

function mesecon.cmpAny(t1, t2)
	if type(t1) ~= type(t2) then return false end
	if type(t1) ~= "table" and type(t2) ~= "table" then return t1 == t2 end

	for i, e in pairs(t1) do
		if not mesecon.cmpAny(e, t2[i]) then return false end
	end

	return true
end

-- does not overwrite values; number keys (ipairs) are appended, not overwritten
function mesecon.mergetable(source, dest)
	local rval = mesecon.tablecopy(dest)

	for k, v in pairs(source) do
		rval[k] = dest[k] or mesecon.tablecopy(v)
	end
	for i, v in ipairs(source) do
		table.insert(rval, mesecon.tablecopy(v))
	end

	return rval
end

function mesecon.register_node(name, spec_common, spec_off, spec_on)
	spec_common.drop = spec_common.drop or name .. "_off"
	spec_common.__mesecon_basename = name
	spec_on.__mesecon_state = "on"
	spec_off.__mesecon_state = "off"

	spec_on = mesecon.mergetable(spec_common, spec_on);
	spec_off = mesecon.mergetable(spec_common, spec_off);

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
	local f = io.open(wpath..DIR_DELIM..filename, "r")
	if f == nil then return {} end
	local t = f:read("*all")
	f:close()
	if t == "" or t == nil then return {} end
	return minetest.deserialize(t)
end

function mesecon.table2file(filename, table)
	local f = io.open(wpath..DIR_DELIM..filename, "w")
	f:write(minetest.serialize(table))
	f:close()
end

-- Forceloading: Force server to load area if node is nil
local BLOCKSIZE = 16

-- convert node position --> block hash
local function hash_blockpos(pos)
	return minetest.hash_node_position({
		x = math.floor(pos.x/BLOCKSIZE),
		y = math.floor(pos.y/BLOCKSIZE),
		z = math.floor(pos.z/BLOCKSIZE)
	})
end

-- convert block hash --> node position
local function unhash_blockpos(hash)
	return vector.multiply(minetest.get_position_from_hash(hash), BLOCKSIZE)
end

mesecon.forceloaded_blocks = {}

-- get node and force-load area
function mesecon.get_node_force(pos)
	local hash = hash_blockpos(pos)

	if mesecon.forceloaded_blocks[hash] == nil then
		-- if no more forceload spaces are available, try again next time
		if minetest.forceload_block(pos) then
			mesecon.forceloaded_blocks[hash] = 0
		end
	else
		mesecon.forceloaded_blocks[hash] = 0
	end

	return minetest.get_node_or_nil(pos)
end

minetest.register_globalstep(function (dtime)
	local timeout = mesecon.setting("forceload_timeout", 600)
	for hash, time in pairs(mesecon.forceloaded_blocks) do
		-- unload forceloaded blocks after 10 minutes without usage
		if (time > timeout) then
			minetest.forceload_free_block(unhash_blockpos(hash))
			mesecon.forceloaded_blocks[hash] = nil
		else
			mesecon.forceloaded_blocks[hash] = time + dtime
		end
	end
end)

-- Store and read the forceloaded blocks to / from a file
-- so that those blocks are remembered when the game
-- is restarted
mesecon.forceloaded_blocks = mesecon.file2table("mesecon_forceloaded")
minetest.register_on_shutdown(function()
	mesecon.table2file("mesecon_forceloaded", mesecon.forceloaded_blocks)
end)

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
