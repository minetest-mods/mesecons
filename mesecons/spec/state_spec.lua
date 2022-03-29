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
		mesecon.swap_node_force(layout[1][1], "mesecons:test_receptor_on")
		mesecon.receptor_on(layout[1][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_conductor_on", world.get_node(layout[3][1]).name)
		assert.equal(tonumber("10000001", 2), world.get_node(layout[4][1]).param2)
		assert.equal(tonumber("10000010", 2), world.get_node(layout[5][1]).param2)
		assert.equal(tonumber("10000100", 2), world.get_node(layout[6][1]).param2)

		mesecon.swap_node_force(layout[2][1], "mesecons:test_receptor_on")
		mesecon.receptor_on(layout[2][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_conductor_on", world.get_node(layout[3][1]).name)
		assert.equal(tonumber("10000001", 2), world.get_node(layout[4][1]).param2)
		assert.equal(tonumber("10000010", 2), world.get_node(layout[5][1]).param2)
		assert.equal(tonumber("10000100", 2), world.get_node(layout[6][1]).param2)
	end)

	it("turns off", function()
		mesecon.swap_node_force(layout[1][1], "mesecons:test_receptor_on")
		mesecon.swap_node_force(layout[2][1], "mesecons:test_receptor_on")
		mesecon.receptor_on(layout[1][1], mesecon.rules.alldirs)
		mesecon.receptor_on(layout[2][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()

		mesecon.swap_node_force(layout[1][1], "mesecons:test_receptor_off")
		mesecon.receptor_off(layout[1][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_conductor_on", world.get_node(layout[3][1]).name)
		assert.equal(tonumber("10000001", 2), world.get_node(layout[4][1]).param2)
		assert.equal(tonumber("00000000", 2), world.get_node(layout[5][1]).param2)
		assert.equal(tonumber("10000100", 2), world.get_node(layout[6][1]).param2)

		mesecon.swap_node_force(layout[2][1], "mesecons:test_receptor_off")
		mesecon.receptor_off(layout[2][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_conductor_off", world.get_node(layout[3][1]).name)
		assert.equal(tonumber("00000000", 2), world.get_node(layout[4][1]).param2)
		assert.equal(tonumber("00000000", 2), world.get_node(layout[5][1]).param2)
		assert.equal(tonumber("00000000", 2), world.get_node(layout[6][1]).param2)
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
		mesecon.swap_node_force(layout[1][1], "mesecons:test_receptor_on")
		mesecon.receptor_on(layout[1][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_multiconductor_001", world.get_node(layout[4][1]).name)

		mesecon.swap_node_force(layout[2][1], "mesecons:test_receptor_on")
		mesecon.receptor_on(layout[2][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_multiconductor_011", world.get_node(layout[4][1]).name)

		mesecon.swap_node_force(layout[3][1], "mesecons:test_receptor_on")
		mesecon.receptor_on(layout[3][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_multiconductor_on", world.get_node(layout[4][1]).name)
	end)

	it("loops through itself", function()
		-- Make a loop.
		world.set_node({x = 0, y = -1, z = 0}, "mesecons:test_conductor_off")
		world.set_node({x = -1, y = -1, z = 0}, "mesecons:test_conductor_off")
		world.set_node({x = -1, y = 0, z = 0}, "mesecons:test_conductor_off")

		mesecon.swap_node_force(layout[1][1], "mesecons:test_receptor_on")
		mesecon.receptor_on(layout[1][1], mesecon.rules.alldirs)
		mineunit:execute_globalstep()
		assert.equal("mesecons:test_multiconductor_101", world.get_node(layout[4][1]).name)
	end)
end)
