-- Ugly hack to prevent breaking compatibility with other mods
-- Just remove the following two functions to delete the hack, to be done when other mods have updated
function mesecon.receptor_on(self, pos, rules)
	if (self.receptor_on) then
		print("[Mesecons] Warning: A mod with mesecon support called mesecon:receptor_on.")
		print("[Mesecons]          If you are the programmer of this mod, please update it ")
		print("[Mesecons]          to use mesecon.receptor_on instead. mesecon:* is deprecated")
		print("[Mesecons]          Otherwise, please make sure you're running the latest version")
		print("[Mesecons]          of that mod and inform the mod creator.")
	else
		rules = pos
		pos = self
	end
	mesecon.queue:add_action(pos, "receptor_on", {rules}, nil, rules)
end

function mesecon.receptor_off(self, pos, rules)
	if (self.receptor_off) then
		print("[Mesecons] Warning: A mod with mesecon support called mesecon:receptor_off.")
		print("[Mesecons]          If you are the programmer of this mod, please update it ")
		print("[Mesecons]          to use mesecon.receptor_off instead. mesecon:* is deprecated")
		print("[Mesecons]          Otherwise, please make sure you're running the latest version")
		print("[Mesecons]          of that mod and inform the mod creator.")
	else
		rules = pos
		pos = self
	end
	mesecon.queue:add_action(pos, "receptor_off", {rules}, nil, rules)
end

