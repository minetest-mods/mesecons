require("mineunit")

fixture("mesecons_mvps")

world.set_default_node("air")

describe("node movement", function()
	after_each(function()
		mesecon._test_reset()
		world.clear()
	end)

	it("works with no moved nodes", function()
		local pos = {x = 0, y = 0, z = 0}
		local dir = {x = 1, y = 0, z = 0}

		assert.same({true, {}, {}}, {mesecon.mvps_push(pos, dir, 1, "")})
		assert.same({true, {}, {}}, {mesecon.mvps_pull_all(pos, dir, 1, "")})
		assert.same({true, {}, {}}, {mesecon.mvps_pull_single(pos, dir, 1, "")})
	end)

	it("works with simple stack", function()
		local pos = {x = 0, y = 0, z = 0}
		local dir = {x = 1, y = 0, z = 0}
		world.set_node(pos, "mesecons:test_conductor_off")
		world.set_node(vector.add(pos, dir), "mesecons:test_conductor_off")

		assert.is_true((mesecon.mvps_push(pos, dir, 2, "")))
		assert.equal("air", world.get_node(pos).name)
		assert.equal("mesecons:test_conductor_off", world.get_node(vector.add(pos, dir)).name)
		assert.equal("mesecons:test_conductor_off", world.get_node(vector.add(pos, vector.multiply(dir, 2))).name)

		assert.is_true((mesecon.mvps_pull_all(vector.add(pos, dir), vector.multiply(dir, -1), 2, "")))
		assert.equal("mesecons:test_conductor_off", world.get_node(pos).name)
		assert.equal("mesecons:test_conductor_off", world.get_node(vector.add(pos, dir)).name)
		assert.equal("air", world.get_node(vector.add(pos, vector.multiply(dir, 2))).name)

		assert.is_true((mesecon.mvps_pull_single(pos, vector.multiply(dir, -1), 1, "")))
		assert.equal("mesecons:test_conductor_off", world.get_node(vector.subtract(pos, dir)).name)
		assert.equal("air", world.get_node(pos).name)
		assert.equal("mesecons:test_conductor_off", world.get_node(vector.add(pos, dir)).name)
	end)

	it("works with sticky nodes", function()
		local pos = {x = 0, y = 0, z = 0}
		local dir = {x = 0, y = 1, z = 0}
		world.set_node(pos, "mesecons:test_conductor_off")
		world.set_node(vector.offset(pos, 0, 1, 0), "mesecons_mvps:test_sticky")
		world.set_node(vector.offset(pos, 1, 1, 0), "mesecons:test_conductor_off")
		world.set_node(vector.offset(pos, 1, 2, 0), "mesecons:test_conductor_off")

		assert.is_true((mesecon.mvps_push(pos, dir, 4, "")))
		assert.equal("air", world.get_node(vector.offset(pos, 1, 1, 0)).name)
		assert.equal("mesecons:test_conductor_off", world.get_node(vector.offset(pos, 1, 2, 0)).name)
		assert.equal("mesecons:test_conductor_off", world.get_node(vector.offset(pos, 1, 3, 0)).name)

		assert.is_true((mesecon.mvps_pull_all(vector.add(pos, dir), vector.multiply(dir, -1), 4, "")))
		assert.equal("air", world.get_node(vector.offset(pos, 1, 0, 0)).name)
		assert.equal("mesecons:test_conductor_off", world.get_node(vector.offset(pos, 1, 1, 0)).name)
		assert.equal("mesecons:test_conductor_off", world.get_node(vector.offset(pos, 1, 2, 0)).name)

		assert.is_true((mesecon.mvps_pull_single(pos, vector.multiply(dir, -1), 3, "")))
		assert.equal("air", world.get_node(vector.offset(pos, 1, -1, 0)).name)
		assert.equal("mesecons:test_conductor_off", world.get_node(vector.offset(pos, 1, 0, 0)).name)
		assert.equal("air", world.get_node(vector.offset(pos, 1, 1, 0)).name)
	end)

	it("respects maximum", function()
		local pos = {x = 0, y = 0, z = 0}
		local dir = {x = 1, y = 0, z = 0}
		world.set_node(pos, "mesecons:test_conductor_off")
		world.set_node(vector.add(pos, dir), "mesecons:test_conductor_off")

		assert.is_true(not mesecon.mvps_push(pos, dir, 1, ""))
	end)

	it("is blocked by basic stopper", function()
		local pos = {x = 0, y = 0, z = 0}
		local dir = {x = 1, y = 0, z = 0}
		world.set_node(pos, "mesecons_mvps:test_stopper")

		assert.is_true(not mesecon.mvps_push(pos, dir, 1, ""))
	end)

	it("is blocked by conditional stopper", function()
		local pos = {x = 0, y = 0, z = 0}
		local dir = {x = 1, y = 0, z = 0}

		world.set_node(pos, {name = "mesecons_mvps:test_stopper_cond", param2 = 0})
		assert.is_true(not mesecon.mvps_push(pos, dir, 1, ""))

		world.set_node(pos, {name = "mesecons_mvps:test_stopper_cond", param2 = 1})
		assert.is_true((mesecon.mvps_push(pos, dir, 1, "")))
	end)

	-- TODO: I think this is supposed to work?
	pending("is blocked by ignore", function()
		local pos = {x = 0, y = 0, z = 0}
		local dir = {x = 1, y = 0, z = 0}
		world.set_node(pos, "mesecons:test_conductor_off")
		world.set_node(vector.add(pos, dir), "ignore")

		assert.is_true(not mesecon.mvps_push(pos, dir, 1, ""))
	end)

	it("moves metadata", function()
		local pos = {x = 0, y = 0, z = 0}
		local dir = {x = 1, y = 0, z = 0}
		world.set_node(pos, "mesecons:test_conductor_off")
		minetest.get_meta(pos):set_string("foo", "bar")
		minetest.get_node_timer(pos):set(12, 34)

		mesecon.mvps_push(pos, dir, 1, "")
		assert.equal("bar", minetest.get_meta(vector.add(pos, dir)):get("foo"))
		local moved_timer = minetest.get_node_timer(vector.add(pos, dir))
		assert.equal(12, moved_timer:get_timeout())
		assert.equal(34, moved_timer:get_elapsed())
		moved_timer:stop()
		assert.same({}, minetest.get_meta(pos):to_table().fields)
		assert.is_false(minetest.get_node_timer(pos):is_started())
	end)

	it("calls move callbacks", function()
		local pos = {x = 0, y = 0, z = 0}
		local dir = {x = 1, y = 0, z = 0}
		world.set_node(pos, {name = "mesecons_mvps:test_on_move", param2 = 123})
		minetest.get_meta(pos):set_string("foo", "bar")
		local move_info = {vector.add(pos, dir), world.get_node(pos), pos, minetest.get_meta(pos):to_table()}

		mesecon.mvps_push(pos, dir, 1, "")
		assert.equal(1, #mesecon._test_moves)
		assert.same(move_info, mesecon._test_moves[1])
	end)

	it("executes autoconnect hooks", function()
		local pos = {x = 0, y = 0, z = 0}
		local dir = {x = 1, y = 0, z = 0}
		world.set_node(pos, "mesecons:test_conductor_off")

		mesecon.mvps_push(pos, dir, 1, "")
		mineunit:execute_globalstep() -- Execute delayed autoconnect hook
		assert.equal(2, #mesecon._test_autoconnects)
	end)

	it("updates moved receptors", function()
		local pos1 = {x = 0, y = 0, z = 0}
		local pos2 = vector.offset(pos1, 0, 1, 0)
		local pos3 = vector.offset(pos1, 2, 0, 0)
		local pos4 = vector.offset(pos1, 0, 0, 1)
		local dir = {x = 1, y = 0, z = 0}
		mesecon._test_place(pos1, "mesecons:test_receptor_on")
		mesecon._test_place(pos2, "mesecons:test_conductor_off")
		mesecon._test_place(pos3, "mesecons:test_conductor_off")
		mesecon._test_place(pos4, "mesecons:test_conductor_off")
		mesecon._test_place(vector.add(pos4, dir), "mesecons:test_conductor_off")
		mineunit:execute_globalstep() -- Execute receptor_on action

		mesecon.mvps_push(pos1, dir, 1, "")
		mineunit:execute_globalstep() -- Execute receptor_on/receptor_off actions
		assert.equal("mesecons:test_conductor_off", world.get_node(pos2).name)
		assert.equal("mesecons:test_conductor_on", world.get_node(pos3).name)
		assert.equal("mesecons:test_conductor_on", world.get_node(pos4).name)
	end)

	it("updates moved conductors", function()
		local pos1 = {x = 0, y = 0, z = 0}
		local pos2 = vector.offset(pos1, 0, 1, 0)
		local pos3 = vector.offset(pos1, 0, -1, 0)
		local dir = {x = 1, y = 0, z = 0}
		mesecon._test_place(pos1, "mesecons:test_conductor_off")
		mesecon._test_place(pos2, "mesecons:test_receptor_on")
		mesecon._test_place(pos3, "mesecons:test_conductor_off")
		mineunit:execute_globalstep() -- Execute receptor_on action

		mesecon.mvps_push(pos1, dir, 1, "")
		mineunit:execute_globalstep() -- Execute receptor_off action
		assert.equal("mesecons:test_conductor_off", world.get_node(vector.add(pos1, dir)).name)
		assert.equal("mesecons:test_conductor_off", world.get_node(pos3).name)

		mesecon.mvps_pull_all(vector.add(pos1, dir), vector.multiply(dir, -1), 1, "")
		mineunit:execute_globalstep() -- Execute receptor_on action
		assert.equal("mesecons:test_conductor_on", world.get_node(pos1).name)
		assert.equal("mesecons:test_conductor_on", world.get_node(pos3).name)
	end)

	it("updates moved effectors", function()
		local pos = {x = 0, y = 0, z = 0}
		local dir = {x = 1, y = 0, z = 0}
		mesecon._test_place(pos, "mesecons:test_effector")
		mesecon._test_place(vector.offset(pos, 0, 1, 0), "mesecons:test_receptor_on")
		mesecon._test_place(vector.add(pos, dir), "mesecons:test_receptor_on")
		mineunit:execute_globalstep() -- Execute receptor_on action

		mesecon.mvps_push(pos, dir, 2, "")
		mineunit:execute_globalstep() -- Execute activate/deactivate/change actions
		assert.equal(tonumber("10000001", 2), world.get_node(vector.add(pos, dir)).param2)

		mesecon.mvps_pull_single(vector.add(pos, dir), vector.multiply(dir, -1), 1, "")
		mineunit:execute_globalstep() -- Execute activate/deactivate/change actions
		assert.equal(tonumber("10000100", 2), world.get_node(pos).param2)
	end)

	-- mineunit doesn't yet implement minetest.check_for_falling.
	pending("causes nodes to fall", function()
	end)
end)

describe("protection", function()
	teardown(function()
		minetest.settings:remove("mesecon.mvps_protection_mode")
	end)

	after_each(function()
		mesecon._test_reset()
		world.clear()
	end)

	local protected_pos = {x = 1, y = 0, z = 0}
	mineunit:protect(protected_pos, "Joe")

	it("blocks movement", function()
		minetest.settings:set("mesecon.mvps_protection_mode", "restrict")

		local pos = {x = 0, y = 0, z = 0}
		world.set_node(pos, "mesecons:test_conductor_off")

		assert.same({false, "protected"}, {mesecon.mvps_push(pos, {x = 1, y = 0, z = 0}, 1, "Bob")})
	end)

	it("allows owner's movement", function()
		minetest.settings:set("mesecon.mvps_protection_mode", "restrict")

		local pos = {x = 0, y = 0, z = 0}
		world.set_node(pos, "mesecons:test_conductor_off")

		assert.is_true((mesecon.mvps_push(pos, {x = 1, y = 0, z = 0}, 1, "Joe")))
	end)

	it("'ignore'", function()
		minetest.settings:set("mesecon.mvps_protection_mode", "ignore")

		local pos = {x = 0, y = 0, z = 0}
		world.set_node(pos, "mesecons:test_conductor_off")

		assert.is_true((mesecon.mvps_push(pos, {x = 1, y = 0, z = 0}, 1, "Bob")))
	end)

	it("'normal'", function()
		minetest.settings:set("mesecon.mvps_protection_mode", "normal")

		local pos = {x = 0, y = 0, z = 0}
		world.set_node(pos, "mesecons:test_conductor_off")

		assert.same({false, "protected"}, {mesecon.mvps_push(pos, {x = 1, y = 0, z = 0}, 1, "")})

		assert.is_true((mesecon.mvps_push(pos, {x = 0, y = 1, z = 0}, 1, "")))
	end)

	it("'compat'", function()
		minetest.settings:set("mesecon.mvps_protection_mode", "compat")

		local pos = {x = 0, y = 0, z = 0}
		world.set_node(pos, "mesecons:test_conductor_off")

		assert.is_true((mesecon.mvps_push(pos, {x = 1, y = 0, z = 0}, 1, "")))
	end)

	it("'restrict'", function()
		minetest.settings:set("mesecon.mvps_protection_mode", "restrict")

		local pos = {x = 0, y = 0, z = 0}
		world.set_node(pos, "mesecons:test_conductor_off")

		assert.same({false, "protected"}, {mesecon.mvps_push(pos, {x = 0, y = 1, z = 0}, 1, "")})
	end)
end)
