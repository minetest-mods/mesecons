-- Dig and place services

mesecon.on_placenode = function (pos, node)
	mesecon.update_autoconnect(pos, node)

	-- Receptors: Send on signal when active
	if mesecon.is_receptor_on(node.name) then
		mesecon.receptor_on(pos, mesecon.receptor_get_rules(node))
	end

	-- Conductors: Send turnon signal when powered or replace by respective offstate conductor
	-- if placed conductor is an onstate one
	if mesecon.is_conductor(node.name) then
		local sources = mesecon.is_powered(pos)
		if sources then
			-- also call receptor_on if itself is powered already, so that neighboring
			-- conductors will be activated (when pushing an on-conductor with a piston)
			for _, s in ipairs(sources) do
				local rule = {x = pos.x - s.x, y = pos.y - s.y, z = pos.z - s.z}
				mesecon.turnon(pos, rule)
			end
			--mesecon.receptor_on (pos, mesecon.conductor_get_rules(node))
		elseif mesecon.is_conductor_on(node) then
			minetest.swap_node(pos, {name = mesecon.get_conductor_off(node)})
		end
	end

	-- Effectors: Send changesignal and activate or deactivate
	if mesecon.is_effector(node.name) then
		local powered_rules = {}
		local unpowered_rules = {}

		-- for each input rule, check if powered
		for _, r in ipairs(mesecon.effector_get_rules(node)) do
			local powered = mesecon.is_powered(pos, r)
			if powered then table.insert(powered_rules, r)
			else table.insert(unpowered_rules, r) end

			local state = powered and mesecon.state.on or mesecon.state.off
			mesecon.changesignal(pos, node, r, state, 1)
		end

		if (#powered_rules > 0) then
			for _, r in ipairs(powered_rules) do
				mesecon.activate(pos, node, r, 1)
			end
		else
			for _, r in ipairs(unpowered_rules) do
				mesecon.deactivate(pos, node, r, 1)
			end
		end
	end
end

mesecon.on_dignode = function (pos, node)
	if mesecon.is_conductor_on(node) then
		mesecon.receptor_off(pos, mesecon.conductor_get_rules(node))
	elseif mesecon.is_receptor_on(node.name) then
		mesecon.receptor_off(pos, mesecon.receptor_get_rules(node))
	end
	mesecon.queue:add_action(pos, "update_autoconnect", {node})
end

mesecon.queue:add_function("update_autoconnect", mesecon.update_autoconnect)

minetest.register_on_placenode(mesecon.on_placenode)
minetest.register_on_dignode(mesecon.on_dignode)

-- Overheating service for fast circuits

-- returns true if heat is too high
mesecon.do_overheat = function(pos)
	local meta = minetest.get_meta(pos)
	local heat = meta:get_int("heat") or 0

	heat = heat + 1
	meta:set_int("heat", heat)

	if heat < mesecon.setting("overheat_max", 20) then
		mesecon.queue:add_action(pos, "cooldown", {}, 1, nil, 0)
	else
		return true
	end

	return false
end


mesecon.queue:add_function("cooldown", function (pos)
	if minetest.get_item_group(minetest.get_node(pos).name, "overheat") == 0 then
		return -- node has been moved, this one does not use overheating - ignore
	end

	local meta = minetest.get_meta(pos)
	local heat = meta:get_int("heat")

	if (heat > 0) then
		meta:set_int("heat", heat - 1)
	end
end)
