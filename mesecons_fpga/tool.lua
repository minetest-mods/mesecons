return function(plg)

local function reset_meta(pos, code, errmsg) 
	local meta = minetest.get_meta(pos)
	meta:set_string("code", code)
	code = minetest.formspec_escape(code or "")
	errmsg = minetest.formspec_escape(errmsg or "")
	meta:set_string("formspec", "size[10,8]"..
		"background[-0.2,-0.25;10.4,8.75;jeija_luac_background.png]"..
		"textarea[0.2,0.6;10.2,5;code;;"..code.."]"..
		"image_button[3.75,6;2.5,1;jeija_luac_runbutton.png;program;]"..
		"image_button_exit[9.72,-0.25;0.425,0.4;jeija_close_window.png;exit;]"..
		"label[0.1,5;"..errmsg.."]")
	meta:set_int("heat", 0)
	meta:set_int("luac_id", math.random(1, 65535))
end


minetest.register_tool("mesecons_fpga:programmer", {
	description = "Programmer for FPGA and luacontroller",
	inventory_image = "jeija_fpga_programmer.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		
		local pos = pointed_thing.under
		if minetest.get_node(pos).name:find("mesecons_fpga:fpga") == 1 then
			local meta = minetest.get_meta(pos)
			if meta:get_string("instr") == "//////////////" then
			minetest.chat_send_player(placer:get_player_name(), "This FPGA is unprogrammed.")
			return itemstack
			end
			itemstack:set_metadata(meta:get_string("instr"))
			minetest.chat_send_player(placer:get_player_name(), "FPGA gate configuration was successfully copied!")
			
			return itemstack
			
		elseif minetest.get_node(pos).name:find("mesecons_luacontroller:luacontroller") == 1 then
			local meta = minetest.get_meta(pos)
			if meta:get_string("code") == "" then
			  minetest.chat_send_player(placer:get_player_name(), "This luacontroller is unprogrammed.")
			  return itemstack
			end
			itemstack:set_metadata(meta:get_string("code"))
			minetest.chat_send_player(placer:get_player_name(), "luacontroller was successfully copied!")
			return itemstack
		end

		return itemstack
	end,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local pos = pointed_thing.under
		
		if minetest.is_protected(pos, user:get_player_name()) then
		      minetest.chat_send_player(user:get_player_name(), "This is not your device !")
		      return itemstack
		end
		
		if minetest.get_node(pos).name:find("mesecons_fpga:fpga") == 1 then
		      local imeta = itemstack:get_metadata()
		      if imeta == "" then
			    minetest.chat_send_player(user:get_player_name(), "Use shift+right-click to copy a gate configuration first.")
			    return itemstack
		      end

		      local meta = minetest.get_meta(pos)
		      local _, count = string.gsub(imeta, "/", "")  -- fpga's always have 14 slashes in code
		      if count ~= 14 or imeta:find("[IiEeUuOoNntT]") ~= nil then    -- very unlikely but there could be a controller with 14 slashes too
			  minetest.chat_send_player(user:get_player_name(), "Code in Programmer is for a lua controller")
			  return itemstack
		      end
		      meta:set_string("instr", imeta)
		      plg.update_formspec(pos, imeta)
		      minetest.chat_send_player(user:get_player_name(), "Gate configuration was successfully written to FPGA!")
		      return itemstack
		      
		elseif minetest.get_node(pos).name:find("mesecons_luacontroller:luacontroller") == 1 then
		      local imeta = itemstack:get_metadata()
		      
		      if imeta == "" then
			    minetest.chat_send_player(user:get_player_name(), "Use shift+right-click to copy configuration first.")
			    return itemstack
		      end
		      local meta = minetest.get_meta(pos)
		      local _, count = string.gsub(imeta, "/", "")  -- fpga's always have 14 slashes in code
		      if (count == 14) and (imeta:find("[IiEeUuOoNntT]") == nil) then    
			  minetest.chat_send_player(user:get_player_name(), "Code in Programmer is for a FPGA")
			  return itemstack
		      end
		      meta:set_string("code", imeta)
		      reset_meta(pos, imeta, err)
		      minetest.chat_send_player(user:get_player_name(), "Configuration was successfully written to luacontroller!")
		      return itemstack
		end
		return itemstack
	end
})

minetest.register_craft({
	output = "mesecons_fpga:programmer",
	recipe = {
		{'group:mesecon_conductor_craftable'},
		{'mesecons_materials:silicon'},
	}
})


end
