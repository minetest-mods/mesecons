
local lg = {}

local operations = {
	-- table index: Index in the formspec dropdown
	-- gate:    Internal name
	-- short:   Serialized form, single character
	-- fs_name: Display name, padded to 4 characters
	-- func:    Function that returns a string representing the operation
	-- unary:   Whether this gate only has one input
	{ gate = "and",  short = "&", fs_name = " AND", func = function(a, b) return ("%s and %s"):format(a, b) end },
	{ gate = "or",   short = "|", fs_name = "  OR", func = function(a, b) return ("%s or %s"):format(a, b) end },
	{ gate = "not",  short = "~", fs_name = " NOT", func = function(_, b) return ("not %s"):format(b) end, unary = true },
	{ gate = "xor",  short = "^", fs_name = " XOR", func = function(a, b) return ("%s~=%s"):format(a, b) end },
	{ gate = "nand", short = "?", fs_name = "NAND", func = function(a, b) return ("not(%s and %s)"):format(a, b) end },
	{ gate = "buf",  short = "_", fs_name = "   =", func = function(_, b) return b end, unary = true },
	{ gate = "xnor", short = "=", fs_name = "XNOR", func = function(a, b) return ("%s==%s"):format(a, b) end },
	{ gate = "nor",  short = "!", fs_name = " NOR", func = function(a, b) return ("not(%s or %s)"):format(a, b) end },
}

lg.get_operations = function()
	return operations
end

-- (de)serialize
lg.serialize = function(t)
	local function _op(t)
		if t == nil then
			return " "
		elseif t.type == "io" then
			return t.port
		else -- t.type == "reg"
			return tostring(t.n)
		end
	end
	-- Serialize actions (gates) from eg. "and" to "&"
	local function _action(action)
		for i, data in ipairs(operations) do
			if data.gate == action then
				return data.short
			end
		end
		return " "
	end

	local s = ""
	for i = 1, 14 do
		local cur = t[i]
		if next(cur) ~= nil then
			s = s .. _op(cur.op1) .. _action(cur.action) .. _op(cur.op2) .. _op(cur.dst)
		end
		s = s .. "/"
	end
	return s
end

lg.deserialize = function(s)
	local function _op(c)
		if c == "A" or c == "B" or c == "C" or c == "D" then
			return {type = "io", port = c}
		elseif c == " " then
			return nil
		else
			return {type = "reg", n = tonumber(c)}
		end
	end
	-- Deserialize actions (gates) from eg. "&" to "and"
	local function _action(action)
		for i, data in ipairs(operations) do
			if data.short == action then
				return data.gate
			end
		end
		-- nil
	end

	local ret = {}
	for part in s:gmatch("(.-)/") do
		local parsed
		if part == "" then
			parsed = {}
		else
			parsed = {
				action = _action( part:sub(2,2) ),
				op1 = _op( part:sub(1,1) ),
				op2 = _op( part:sub(3,3) ),
				dst = _op( part:sub(4,4) ),
			}
		end
		ret[#ret + 1] = parsed
	end
	-- More than 14 instructions (write to all 10 regs + 4 outputs)
	-- will not pass the write-once requirement of the validator
	assert(#ret == 14)
	return ret
end

-- validation
lg.validate_single = function(t, i)
	local function is_reg_written_to(t, n, max)
		for i = 1, max-1 do
			if next(t[i]) ~= nil
					and t[i].dst and t[i].dst.type == "reg"
					and t[i].dst.n == n then
				return true
			end
		end
		return false
	end
	local function compare_op(t1, t2, allow_same_io)
		if t1 == nil or t2 == nil then
			return false
		elseif t1.type ~= t2.type then
			return false
		end
		if t1.type == "reg" and t1.n == t2.n then
			return true
		elseif t1.type == "io" and t1.port == t2.port then
			return not allow_same_io
		end
		return false
	end
	local elem = t[i]

	local gate_data
	for j, data in ipairs(operations) do
		if data.gate == elem.action then
			gate_data = data
			break
		end
	end

	-- check for completeness
	if not gate_data then
		return {i = i, msg = "Gate type is required"}
	elseif gate_data.unary then
		if elem.op1 ~= nil or elem.op2 == nil or elem.dst == nil then
			return {i = i, msg = "Second operand (only) and destination are required"}
		end
	else
		if elem.op1 == nil or elem.op2 == nil or elem.dst == nil then
			return {i = i, msg = "Operands and destination are required"}
		end
	end
	-- check whether operands/destination are identical
	if compare_op(elem.op1, elem.op2) then
		return {i = i, msg = "Operands cannot be identical"}
	end
	if compare_op(elem.op1, elem.dst, true) or compare_op(elem.op2, elem.dst, true) then
		return {i = i, msg = "Destination and operands must be different"}
	end
	-- check whether operands point to defined registers
	if elem.op1 ~= nil and elem.op1.type == "reg"
			and not is_reg_written_to(t, elem.op1.n, i) then
		return {i = i, msg = "First operand is undefined register"}
	end
	if elem.op2.type == "reg" and not is_reg_written_to(t, elem.op2.n, i) then
		return {i = i, msg = "Second operand is undefined register"}
	end
	-- check whether destination points to undefined register
	if elem.dst.type == "reg" and is_reg_written_to(t, elem.dst.n, i) then
		return {i = i, msg = "Destination is already used register"}
	end

	return nil
end

lg.validate = function(t)
	for i = 1, 14 do
		if next(t[i]) ~= nil then
			local r = lg.validate_single(t, i)
			if r ~= nil then
				return r
			end
		end
	end
	return nil
end

local fpga_env = setmetatable({}, {
	__index = function(_, var)
		error("FPGA code tried to read undeclared variable " .. var)
	end,
	__newindex = function(_, var)
		error("FPGA code tried to set undeclared variable " .. var)
	end,
})

-- compiler
lg.compile = function(t)
	-- Get token generation function from action gate string
	local function _action(s)
		for i, data in ipairs(operations) do
			if data.gate == s then
				return data.func
			end
		end
		return nil -- unknown gate
	end
	-- Serialize input operand
	local function _op(t)
		if t == nil then
			return nil
		elseif t.type == "reg" then
			return "r" .. t.n
		else -- t.type == "io"
			return "i" .. t.port
		end
	end
	-- Serialize destination
	local function _dst(t)
		if t.type == "reg" then
			return "local r" .. t.n
		else -- t.type == "io"
			return "o" .. t.port
		end
	end

	local code = {
		-- Declare inputs and outputs:
		"return function(iA,iB,iC,iD)local oA,oB,oC,oD;",
	}
	for i = 1, 14 do
		local cur = t[i]
		if next(cur) ~= nil then
			table.insert(code, _dst(cur.dst))
			table.insert(code, "=")
			table.insert(code, _action(cur.action)(_op(cur.op1), _op(cur.op2)))
			table.insert(code, ";")
		end
	end
	table.insert(code, "return oA,oB,oC,oD;end")

	local func = assert(loadstring(table.concat(code)))()
	setfenv(func, fpga_env)
	return func
end

return lg
