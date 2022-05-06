mineunit("player")

fixture("mesecons")

mesecon.node_sound = {}

local registered_on_player_receive_fields = {}
local old_register_on_player_receive_fields = minetest.register_on_player_receive_fields
function minetest.register_on_player_receive_fields(func)
	old_register_on_player_receive_fields(func)
	table.insert(registered_on_player_receive_fields, func)
end

mineunit:set_current_modname("mesecons_fpga")
mineunit:set_modpath("mesecons_fpga", "../mesecons_fpga")
sourcefile("../mesecons_fpga/init")

local fpga_user = Player("mesecons_fpga_user")

function mesecon._test_program_fpga(pos, program)
	local node = minetest.get_node(pos)
	assert.equal("mesecons_fpga:fpga", node.name:sub(1, 18))

	local fields = {program = true}
	for i, instr in ipairs(program) do
		local op1, act, op2, dst
		if #instr == 3 then
			act, op2, dst = unpack(instr)
		else
			assert.equal(4, #instr)
			op1, act, op2, dst = unpack(instr)
		end
		fields[i .. "op1"] = op1
		fields[i .. "act"] = (" "):rep(4 - #act) .. act
		fields[i .. "op2"] = op2
		fields[i .. "dst"] = dst
	end

	minetest.registered_nodes[node.name].on_rightclick(pos, node, fpga_user)

	for _, func in ipairs(registered_on_player_receive_fields) do
		if func(fpga_user, "mesecons:fpga", fields) then
			break
		end
	end
end

function mesecon._test_copy_fpga_program(pos)
	fpga_user:get_inventory():set_stack("main", 1, "mesecons_fpga:programmer")
	local pt = {type = "node", under = vector.new(pos), above = vector.offset(pos, 0, 1, 0)}
	fpga_user:do_place(pt)
	return fpga_user:get_wielded_item()
end

function mesecon._test_paste_fpga_program(pos, tool)
	fpga_user:get_inventory():set_stack("main", 1, tool)
	local pt = {type = "node", under = vector.new(pos), above = vector.offset(pos, 0, 1, 0)}
	fpga_user:do_use(pt)
end
