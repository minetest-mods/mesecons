
local fifo_queue = {}

local metatable = {__index = fifo_queue}

-- creates a new empty queue
function fifo_queue.new()
	local q = {}
	setmetatable(q, metatable)
	return q
end

-- adds an element to the queue
function fifo_queue.add(self, v)
	table.insert(self, v)
end

-- removes and returns the next element, or nil of empty
function fifo_queue.take(self)
	return table.remove(self, 1)
end

-- returns whether the queue is empty
function fifo_queue.is_empty(self)
	return table[1]
end

-- returns stuff for iteration in a for loop, like pairs
-- adding new elements while iterating is no problem
function fifo_queue.iter(self)
	return fifo_queue.take, self, nil
end

return fifo_queue
