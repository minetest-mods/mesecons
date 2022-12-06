fixture("mesecons")
fixture("mesecons_gamecompat")

mineunit:set_current_modname("mesecons_luacontroller")
mineunit:set_modpath("mesecons_luacontroller", "../mesecons_luacontroller")
sourcefile("../mesecons_luacontroller/init")

function mesecon._test_program_luac(pos, code)
	local node = minetest.get_node(pos)
	assert.equal("mesecons_luacontroller:luacontroller", node.name:sub(1, 36))
	return minetest.registered_nodes[node.name].mesecons.luacontroller.set_program(pos, code)
end
