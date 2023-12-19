
-- a simple first-in-first-out queue
-- very similar to the one in https://github.com/minetest/minetest/pull/7683

local fifo_queue = {}

local metatable = {__index = fifo_queue}

-- creates a new empty queue
function fifo_queue.new()
	local q = {n_in = 0, n_out = 0, i_out = 1, buf_in = {}, buf_out = {}}
	setmetatable(q, metatable)
	return q
end

-- adds an element to the queue
function fifo_queue.add(self, v)
	local n = self.n_in + 1
	self.n_in = n
	self.buf_in[n] = v
end

-- table.move is not available in some lua versions, provide a fallback implementaion
if table.move ~= nil then
	-- add several elements to the queue
	function fifo_queue.add_list(self, v)
		table.move(v, 1, #v, self.n_in + 1, self.buf_in)
		self.n_in = self.n_in + #v
	end
else
	function fifo_queue.add_list(self, v)
		for _, elem in ipairs(v) do
			self:add(elem)
		end
	end
end
-- removes and returns the next element, or nil of empty
function fifo_queue.take(self)
	local i_out = self.i_out
	if i_out <= self.n_out then
		local v = self.buf_out[i_out]
		self.i_out = i_out + 1
		self.buf_out[i_out] = true
		return v
	end

	-- buf_out is empty, try to swap
	self.i_out = 1
	self.n_out = 0
	if self.n_in == 0 then
		return nil -- empty
	end

	-- swap
	self.n_out = self.n_in
	self.n_in = 0
	self.buf_out, self.buf_in = self.buf_in, self.buf_out

	local v = self.buf_out[1]
	self.i_out = 2
	self.buf_out[1] = true
	return v
end

-- returns whether the queue is empty
function fifo_queue.is_empty(self)
	return self.n_out == self.i_out + 1 and self.n_in == 0
end

-- returns stuff for iteration in a for loop, like pairs
-- adding new elements while iterating is no problem
function fifo_queue.iter(self)
	return fifo_queue.take, self, nil
end

return fifo_queue
