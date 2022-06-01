require("mineunit")

fixture("mesecons_luacontroller")

-- Digiline is not tested, since that would require the digiline mod.

describe("LuaController", function()
	local pos = {x = 0, y = 0, z = 0}
	local pos_a = {x = -1, y = 0, z =  0}

	before_each(function()
		mesecon._test_place(pos, "mesecons_luacontroller:luacontroller0000")
		mineunit:execute_globalstep()
	end)

	after_each(function()
		mesecon._test_reset()
		world.clear()
	end)

	it("rejects binary code", function()
		local ok = mesecon._test_program_luac(pos, string.dump(function() end))
		assert.is_false(ok)
	end)

	it("I/O", function()
		mesecon._test_place(pos_a, "mesecons:test_receptor_on")
		mineunit:execute_globalstep()
		mineunit:execute_globalstep()
		mesecon._test_program_luac(pos, [[
			port.a = not pin.a
			port.b = not pin.b
			port.c = not pin.c
			port.d = not pin.d
		]])
		mineunit:execute_globalstep()
		assert.equal("mesecons_luacontroller:luacontroller1110", world.get_node(pos).name)
		mesecon._test_dig(pos_a)
		mineunit:execute_globalstep()
		mineunit:execute_globalstep()
		assert.equal("mesecons_luacontroller:luacontroller0001", world.get_node(pos).name)
	end)

	it("memory", function()
		mesecon._test_program_luac(pos, [[
			if not mem.x then
				mem.x = {}
				mem.x[mem.x] = {true, "", 1.2}
			else
				local b, s, n = unpack(mem.x[mem.x])
				if b == true and s == "" and n == 1.2 then
					port.d = true
				end
			end
		]])
		mineunit:execute_globalstep()
		assert.equal("mesecons_luacontroller:luacontroller0000", world.get_node(pos).name)
		mesecon._test_place(pos_a, "mesecons:test_receptor_on")
		mineunit:execute_globalstep()
		mineunit:execute_globalstep()
		assert.equal("mesecons_luacontroller:luacontroller1000", world.get_node(pos).name)
	end)

	it("interrupts without IDs", function()
		mesecon._test_program_luac(pos, [[
			if event.type == "program" then
				interrupt(4)
				interrupt(8)
			elseif event.type == "interrupt" then
				port.a = not pin.a
			end
		]])
		mineunit:execute_globalstep(0.1)
		mineunit:execute_globalstep(3)
		assert.equal("mesecons_luacontroller:luacontroller0000", world.get_node(pos).name)
		mineunit:execute_globalstep(1)
		mineunit:execute_globalstep(0.1)
		assert.equal("mesecons_luacontroller:luacontroller0001", world.get_node(pos).name)
		mineunit:execute_globalstep(3)
		assert.equal("mesecons_luacontroller:luacontroller0001", world.get_node(pos).name)
		mineunit:execute_globalstep(1)
		mineunit:execute_globalstep(0.1)
		assert.equal("mesecons_luacontroller:luacontroller0000", world.get_node(pos).name)
	end)

	it("interrupts with IDs", function()
		mesecon._test_program_luac(pos, [[
			if event.type == "program" then
				interrupt(2, "a")
				interrupt(4, "a")
				interrupt(16, "b")
			elseif event.type == "interrupt" then
				if event.iid == "a" then
					interrupt(5, "b")
					interrupt(4, "b")
				end
				port.a = not pin.a
			end
		]])
		mineunit:execute_globalstep(0.1)
		mineunit:execute_globalstep(3)
		assert.equal("mesecons_luacontroller:luacontroller0000", world.get_node(pos).name)
		mineunit:execute_globalstep(1)
		mineunit:execute_globalstep(0.1)
		assert.equal("mesecons_luacontroller:luacontroller0001", world.get_node(pos).name)
		mineunit:execute_globalstep(3)
		assert.equal("mesecons_luacontroller:luacontroller0001", world.get_node(pos).name)
		mineunit:execute_globalstep(1)
		mineunit:execute_globalstep(0.1)
		assert.equal("mesecons_luacontroller:luacontroller0000", world.get_node(pos).name)
	end)

	it("limits interrupt ID size", function()
		mesecon._test_program_luac(pos, [[
			if event.type == "program" then
				interrupt(0, (" "):rep(257))
			elseif event.type == "interrupt" then
				port.a = not pin.a
			end
		]])
		mineunit:execute_globalstep(3)
		mineunit:execute_globalstep(3)
		assert.equal("mesecons_luacontroller:luacontroller0000", world.get_node(pos).name)
	end)

	it("string.rep", function()
		mesecon._test_program_luac(pos, [[
			(" "):rep(64000)
			port.a = true
		]])
		mineunit:execute_globalstep()
		assert.equal("mesecons_luacontroller:luacontroller0001", world.get_node(pos).name)
		mesecon._test_program_luac(pos, [[
			(" "):rep(64001)
			port.b = true
		]])
		mineunit:execute_globalstep()
		assert.equal("mesecons_luacontroller:luacontroller0000", world.get_node(pos).name)
	end)

	it("string.find", function()
		mesecon._test_program_luac(pos, [[
			port.a = (" a"):find("a", nil, true) == 2
		]])
		mineunit:execute_globalstep()
		assert.equal("mesecons_luacontroller:luacontroller0001", world.get_node(pos).name)
		mesecon._test_program_luac(pos, [[
			(" a"):find("a", nil)
			port.b = true
		]])
		mineunit:execute_globalstep()
		assert.equal("mesecons_luacontroller:luacontroller0000", world.get_node(pos).name)
	end)

	it("overheats", function()
		mesecon._test_program_luac(pos, [[
			interrupt(0)
			interrupt(0)
		]])
		mineunit:execute_globalstep()
		mineunit:execute_globalstep()
		mineunit:execute_globalstep()
		mineunit:execute_globalstep()
		assert.equal("mesecons_luacontroller:luacontroller_burnt", world.get_node(pos).name)
	end)

	it("limits memory", function()
		mesecon._test_program_luac(pos, [[
			port.a = true
			mem.x = (" "):rep(50000) .. (" "):rep(50000)
		]])
		mineunit:execute_globalstep()
		assert.equal("mesecons_luacontroller:luacontroller_burnt", world.get_node(pos).name)
	end)

	it("limits run time", function()
		mesecon._test_program_luac(pos, [[
			port.a = true
			for i = 1, 1000000 do end
		]])
		mineunit:execute_globalstep()
		assert.equal("mesecons_luacontroller:luacontroller0000", world.get_node(pos).name)
	end)
end)
