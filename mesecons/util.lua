function mesecon.move_node(pos, newpos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos):to_table()
	minetest.remove_node(pos)
	minetest.add_node(newpos, node)
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
		if mesecon.cmpPos(findrule, rule) then
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
		if mesecon.cmpPos(findrule, rule) then
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
	return {x = -r.x, y = -r.y, z = -r.z}
end

function mesecon.addPosRule(p, r)
	return {x = p.x + r.x, y = p.y + r.y, z = p.z + r.z}
end

function mesecon.cmpPos(p1, p2)
	return (p1.x == p2.x and p1.y == p2.y and p1.z == p2.z)
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
