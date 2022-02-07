-- Internal.lua - The core of mesecons
--
-- For more practical developer resources see http://mesecons.net/developers.php
--
-- Function overview
-- mesecon.get_effector(nodename)	--> Returns the mesecons.effector -specifictation in the nodedef by the nodename
-- mesecon.get_receptor(nodename)	--> Returns the mesecons.receptor -specifictation in the nodedef by the nodename
-- mesecon.get_conductor(nodename)	--> Returns the mesecons.conductor-specifictation in the nodedef by the nodename
-- mesecon.get_any_inputrules (node)	--> Returns the rules of a node if it is a conductor or an effector
-- mesecon.get_any_outputrules (node)	--> Returns the rules of a node if it is a conductor or a receptor

-- RECEPTORS
-- mesecon.is_receptor(nodename)	--> Returns true if nodename is a receptor
-- mesecon.is_receptor_on(nodename)	--> Returns true if nodename is an receptor with state = mesecon.state.on
-- mesecon.is_receptor_off(nodename)	--> Returns true if nodename is an receptor with state = mesecon.state.off
-- mesecon.receptor_get_rules(node)	--> Returns the rules of the receptor (mesecon.rules.default if none specified)

-- EFFECTORS
-- mesecon.is_effector(nodename)	--> Returns true if nodename is an effector
-- mesecon.is_effector_on(nodename)	--> Returns true if nodename is an effector with nodedef.mesecons.effector.action_off
-- mesecon.is_effector_off(nodename)	--> Returns true if nodename is an effector with nodedef.mesecons.effector.action_on
-- mesecon.effector_get_rules(node)	--> Returns the input rules of the effector (mesecon.rules.default if none specified)

-- SIGNALS
-- mesecon.activate(pos, node, depth)				--> Activates   the effector node at the specific pos (calls nodedef.mesecons.effector.action_on), higher depths are executed later
-- mesecon.deactivate(pos, node, depth)				--> Deactivates the effector node at the specific pos (calls nodedef.mesecons.effector.action_off), higher depths are executed later
-- mesecon.changesignal(pos, node, rulename, newstate, depth)	--> Changes     the effector node at the specific pos (calls nodedef.mesecons.effector.action_change), higher depths are executed later

