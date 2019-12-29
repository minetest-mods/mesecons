--[[
Mesecons uses something it calls an ActionQueue.

The ActionQueue holds functions and actions.
Functions are added on load time with a specified name.
Actions are preserved over server restarts.

Each action consists of a position, the name of an added function to be called,
the params that should be used in this function call (additionally to the pos),
the time after which it should be executed, an optional overwritecheck and a
priority.

If time = 0, the action will be executed in the next globalstep, otherwise the
earliest globalstep when it will be executed is the after next globalstep.

It is guaranteed, that for two actions ac1, ac2 where ac1 ~= ac2,
ac1.time == ac2.time, ac1.priority == ac2.priority and ac1 was added earlier
than ac2, ac1 will be executed before ac2 (but in the same globalstep).

Note: Do not pass references in params, as they can not be preserved.

Also note: Some of the guarantees here might be dropped at some time.
]]


-- localize for speed
local queue = mesecon.queue

queue.actions = {} -- contains all ActionQueue actions

function queue:add_function(name, func)
	queue.funcs[name] = func
end

-- If add_action with twice the same overwritecheck and same position are called, the first one is overwritten
-- use overwritecheck nil to never overwrite, but just add the event to the queue
-- priority specifies the order actions are executed within one globalstep, highest first
-- should be between 0 and 1
function queue:add_action(pos, func, params, time, overwritecheck, priority)
	-- Create Action Table:
	time = time or 0 -- time <= 0 --> execute, time > 0 --> wait time until execution
	priority = priority or 1
	local action = {
		pos = mesecon.tablecopy(pos),
		func = func,
		params = mesecon.tablecopy(params or {}),
		time = time,
		owcheck = (overwritecheck and mesecon.tablecopy(overwritecheck)) or nil,
		priority = priority
	}

	 -- check if old action has to be overwritten / removed:
	if overwritecheck then
		for i, ac in ipairs(queue.actions) do
			if vector.equals(pos, ac.pos)
					and mesecon.cmpAny(overwritecheck, ac.owcheck) then
				-- remove the old action
				table.remove(queue.actions, i)
				break
			end
		end
	end

	table.insert(queue.actions, action)
end

-- execute the stored functions on a globalstep
-- if however, the pos of a function is not loaded (get_node_or_nil == nil), do NOT execute the function
-- this makes sure that resuming mesecons circuits when restarting minetest works fine (hm, where do we do this?)
-- However, even that does not work in some cases, that's why we delay the time the globalsteps
-- start to be execute by 4 seconds

local function globalstep_func(dtime)
	local actions = queue.actions
	-- split into two categories:
	-- actions_now: actions to execute now
	-- queue.actions: actions to execute later
	local actions_now = {}
	queue.actions = {}

	for _, ac in ipairs(actions) do
		if ac.time > 0 then
			-- action ac is to be executed later
			-- ~> insert into queue.actions
			ac.time = ac.time - dtime
			table.insert(queue.actions, ac)
		else
			-- action ac is to be executed now
			-- ~> insert into actions_now
			table.insert(actions_now, ac)
		end
	end

	-- stable-sort the executed actions after their priority
	-- some constructions might depend on the execution order, hence we first
	-- execute the actions that had a lower index in actions_now
	local old_action_order = {}
	for i, ac in ipairs(actions_now) do
		old_action_order[ac] = i
	end
	table.sort(actions_now, function(ac1, ac2)
		if ac1.priority ~= ac2.priority then
			return ac1.priority > ac2.priority
		else
			return old_action_order[ac1] < old_action_order[ac2]
		end
	end)

	-- execute highest priorities first, until all are executed
	for _, ac in ipairs(actions_now) do
		queue:execute(ac)
	end
end

-- delay the time the globalsteps start to be execute by 4 seconds
do
	local m_time = 0
	local resumetime = mesecon.setting("resumetime", 4)
	local globalstep_func_index = #minetest.registered_globalsteps + 1

	minetest.register_globalstep(function(dtime)
		m_time = m_time + dtime
		-- don't even try if server has not been running for XY seconds; resumetime = time to wait
		-- after starting the server before processing the ActionQueue, don't set this too low
		if m_time < resumetime then
			return
		end
		-- replace this globalstep function
		minetest.registered_globalsteps[globalstep_func_index] = globalstep_func
	end)
end

function queue:execute(action)
	-- ignore if action queue function name doesn't exist,
	-- (e.g. in case the action queue savegame was written by an old mesecons version)
	if queue.funcs[action.func] then
		queue.funcs[action.func](action.pos, unpack(action.params))
	end
end


-- Store and read the ActionQueue to / from a file
-- so that upcoming actions are remembered when the game
-- is restarted
queue.actions = mesecon.file2table("mesecon_actionqueue")

minetest.register_on_shutdown(function()
	mesecon.table2file("mesecon_actionqueue", queue.actions)
end)
