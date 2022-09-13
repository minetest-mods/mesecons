require("mineunit")

fixture("mesecons")

describe("state", function()
	local layout = {
		{{x =  1, y =  0, z = 0}, "mesecons:test_receptor_off"},
		{{x =  0, y =  1, z = 0}, "mesecons:test_receptor_off"},
		{{x =  0, y =  0, z = 0}, "mesecons:test_conductor_off"},
		{{x = -1, y =  0, z = 0}, "mesecons:test_effector"},
		{{x =  2, y =  0, z = 0}, "mesecons:test_effector"},
		{{x =  0, y = -1, z = 0}, "mesecons:test_effector"},
	}

	before_each(function()
		world.layout(layout)
	end)

	after_each(function()
		mesecon._test_reset()
		world.clear()
	end)

	it("turns on", function()
		world.set_node(layout[1][1], "mesecons:test_receptor_on")
		mesecon.receptor_on(layout[1][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_conductor_on", world.get_node(layout[3][1]).name)
		assert.equal(tonumber("10000001", 2), world.get_node(layout[4][1]).param2)
		assert.equal(tonumber("10000010", 2), world.get_node(layout[5][1]).param2)
		assert.equal(tonumber("10000100", 2), world.get_node(layout[6][1]).param2)

		world.set_node(layout[2][1], "mesecons:test_receptor_on")
		mesecon.receptor_on(layout[2][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_conductor_on", world.get_node(layout[3][1]).name)
		assert.equal(tonumber("10000001", 2), world.get_node(layout[4][1]).param2)
		assert.equal(tonumber("10000010", 2), world.get_node(layout[5][1]).param2)
		assert.equal(tonumber("10000100", 2), world.get_node(layout[6][1]).param2)
	end)

	it("turns off", function()
		world.set_node(layout[1][1], "mesecons:test_receptor_on")
		world.set_node(layout[2][1], "mesecons:test_receptor_on")
		mesecon.receptor_on(layout[1][1], mesecon.rules.alldirs)
		mesecon.receptor_on(layout[2][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()

		world.set_node(layout[1][1], "mesecons:test_receptor_off")
		mesecon.receptor_off(layout[1][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_conductor_on", world.get_node(layout[3][1]).name)
		assert.equal(tonumber("10000001", 2), world.get_node(layout[4][1]).param2)
		assert.equal(tonumber("00000000", 2), world.get_node(layout[5][1]).param2)
		assert.equal(tonumber("10000100", 2), world.get_node(layout[6][1]).param2)

		world.set_node(layout[2][1], "mesecons:test_receptor_off")
		mesecon.receptor_off(layout[2][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_conductor_off", world.get_node(layout[3][1]).name)
		assert.equal(tonumber("00000000", 2), world.get_node(layout[4][1]).param2)
		assert.equal(tonumber("00000000", 2), world.get_node(layout[5][1]).param2)
		assert.equal(tonumber("00000000", 2), world.get_node(layout[6][1]).param2)
	end)
end)

describe("rotation", function()
	local layout = {
		{{x =  0, y = 0, z =  0}, "mesecons:test_receptor_off"},
		{{x =  1, y = 0, z =  0}, {name = "mesecons:test_conductor_rot_off", param2 = 0}},
		{{x =  0, y = 0, z =  1}, {name = "mesecons:test_conductor_rot_off", param2 = 1}},
		{{x = -1, y = 0, z =  0}, {name = "mesecons:test_conductor_rot_off", param2 = 2}},
		{{x =  0, y = 0, z = -1}, {name = "mesecons:test_conductor_rot_off", param2 = 3}},
	}

	before_each(function()
		for _, entry in ipairs(layout) do
			world.set_node(entry[1], entry[2])
		end
	end)

	after_each(function()
		mesecon._test_reset()
		world.clear()
	end)

	it("works", function()
		world.set_node(layout[1][1], "mesecons:test_receptor_on")
		mesecon.receptor_on(layout[1][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_conductor_rot_on", world.get_node(layout[2][1]).name)
		assert.equal("mesecons:test_conductor_rot_on", world.get_node(layout[3][1]).name)
		assert.equal("mesecons:test_conductor_rot_on", world.get_node(layout[4][1]).name)
		assert.equal("mesecons:test_conductor_rot_on", world.get_node(layout[5][1]).name)
	end)
end)

describe("multiconductor", function()
	local layout = {
		{{x =  1, y = 0, z =  0}, "mesecons:test_receptor_off"},
		{{x =  0, y = 1, z =  0}, "mesecons:test_receptor_off"},
		{{x =  0, y = 0, z =  1}, "mesecons:test_receptor_off"},
		{{x =  0, y = 0, z =  0}, "mesecons:test_multiconductor_off"},
	}

	before_each(function()
		world.layout(layout)
	end)

	after_each(function()
		world.clear()
		mesecon._test_reset()
	end)

	it("separates its subparts", function()
		world.set_node(layout[1][1], "mesecons:test_receptor_on")
		mesecon.receptor_on(layout[1][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_multiconductor_001", world.get_node(layout[4][1]).name)

		world.set_node(layout[2][1], "mesecons:test_receptor_on")
		mesecon.receptor_on(layout[2][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_multiconductor_011", world.get_node(layout[4][1]).name)

		world.set_node(layout[3][1], "mesecons:test_receptor_on")
		mesecon.receptor_on(layout[3][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_multiconductor_on", world.get_node(layout[4][1]).name)
	end)

	it("loops through itself", function()
		-- Make a loop.
		world.set_node({x = 0, y = -1, z = 0}, "mesecons:test_conductor_off")
		world.set_node({x = -1, y = -1, z = 0}, "mesecons:test_conductor_off")
		world.set_node({x = -1, y = 0, z = 0}, "mesecons:test_conductor_off")

		world.set_node(layout[1][1], "mesecons:test_receptor_on")
		mesecon.receptor_on(layout[1][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_multiconductor_101", world.get_node(layout[4][1]).name)
	end)
end)