-- CONDUCTORS
-- mesecon.is_conductor(nodename)	--> Returns true if nodename is a conductor
-- mesecon.is_conductor_on(node		--> Returns true if node is a conductor with state = mesecon.state.on
-- mesecon.is_conductor_off(node)	--> Returns true if node is a conductor with state = mesecon.state.off
-- mesecon.get_conductor_on(node_off)	--> Returns the onstate  nodename of the conductor
-- mesecon.get_conductor_off(node_on)	--> Returns the offstate nodename of the conductor
-- mesecon.conductor_get_rules(node)	--> Returns the input+output rules of a conductor (mesecon.rules.default if none specified)

-- HIGH-LEVEL Internals
-- mesecon.is_power_on(pos)				--> Returns true if pos emits power in any way
-- mesecon.is_power_off(pos)				--> Returns true if pos does not emit power in any way
-- mesecon.is_powered(pos)				--> Returns true if pos is powered by a receptor or a conductor

-- RULES ROTATION helpers
-- mesecon.rotate_rules_right(rules)
-- mesecon.rotate_rules_left(rules)
-- mesecon.rotate_rules_up(rules)
-- mesecon.rotate_rules_down(rules)
-- These functions return rules that have been rotated in the specific direction

local fifo_queue = dofile(minetest.get_modpath("mesecons").."/fifo_queue.lua")

-- General
function mesecon.get_effector(nodename)
	if  minetest.registered_nodes[nodename]
	and minetest.registered_nodes[nodename].mesecons
	and minetest.registered_nodes[nodename].mesecons.effector then
		return minetest.registered_nodes[nodename].mesecons.effector
	end
end

function mesecon.get_receptor(nodename)
	if  minetest.registered_nodes[nodename]
	and minetest.registered_nodes[nodename].mesecons
	and minetest.registered_nodes[nodename].mesecons.receptor then
		return minetest.registered_nodes[nodename].mesecons.receptor
	end
end

function mesecon.get_conductor(nodename)
	if  minetest.registered_nodes[nodename]
	and minetest.registered_nodes[nodename].mesecons
	and minetest.registered_nodes[nodename].mesecons.conductor then
		return minetest.registered_nodes[nodename].mesecons.conductor
	end
end

function mesecon.get_any_outputrules(node)
	if not node then return nil end

	if mesecon.is_conductor(node.name) then
		return mesecon.conductor_get_rules(node)
	elseif mesecon.is_receptor(node.name) then
		return mesecon.receptor_get_rules(node)
	end
end

function mesecon.get_any_inputrules(node)
	if not node then return nil end

	if mesecon.is_conductor(node.name) then
		return mesecon.conductor_get_rules(node)
	elseif mesecon.is_effector(node.name) then
		return mesecon.effector_get_rules(node)
	end
end

function mesecon.get_any_rules(node)
	return mesecon.merge_rule_sets(mesecon.get_any_inputrules(node),
		mesecon.get_any_outputrules(node))
end

-- Receptors
-- Nodes that can power mesecons
function mesecon.is_receptor_on(nodename)
	local receptor = mesecon.get_receptor(nodename)
	if receptor and receptor.state == mesecon.state.on then
		return true
	end
	return false
end

function mesecon.is_receptor_off(nodename)
	local receptor = mesecon.get_receptor(nodename)
	if receptor and receptor.state == mesecon.state.off then
		return true
	end
	return false
end

function mesecon.is_receptor(nodename)
	local receptor = mesecon.get_receptor(nodename)
	if receptor then
		return true
	end
	return false
end

function mesecon.receptor_get_rules(node)
	local receptor = mesecon.get_receptor(node.name)
	if receptor then
		local rules = receptor.rules
		if type(rules) == 'function' then
			return rules(node)
		elseif rules then
			return rules
		end
	end

	return mesecon.rules.default
end

-- Effectors
-- Nodes that can be powered by mesecons
function mesecon.is_effector_on(nodename)
	local effector = mesecon.get_effector(nodename)
	if effector and effector.action_off then
		return true
	end
	return false
end

function mesecon.is_effector_off(nodename)
	local effector = mesecon.get_effector(nodename)
	if effector and effector.action_on then
		return true
	end
	return false
end

function mesecon.is_effector(nodename)
	local effector = mesecon.get_effector(nodename)
	if effector then
		return true
	end
	return false
end

function mesecon.effector_get_rules(node)
	local effector = mesecon.get_effector(node.name)
	if effector then
		local rules = effector.rules
		if type(rules) == 'function' then
			return rules(node)
		elseif rules then
			return rules
		end
	end
	return mesecon.rules.default
end

-- #######################
-- # Signals (effectors) #
-- #######################

-- Activation:
mesecon.queue:add_function("activate", function (pos, rulename)
	local node = mesecon.get_node_force(pos)
	if not node then return end

	local effector = mesecon.get_effector(node.name)

	if effector and effector.action_on then
		effector.action_on(pos, node, rulename)
	end
end)

function mesecon.activate(pos, node, rulename, depth)
	if rulename == nil then
		for _,rule in ipairs(mesecon.effector_get_rules(node)) do
			mesecon.activate(pos, node, rule, depth + 1)
		end
		return
	end
	mesecon.queue:add_action(pos, "activate", {rulename}, nil, rulename, 1 / depth)
end


-- Deactivation
mesecon.queue:add_function("deactivate", function (pos, rulename)
	local node = mesecon.get_node_force(pos)
	if not node then return end

	local effector = mesecon.get_effector(node.name)

	if effector and effector.action_off then
		effector.action_off(pos, node, rulename)
	end
end)

function mesecon.deactivate(pos, node, rulename, depth)
	if rulename == nil then
		for _,rule in ipairs(mesecon.effector_get_rules(node)) do
			mesecon.deactivate(pos, node, rule, depth + 1)
		end
		return
	end
	mesecon.queue:add_action(pos, "deactivate", {rulename}, nil, rulename, 1 / depth)
end


-- Change
mesecon.queue:add_function("change", function (pos, rulename, changetype)
	local node = mesecon.get_node_force(pos)
	if not node then return end

	local effector = mesecon.get_effector(node.name)

	if effector and effector.action_change then
		effector.action_change(pos, node, rulename, changetype)
	end
end)

function mesecon.changesignal(pos, node, rulename, newstate, depth)
	if rulename == nil then
		for _,rule in ipairs(mesecon.effector_get_rules(node)) do
			mesecon.changesignal(pos, node, rule, newstate, depth + 1)
		end
		return
	end

	-- Include "change" in overwritecheck so that it cannot be overwritten
	-- by "active" / "deactivate" that will be called upon the node at the same time.
	local overwritecheck = {"change", rulename}
	mesecon.queue:add_action(pos, "change", {rulename, newstate}, nil, overwritecheck, 1 / depth)
end

-- Conductors

function mesecon.is_conductor_on(node, rulename)
	if not node then return false end

	local conductor = mesecon.get_conductor(node.name)
	if conductor then
		if conductor.state then
			return conductor.state == mesecon.state.on
		end
		if conductor.states then
			if not rulename then
				return mesecon.getstate(node.name, conductor.states) ~= 1
			end
			local bit = mesecon.rule2bit(rulename, mesecon.conductor_get_rules(node))
			local binstate = mesecon.getbinstate(node.name, conductor.states)
			return mesecon.get_bit(binstate, bit)
		end
	end

	return false
end

function mesecon.is_conductor_off(node, rulename)
	if not node then return false end

	local conductor = mesecon.get_conductor(node.name)
	if conductor then
		if conductor.state then
			return conductor.state == mesecon.state.off
		end
		if conductor.states then
			if not rulename then
				return mesecon.getstate(node.name, conductor.states) == 1
			end
			local bit = mesecon.rule2bit(rulename, mesecon.conductor_get_rules(node))
			local binstate = mesecon.getbinstate(node.name, conductor.states)
			return not mesecon.get_bit(binstate, bit)
		end
	end

	return false
end

function mesecon.is_conductor(nodename)
	local conductor = mesecon.get_conductor(nodename)
	if conductor then
		return true
	end
	return false
end

function mesecon.get_conductor_on(node_off, rulename)
	local conductor = mesecon.get_conductor(node_off.name)
	if conductor then
		if conductor.onstate then
			return conductor.onstate
		end
		if conductor.states then
			local bit = mesecon.rule2bit(rulename, mesecon.conductor_get_rules(node_off))
			local binstate = mesecon.getbinstate(node_off.name, conductor.states)
			binstate = mesecon.set_bit(binstate, bit, "1")
			return conductor.states[tonumber(binstate,2)+1]
		end
	end
	return nil
end

function mesecon.get_conductor_off(node_on, rulename)
	local conductor = mesecon.get_conductor(node_on.name)
	if conductor then
		if conductor.offstate then
			return conductor.offstate
		end
		if conductor.states then
			local bit = mesecon.rule2bit(rulename, mesecon.conductor_get_rules(node_on))
			local binstate = mesecon.getbinstate(node_on.name, conductor.states)
			binstate = mesecon.set_bit(binstate, bit, "0")
			return conductor.states[tonumber(binstate,2)+1]
		end
	end
	return nil
end

function mesecon.conductor_get_rules(node)
	local conductor = mesecon.get_conductor(node.name)
	if conductor then
		local rules = conductor.rules
		if type(rules) == 'function' then
			return rules(node)
		elseif rules then
			return rules
		end
	end
	return mesecon.rules.default
end

-- some more general high-level stuff

function mesecon.is_power_on(pos, rulename)
	local node = mesecon.get_node_force(pos)
	if node and (mesecon.is_conductor_on(node, rulename) or mesecon.is_receptor_on(node.name)) then
		return true
	end
	return false
end

function mesecon.is_power_off(pos, rulename)
	local node = mesecon.get_node_force(pos)
	if node and (mesecon.is_conductor_off(node, rulename) or mesecon.is_receptor_off(node.name)) then
		return true
	end
	return false
end

-- The set of conductor states which require light updates when they change.
local light_update_conductors

-- Calculate the contents of the above set if they have not been calculated.
local function find_light_update_conductors()
	-- The expensive calculation is only done the first time.
	if light_update_conductors then return end

	light_update_conductors = {}

	-- Find conductors whose lighting characteristics change depending on their state.
	local checked = {}
	for name, def in pairs(minetest.registered_nodes) do
		local conductor = mesecon.get_conductor(name)
		if conductor and not checked[name] then
			-- Find the other states of the conductor besides the current one.
			local other_states
			if conductor.onstate then
				other_states = {conductor.onstate}
			elseif conductor.offstate then
				other_states = {conductor.offstate}
			else
				other_states = conductor.states
			end

			-- Check the conductor. Other states are marked as checked.
			for _, other_state in ipairs(other_states) do
				local other_def = minetest.registered_nodes[other_state]
				if (def.paramtype == "light") ~= (other_def.paramtype == "light")
				or def.sunlight_propagates ~= other_def.sunlight_propagates
				or def.light_source ~= other_def.light_source then
					-- The light characteristics change depending on the state.
					-- The states are added to the set.
					light_update_conductors[name] = true
					for _, other_state in ipairs(other_states) do
						light_update_conductors[other_state] = true
						checked[other_state] = true
					end
					break
				end
				checked[other_state] = true
			end
		end
	end
end

-- Turn off an equipotential section starting at `pos`, which outputs in the direction of `link`.
-- Breadth-first search. Map is abstracted away in a voxelmanip.
-- Follow all all conductor paths replacing conductors that were already
-- looked at, activating / changing all effectors along the way.
function mesecon.turnon(pos, link)
	find_light_update_conductors()

	local frontiers = fifo_queue.new()
	frontiers:add({pos = pos, link = link})
	local pos_can_be_skipped = {}

	local depth = 1
	for f in frontiers:iter() do
		local node = mesecon.get_node_force(f.pos)

		if not node then
			-- Area does not exist; do nothing
			pos_can_be_skipped[minetest.hash_node_position(f.pos)] = true
		elseif mesecon.is_conductor(node.name) then
			local rules = mesecon.conductor_get_rules(node)

			if mesecon.is_conductor_off(node, f.link) then
				-- Call turnon on neighbors
				for _, r in ipairs(mesecon.rule2meta(f.link, rules)) do
					local np = vector.add(f.pos, r)
					if not pos_can_be_skipped[minetest.hash_node_position(np)] then
						for _, l in ipairs(mesecon.rules_link_rule_all(f.pos, r)) do
							frontiers:add({pos = np, link = l})
						end
					end
				end

				mesecon.swap_node_force(f.pos, mesecon.get_conductor_on(node, f.link), light_update_conductors[node.name] ~= nil)
			end

			-- Only conductors with flat rules can be reliably skipped later
			if not rules[1] or rules[1].x then
				pos_can_be_skipped[minetest.hash_node_position(f.pos)] = true
			end
		elseif mesecon.is_effector(node.name) then
			mesecon.changesignal(f.pos, node, f.link, mesecon.state.on, depth)
			if mesecon.is_effector_off(node.name) then
				mesecon.activate(f.pos, node, f.link, depth)
			end
		else
			pos_can_be_skipped[minetest.hash_node_position(f.pos)] = true
		end
		depth = depth + 1
	end
end

-- Turn on an equipotential section starting at `pos`, which outputs in the direction of `link`.
-- Breadth-first search. Map is abstracted away in a voxelmanip.
-- Follow all all conductor paths replacing conductors that were already
-- looked at, deactivating / changing all effectors along the way.
-- In case an onstate receptor is discovered, abort the process by returning false, which will
-- cause `receptor_off` to discard all changes made in the voxelmanip.
-- Contrary to turnon, turnoff has to cache all change and deactivate signals so that they will only
-- be called in the very end when we can be sure that no conductor was found along the path.
--
-- Signal table entry structure:
-- {
--	pos = position of effector,
--	node = node descriptor (name, param1 and param2),
--	link = link the effector is connected to,
--	depth = indicates order in which signals wire fired, higher is later
-- }
function mesecon.turnoff(pos, link)
	find_light_update_conductors()

	local frontiers = fifo_queue.new()
	frontiers:add({pos = pos, link = link})
	local signals = {}
	local pos_can_be_skipped = {}

	local depth = 1
	for f in frontiers:iter() do
		local node = mesecon.get_node_force(f.pos)

		if not node then
			-- Area does not exist; do nothing
			pos_can_be_skipped[minetest.hash_node_position(f.pos)] = true
		elseif mesecon.is_conductor(node.name) then
			local rules = mesecon.conductor_get_rules(node)

			if mesecon.is_conductor_on(node, f.link) then
				for _, r in ipairs(mesecon.rule2meta(f.link, rules)) do
					local np = vector.add(f.pos, r)

					if not pos_can_be_skipped[minetest.hash_node_position(np)] then
						-- Check if an onstate receptor is connected. If that is the case,
						-- abort this turnoff process by returning false. `receptor_off` will
						-- discard all the changes that we made in the voxelmanip:
						if mesecon.rules_link_rule_all_inverted(f.pos, r)[1] then
							if mesecon.is_receptor_on(mesecon.get_node_force(np).name) then
								return false
							end
						end

						-- Call turnoff on neighbors
						for _, l in ipairs(mesecon.rules_link_rule_all(f.pos, r)) do
							frontiers:add({pos = np, link = l})
						end
					end
				end

				mesecon.swap_node_force(f.pos, mesecon.get_conductor_off(node, f.link), light_update_conductors[node.name] ~= nil)
			end

			-- Only conductors with flat rules can be reliably skipped later
			if not rules[1] or rules[1].x then
				pos_can_be_skipped[minetest.hash_node_position(f.pos)] = true
			end
		elseif mesecon.is_effector(node.name) then
			table.insert(signals, {
				pos = f.pos,
				node = node,
				link = f.link,
				depth = depth
			})
		else
			pos_can_be_skipped[minetest.hash_node_position(f.pos)] = true
		end
		depth = depth + 1
	end

	for _, sig in ipairs(signals) do
		mesecon.changesignal(sig.pos, sig.node, sig.link, mesecon.state.off, sig.depth)
		if mesecon.is_effector_on(sig.node.name) and not mesecon.is_powered(sig.pos) then
			mesecon.deactivate(sig.pos, sig.node, sig.link, sig.depth)
		end
	end

	return true
end

-- Get all linking inputrules of inputnode (effector or conductor) that is connected to
-- outputnode (receptor or conductor) at position `output` and has an output in direction `rule`
function mesecon.rules_link_rule_all(output, rule)
	local input = vector.add(output, rule)
	local inputnode = mesecon.get_node_force(input)
	local inputrules = mesecon.get_any_inputrules(inputnode)
	if not inputrules then
		return {}
	end
	local rules = {}

	for _, inputrule in ipairs(mesecon.flattenrules(inputrules)) do
		-- Check if input accepts from output
		if  vector.equals(vector.add(input, inputrule), output) then
			table.insert(rules, inputrule)
		end
	end

	return rules
end

-- Get all linking outputnodes of outputnode (receptor or conductor) that is connected to
-- inputnode (effector or conductor) at position `input` and has an input in direction `rule`
function mesecon.rules_link_rule_all_inverted(input, rule)
	local output = vector.add(input, rule)
	local outputnode = mesecon.get_node_force(output)
	local outputrules = mesecon.get_any_outputrules(outputnode)
	if not outputrules then
		return {}
	end
	local rules = {}

	for _, outputrule in ipairs(mesecon.flattenrules(outputrules)) do
		if  vector.equals(vector.add(output, outputrule), input) then
			table.insert(rules, mesecon.invertRule(outputrule))
		end
	end
	return rules
end

function mesecon.is_powered(pos, rule)
	local node = mesecon.get_node_force(pos)
	local rules = mesecon.get_any_inputrules(node)
	if not rules then return false end

	-- List of nodes that send out power to pos
	local sourcepos = {}

	if not rule then
		for _, rule in ipairs(mesecon.flattenrules(rules)) do
			local rulenames = mesecon.rules_link_rule_all_inverted(pos, rule)
			for _, rname in ipairs(rulenames) do
				local np = vector.add(pos, rname)
				local nn = mesecon.get_node_force(np)

				if (mesecon.is_conductor_on(nn, mesecon.invertRule(rname))
				or mesecon.is_receptor_on(nn.name)) then
					table.insert(sourcepos, np)
				end
			end
		end
	else
		local rulenames = mesecon.rules_link_rule_all_inverted(pos, rule)
		for _, rname in ipairs(rulenames) do
			local np = vector.add(pos, rname)
			local nn = mesecon.get_node_force(np)
			if (mesecon.is_conductor_on (nn, mesecon.invertRule(rname))
			or mesecon.is_receptor_on (nn.name)) then
				table.insert(sourcepos, np)
			end
		end
	end

	-- Return FALSE if not powered, return list of sources if is powered
	if (#sourcepos == 0) then return false
	else return sourcepos end
end
