return function(plg)


minetest.register_tool("mesecons_proglogicgate:programmer", {
	description = "FPGA Programmer",
	inventory_image = "jeija_proglogicgate_programmer.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local pos = pointed_thing.under
		if minetest.get_node(pos).name:find("mesecons_proglogicgate:gate") ~= 1 then
			return itemstack
		end

		local meta = minetest.get_meta(pos)
		if meta:get_string("instr") == "//////////////" then
			minetest.chat_send_player(placer:get_player_name(), "This FPGA is unprogrammed.")
			return itemstack
		end
		itemstack:set_metadata(meta:get_string("instr"))
		minetest.chat_send_player(placer:get_player_name(), "FPGA circuit configuration was copied!")
		
		return itemstack
	end,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local pos = pointed_thing.under
		if minetest.get_node(pos).name:find("mesecons_proglogicgate:gate") ~= 1 then
			return itemstack
		end

		local imeta = itemstack:get_metadata()
		if imeta == "" then
			minetest.chat_send_player(user:get_player_name(), "Use shift+right-click to copy a circuit configuration first.")
			return itemstack
		end

		local meta = minetest.get_meta(pos)
		meta:set_string("instr", imeta)
		plg.update_formspec(pos, imeta)
		minetest.chat_send_player(user:get_player_name(), "Circuit configuration was successfully written to FPGA!")

		return itemstack
	end
})

minetest.register_craft({
	output = "mesecons_proglogicgate:programmer",
	recipe = {
		{'group:mesecon_conductor_craftable'},
		{'mesecons_materials:silicon'},
	}
})


end
