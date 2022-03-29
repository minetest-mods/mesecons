require("mineunit")

fixture("mesecons")

describe("placement/digging service", function()
	local layout = {
		{{x =  1, y = 0, z = 0}, "mesecons:test_receptor_on"},
		{{x =  0, y = 0, z = 0}, "mesecons:test_conductor_on"},
		{{x = -1, y = 0, z = 0}, "mesecons:test_conductor_on"},
		{{x =  0, y = 1, z = 0}, "mesecons:test_effector"},
		{{x = -2, y = 0, z = 0}, "mesecons:test_effector"},
		{{x =  2, y = 0, z = 0}, "mesecons:test_effector"},
	}

	before_each(function()
		world.layout(layout)
	end)

	after_each(function()
		mesecon._test_reset()
		world.clear()
	end)

	it("updates components when a receptor changes", function()
		mesecon._test_dig(layout[1][1])
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_conductor_off", world.get_node(layout[2][1]).name)
		mineunit:execute_globalstep()
		assert.equal(3, #mesecon._test_effector_events)

		mesecon._test_place(layout[1][1], "mesecons:test_receptor_on")
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_conductor_on", world.get_node(layout[2][1]).name)
		mineunit:execute_globalstep()
		assert.equal(6, #mesecon._test_effector_events)
	end)

	it("updates components when a conductor changes", function()
		mesecon._test_dig(layout[2][1])
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_conductor_off", world.get_node(layout[3][1]).name)
		mineunit:execute_globalstep()
		assert.equal(2, #mesecon._test_effector_events)

		mesecon._test_place(layout[2][1], "mesecons:test_conductor_off")
		assert.equal("mesecons:test_conductor_on", world.get_node(layout[2][1]).name)
		assert.equal("mesecons:test_conductor_on", world.get_node(layout[3][1]).name)
		mineunit:execute_globalstep()
		assert.equal(4, #mesecon._test_effector_events)
	end)

	it("updates effectors on placement", function()
		local pos = {x = 0, y = 0, z = 1}
		mesecon._test_place(pos, "mesecons:test_effector")
		mineunit:execute_globalstep()
		assert.equal(tonumber("10100000", 2), world.get_node(pos).param2)
	end)

	it("updates multiconductors on placement", function()
		local pos = {x = 0, y = 0, z = 1}
		mesecon._test_place(pos, "mesecons:test_multiconductor_off")
		assert.equal("mesecons:test_multiconductor_010", world.get_node(pos).name)
	end)

	it("turns off conductors on placement", function()
		local pos = {x = 3, y = 0, z = 0}
		mesecon._test_place(pos, "mesecons:test_conductor_on")
		assert.equal("mesecons:test_conductor_off", world.get_node(pos).name)
	end)

	-- Will work once #584 is merged.
	pending("turns off multiconductors on placement", function()
		local pos = {x = 3, y = 0, z = 0}
		mesecon._test_place(pos, "mesecons:test_multiconductor_on")
		assert.equal("mesecons:test_multiconductor_off", world.get_node(pos).name)
	end)

	it("triggers autoconnect hooks", function()
		mesecon._test_dig(layout[2][1])
		mineunit:execute_globalstep()
		assert.equal(1, #mesecon._test_autoconnects)

		mesecon._test_place(layout[2][1], layout[2][2])
		assert.equal(2, #mesecon._test_autoconnects)
	end)
end)

describe("overheating service", function()
	local layout = {
		{{x = 0, y = 0, z = 0}, "mesecons:test_receptor_off"},
		{{x = 1, y = 0, z = 0}, "mesecons:test_effector"},
		{{x = 2, y = 0, z = 0}, "mesecons:test_receptor_on"},
	}

	before_each(function()
		world.layout(layout)
	end)

	after_each(function()
		mesecon._test_reset()
		world.clear()
	end)

	it("tracks heat", function()
		mesecon.do_overheat(layout[2][1])
		assert.equal(1, mesecon.get_heat(layout[2][1]))
		mesecon.do_cooldown(layout[2][1])
		assert.equal(0, mesecon.get_heat(layout[2][1]))
	end)

	it("cools over time", function()
		mesecon.do_overheat(layout[2][1])
		assert.equal(1, mesecon.get_heat(layout[2][1]))
		mineunit:execute_globalstep(60)
		mineunit:execute_globalstep(60)
		mineunit:execute_globalstep(60)
		assert.equal(0, mesecon.get_heat(layout[2][1]))
	end)

	it("tracks movement", function()
		local oldpos = layout[2][1]
		local pos = vector.offset(oldpos, 0, 1, 0)
		mesecon.do_overheat(oldpos)
		mesecon.move_hot_nodes({{pos = pos, oldpos = oldpos}})
		assert.equal(0, mesecon.get_heat(oldpos))
		assert.equal(1, mesecon.get_heat(pos))
	end)

	it("causes overheating", function()
		repeat
			if mesecon.flipstate(layout[1][1], minetest.get_node(layout[1][1])) == "on" then
				mesecon.receptor_on(layout[1][1], mesecon.rules.alldirs)
			else
				mesecon.receptor_off(layout[1][1], mesecon.rules.alldirs)
			end
			mineunit:execute_globalstep(0)
		until minetest.get_node(layout[2][1]).name ~= "mesecons:test_effector"
		assert.same({"overheat", layout[2][1]}, mesecon._test_effector_events[#mesecon._test_effector_events])
		assert.equal(0, mesecon.get_heat(layout[2][1]))
	end)
end)
