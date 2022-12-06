require("mineunit")

fixture("mesecons_fpga")

describe("FPGA logic", function()
	local pos = {x = 0, y = 0, z = 0}
	local pos_a = {x = -1, y = 0, z =  0}
	local pos_b = {x =  0, y = 0, z =  1}
	local pos_c = {x =  1, y = 0, z =  0}
	local pos_d = {x =  0, y = 0, z = -1}

	local fpga_set = false

	local function set_fpga()
		if not fpga_set then
			world.set_node(pos, "mesecons_fpga:fpga0000")
			fpga_set = true
		end
	end
	before_each(set_fpga)

	local function reset_world()
		if fpga_set then
			mesecon._test_reset()
			world.clear()
			fpga_set = false
		end
	end
	after_each(reset_world)

	local function test_program(inputs, outputs, program)
		set_fpga()

		mesecon._test_program_fpga(pos, program)

		if inputs.a then mesecon._test_place(pos_a, "mesecons:test_receptor_on") end
		if inputs.b then mesecon._test_place(pos_b, "mesecons:test_receptor_on") end
		if inputs.c then mesecon._test_place(pos_c, "mesecons:test_receptor_on") end
		if inputs.d then mesecon._test_place(pos_d, "mesecons:test_receptor_on") end
		mineunit:execute_globalstep() -- Execute receptor_on actions
		mineunit:execute_globalstep() -- Execute activate/change actions

		local expected_name = "mesecons_fpga:fpga"
				.. (outputs.d and 1 or 0) .. (outputs.c and 1 or 0)
				.. (outputs.b and 1 or 0) .. (outputs.a and 1 or 0)
		assert.equal(expected_name, world.get_node(pos).name)

		reset_world()
	end

	it("operator and", function()
		local prog = {{"A", "AND", "B", "C"}}
		test_program({}, {}, prog)
		test_program({a = true}, {}, prog)
		test_program({b = true}, {}, prog)
		test_program({a = true, b = true}, {c = true}, prog)
	end)

	it("operator or", function()
		local prog = {{"A", "OR", "B", "C"}}
		test_program({}, {}, prog)
		test_program({a = true}, {c = true}, prog)
		test_program({b = true}, {c = true}, prog)
		test_program({a = true, b = true}, {c = true}, prog)
	end)

	it("operator not", function()
		local prog = {{"NOT", "A", "B"}}
		test_program({}, {b = true}, prog)
		test_program({a = true}, {}, prog)
	end)

	it("operator xor", function()
		local prog = {{"A", "XOR", "B", "C"}}
		test_program({}, {}, prog)
		test_program({a = true}, {c = true}, prog)
		test_program({b = true}, {c = true}, prog)
		test_program({a = true, b = true}, {}, prog)
	end)

	it("operator nand", function()
		local prog = {{"A", "NAND", "B", "C"}}
		test_program({}, {c = true}, prog)
		test_program({a = true}, {c = true}, prog)
		test_program({b = true}, {c = true}, prog)
		test_program({a = true, b = true}, {}, prog)
	end)

	it("operator buf", function()
		local prog = {{"=", "A", "B"}}
		test_program({}, {}, prog)
		test_program({a = true}, {b = true}, prog)
	end)

	it("operator xnor", function()
		local prog = {{"A", "XNOR", "B", "C"}}
		test_program({}, {c = true}, prog)
		test_program({a = true}, {}, prog)
		test_program({b = true}, {}, prog)
		test_program({a = true, b = true}, {c = true}, prog)
	end)

	it("operator nor", function()
		local prog = {{"A", "NOR", "B", "C"}}
		test_program({}, {c = true}, prog)
		test_program({a = true}, {}, prog)
		test_program({b = true}, {}, prog)
		test_program({a = true, b = true}, {}, prog)
	end)

	it("rejects duplicate operands", function()
		test_program({a = true}, {}, {{"A", "OR", "A", "B"}})
		test_program({a = true}, {}, {{"=", "A", "0"}, {"0", "OR", "0", "B"}})
	end)

	it("rejects unassigned memory operands", function()
		test_program({a = true}, {}, {{"A", "OR", "0", "B"}})
		test_program({a = true}, {}, {{"0", "OR", "A", "B"}})
	end)

	it("rejects double memory assignment", function()
		test_program({a = true}, {}, {{"=", "A", "0"}, {"=", "A", "0"}, {"=", "0", "B"}})
	end)

	it("rejects assignment to memory operand", function()
		test_program({a = true}, {}, {{"=", "A", "0"}, {"A", "OR", "0", "0"}, {"=", "0", "B"}})
	end)

	it("allows double port assignment", function()
		test_program({a = true}, {b = true}, {{"NOT", "A", "B"}, {"=", "A", "B"}})
	end)

	it("allows assignment to port operand", function()
		test_program({a = true}, {b = true}, {{"A", "OR", "B", "B"}})
	end)

	it("preserves initial pin states", function()
		test_program({a = true}, {b = true}, {{"=", "A", "B"}, {"=", "B", "C"}})
	end)

	it("rejects binary operations with single operands", function()
		test_program({a = true}, {}, {{"=", "A", "B"}, {" ", "OR", "A", "C"}})
		test_program({a = true}, {}, {{"=", "A", "B"}, {"A", "OR", " ", "C"}})
	end)

	it("rejects unary operations with first operands", function()
		test_program({a = true}, {}, {{"=", "A", "B"}, {"A", "=", " ", "C"}})
	end)

	it("rejects operations without destinations", function()
		test_program({a = true}, {}, {{"=", "A", "B"}, {"=", "A", " "}})
	end)

	it("allows blank statements", function()
		test_program({a = true}, {b = true, c = true}, {
			{" ", " ", " ", " "},
			{"=", "A", "B"},
			{" ", " ", " ", " "},
			{" ", " ", " ", " "},
			{"=", "A", "C"},
		})
	end)

	it("transmits output signals to adjacent nodes", function()
		mesecon._test_program_fpga(pos, {
			{"=", "A", "B"},
			{"=", "A", "C"},
			{"NOT", "A", "D"},
		})
		mesecon._test_place(pos_b, "mesecons:test_effector")
		mesecon._test_place(pos_c, "mesecons:test_effector")
		mesecon._test_place(pos_d, "mesecons:test_effector")
		mineunit:execute_globalstep() -- Execute receptor_on actions
		mineunit:execute_globalstep() -- Execute activate/change actions

		-- Makes an object from the last three effector events in the list for use with assert.same.
		-- This is necessary to ignore the ordering of events.
		local function event_tester(list)
			local o = {list[#list - 2], list[#list - 1], list[#list - 0]}
			table.sort(o, function(a, b)
				local fmt = "%s %d %d %d"
				return fmt:format(a[1], a[2].x, a[2].y, a[2].z) < fmt:format(b[1], b[2].x, b[2].y, b[2].z)
			end)
			return o
		end

		mesecon._test_place(pos_a, "mesecons:test_receptor_on")
		mineunit:execute_globalstep() -- Execute receptor_on action
		mineunit:execute_globalstep() -- Execute activate/change actions
		mineunit:execute_globalstep() -- Execute receptor_on/receptor_off actions
		mineunit:execute_globalstep() -- Execute activate/deactivate/change actions
		assert.equal("mesecons_fpga:fpga0110", world.get_node(pos).name)
		assert.same(event_tester({{"on", pos_b}, {"on", pos_c}, {"off", pos_d}}), event_tester(mesecon._test_effector_events))

		mesecon._test_dig(pos_a)
		mineunit:execute_globalstep() -- Execute receptor_off action
		mineunit:execute_globalstep() -- Execute deactivate/change actions
		mineunit:execute_globalstep() -- Execute receptor_on/receptor_off actions
		mineunit:execute_globalstep() -- Execute activate/deactivate/change actions
		assert.equal("mesecons_fpga:fpga1000", world.get_node(pos).name)
		assert.same(event_tester({{"off", pos_b}, {"off", pos_c}, {"on", pos_d}}), event_tester(mesecon._test_effector_events))
	end)

	it("considers past outputs in determining inputs", function()
		-- Memory cell: Turning on A turns on C; turning on B turns off C.
		mesecon._test_program_fpga(pos, {
			{"A", "OR", "C", "0"},
			{"B", "OR", "D", "1"},
			{"NOT", "A", "2"},
			{"NOT", "B", "3"},
			{"0", "AND", "3", "C"},
			{"1", "AND", "2", "D"},
		})

		mesecon._test_place(pos_a, "mesecons:test_receptor_on")
		mineunit:execute_globalstep() -- Execute receptor_on actions
		mineunit:execute_globalstep() -- Execute activate/change actions
		assert.equal("mesecons_fpga:fpga0100", world.get_node(pos).name)

		mesecon._test_dig(pos_a)
		mineunit:execute_globalstep() -- Execute receptor_off actions
		mineunit:execute_globalstep() -- Execute deactivate/change actions
		assert.equal("mesecons_fpga:fpga0100", world.get_node(pos).name)

		mesecon._test_place(pos_b, "mesecons:test_receptor_on")
		mineunit:execute_globalstep() -- Execute receptor_on actions
		mineunit:execute_globalstep() -- Execute activate/change actions
		assert.equal("mesecons_fpga:fpga1000", world.get_node(pos).name)

		mesecon._test_dig(pos_b)
		mineunit:execute_globalstep() -- Execute receptor_off actions
		mineunit:execute_globalstep() -- Execute deactivate/change actions
		assert.equal("mesecons_fpga:fpga1000", world.get_node(pos).name)
	end)
end)
