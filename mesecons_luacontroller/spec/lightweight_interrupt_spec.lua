require("mineunit")

-- This test is done in a separate file since it requires different configuration at startup.
mineunit("core")
minetest.settings:set("mesecon.luacontroller_lightweight_interrupts", "true")

fixture("mesecons_luacontroller")

describe("LuaController lightweight interrupt", function()
	local pos = {x = 0, y = 0, z = 0}

	before_each(function()
		mesecon._test_place(pos, "mesecons_luacontroller:luacontroller0000")
		mineunit:execute_globalstep() -- Execute receptor_on action
	end)

	after_each(function()
		mesecon._test_reset()
		world.clear()
	end)

	it("works", function()
		mesecon._test_program_luac(pos, [[
			if event.type == "program" then
				interrupt(5)
				interrupt(10)
			elseif event.type == "interrupt" then
				port.a = not pin.a
			end
		]])
		mineunit:execute_globalstep(0.1)
		mineunit:execute_globalstep(9)
		assert.equal("mesecons_luacontroller:luacontroller0000", world.get_node(pos).name)
		mineunit:execute_globalstep(1)
		mineunit:execute_globalstep(0.1)
		assert.equal("mesecons_luacontroller:luacontroller0001", world.get_node(pos).name)
	end)
end)
