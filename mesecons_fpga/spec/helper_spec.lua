require("mineunit")

fixture("mesecons_fpga")
fixture("screwdriver")

local pos = {x = 0, y = 0, z = 0}
local pos_a = {x = -1, y = 0, z =  0}
local pos_b = {x =  0, y = 0, z =  1}
local pos_c = {x =  1, y = 0, z =  0}
local pos_d = {x =  0, y = 0, z = -1}

describe("FPGA rotation", function()
	before_each(function()
		world.set_node(pos, "mesecons_fpga:fpga0000")
	end)

	after_each(function()
		mesecon._test_reset()
		world.clear()
	end)

	it("rotates I/O operands clockwise", function()
		mesecon._test_program_fpga(pos, {{"A", "OR", "B", "C"}})

		local node = world.get_node(pos)
		minetest.registered_nodes[node.name].on_rotate(pos, node, nil, screwdriver.ROTATE_FACE)

		mesecon._test_place(pos_b, "mesecons:test_receptor_on")
		mineunit:execute_globalstep() -- Execute receptor_on action
		mineunit:execute_globalstep() -- Execute activate/change actions
		assert.equal("mesecons_fpga:fpga1000", world.get_node(pos).name)

		mesecon._test_dig(pos_b)
		mesecon._test_place(pos_c, "mesecons:test_receptor_on")
		mineunit:execute_globalstep() -- Execute receptor_on/receptor_off actions
		mineunit:execute_globalstep() -- Execute activate/deactivate/change actions
		assert.equal("mesecons_fpga:fpga1000", world.get_node(pos).name)
	end)

	it("rotates I/O operands counterclockwise", function()
		mesecon._test_program_fpga(pos, {{"A", "OR", "B", "C"}})

		local node = world.get_node(pos)
		minetest.registered_nodes[node.name].on_rotate(pos, node, nil, screwdriver.ROTATE_AXIS)

		mesecon._test_place(pos_d, "mesecons:test_receptor_on")
		mineunit:execute_globalstep() -- Execute receptor_on action
		mineunit:execute_globalstep() -- Execute activate/change actions
		assert.equal("mesecons_fpga:fpga0010", world.get_node(pos).name)

		mesecon._test_dig(pos_d)
		mesecon._test_place(pos_a, "mesecons:test_receptor_on")
		mineunit:execute_globalstep() -- Execute receptor_on/receptor_off actions
		mineunit:execute_globalstep() -- Execute activate/deactivate/change actions
		assert.equal("mesecons_fpga:fpga0010", world.get_node(pos).name)
	end)

	it("updates ports", function()
		mesecon._test_program_fpga(pos, {{"NOT", "A", "B"}})
		assert.equal("mesecons_fpga:fpga0010", world.get_node(pos).name)

		local node = world.get_node(pos)
		minetest.registered_nodes[node.name].on_rotate(pos, node, nil, screwdriver.ROTATE_AXIS)
		assert.equal("mesecons_fpga:fpga0001", world.get_node(pos).name)
	end)
end)

-- mineunit does not support deprecated ItemStack:get_metadata()
pending("FPGA programmer", function()
	local pos2 = {x = 10, y = 0, z = 0}

	before_each(function()
		world.set_node(pos, "mesecons_fpga:fpga0000")
		world.set_node(pos2, "mesecons_fpga:fpga0000")
	end)

	after_each(function()
		mesecon._test_reset()
		world.clear()
	end)

	it("transfers instructions", function()
		mesecon._test_program_fpga(pos2, {{"NOT", "A", "B"}})
		mesecon._test_paste_fpga_program(pos, mesecon._test_copy_fpga_program(pos2))
		assert.equal("mesecons_fpga:fpga0010", world.get_node(pos).name)
	end)

	it("does not copy from new FPGAs", function()
		mesecon._test_program_fpga(pos, {{"NOT", "A", "B"}})
		mesecon._test_paste_fpga_program(pos, mesecon._test_copy_fpga_program(pos2))
		assert.equal("mesecons_fpga:fpga0010", world.get_node(pos).name)
	end)

	it("does not copy from cleared FPGAs", function()
		mesecon._test_program_fpga(pos, {{"NOT", "A", "B"}})
		mesecon._test_program_fpga(pos2, {{"=", "A", "B"}})
		mesecon._test_program_fpga(pos2, {})
		mesecon._test_paste_fpga_program(pos, mesecon._test_copy_fpga_program(pos2))
		assert.equal("mesecons_fpga:fpga0010", world.get_node(pos).name)
	end)

	it("does not copy from non-FPGA nodes", function()
		mesecon._test_program_fpga(pos, {{"NOT", "A", "B"}})
		mesecon._test_paste_fpga_program(pos, mesecon._test_copy_fpga_program(vector.add(pos2, 1)))
		assert.equal("mesecons_fpga:fpga0010", world.get_node(pos).name)
	end)
end)
