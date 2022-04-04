mineunit("protection")

fixture("mesecons")

mineunit:set_current_modname("mesecons_mvps")
mineunit:set_modpath("mesecons_mvps", "../mesecons_mvps")
sourcefile("../mesecons_mvps/init")

minetest.register_node("mesecons_mvps:test_stopper", {
	description = "Test Stopper",
})
mesecon.register_mvps_stopper("mesecons_mvps:test_stopper")

minetest.register_node("mesecons_mvps:test_stopper_cond", {
	description = "Test Stopper (Conditional)",
})
mesecon.register_mvps_stopper("mesecons_mvps:test_stopper_cond", function(node)
	return node.param2 == 0
end)

minetest.register_node("mesecons_mvps:test_sticky", {
	description = "Test Sticky",
	mvps_sticky = function(pos)
		local connected = {}
		for i, rule in ipairs(mesecon.rules.alldirs) do
			connected[i] = vector.add(pos, rule)
		end
		return connected
	end,
})

mesecon._test_moves = {}
minetest.register_node("mesecons_mvps:test_on_move", {
	description = "Test Moveable",
	mesecon = {
		on_mvps_move = function(pos, _, oldpos, meta)
			table.insert(mesecon._test_moves, {pos, oldpos, meta})
		end
	},
})
local old_reset = mesecon._test_reset
function mesecon._test_reset()
	mesecon._test_moves = {}
	old_reset()
end
