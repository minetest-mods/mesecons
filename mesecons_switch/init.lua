local S = minetest.get_translator(minetest.get_current_modname())

-- mesecons_switch

mesecon.register_node("mesecons_switch:mesecon_switch", {
	paramtype2="facedir",
	description=S("Switch"),
	is_ground_content = false,
	sounds = mesecon.node_sound.stone,
	on_rightclick = function (pos, node)
		if(mesecon.flipstate(pos, node) == "on") then
			mesecon.receptor_on(pos)
		else
			mesecon.receptor_off(pos)
		end
		minetest.sound_play("mesecons_switch", { pos = pos }, true)
	end
},{
	groups = {dig_immediate=2},
	tiles = {	"mesecons_switch_side.png", "mesecons_switch_side.png",
				"mesecons_switch_side.png", "mesecons_switch_side.png",
				"mesecons_switch_side.png", "mesecons_switch_off.png"},
	mesecons = {receptor = { state = mesecon.state.off }}
},{
	groups = {dig_immediate=2, not_in_creative_inventory=1},
	tiles = {	"mesecons_switch_side.png", "mesecons_switch_side.png",
				"mesecons_switch_side.png", "mesecons_switch_side.png",
				"mesecons_switch_side.png", "mesecons_switch_on.png"},
	mesecons = {receptor = { state = mesecon.state.on }}
})

minetest.register_craft({
	output = "mesecons_switch:mesecon_switch_off 2",
	recipe = {
		{"mesecons_gamecompat:steel_ingot", "mesecons_gamecompat:cobble", "mesecons_gamecompat:steel_ingot"},
		{"group:mesecon_conductor_craftable","", "group:mesecon_conductor_craftable"},
	}
})
