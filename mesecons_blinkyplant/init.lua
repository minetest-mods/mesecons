-- The BLINKY_PLANT

local S = minetest.get_translator(minetest.get_current_modname())

local toggle_timer = function (pos)
	local timer = minetest.get_node_timer(pos)
	if timer:is_started() then
		timer:stop()
	else
		timer:start(mesecon.setting("blinky_plant_interval", 3))
	end
end

local on_timer = function (pos)
	local node = minetest.get_node(pos)
	if(mesecon.flipstate(pos, node) == "on") then
		mesecon.receptor_on(pos)
	else
		mesecon.receptor_off(pos)
	end
	toggle_timer(pos)
end

mesecon.register_node("mesecons_blinkyplant:blinky_plant", {
	description= S("Blinky Plant"),
	drawtype = "plantlike",
	inventory_image = "jeija_blinky_plant_off.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	sounds = mesecon.node_sound.leaves,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, -0.5+0.7, 0.3},
	},
	on_timer = on_timer,
	on_rightclick = function(pos, _, clicker)
		if minetest.is_protected(pos, clicker and clicker:get_player_name() or "") then
			return
		end

		toggle_timer(pos)
	end,
	on_construct = toggle_timer
},{
	tiles = {"jeija_blinky_plant_off.png"},
	groups = {dig_immediate=3},
	mesecons = {receptor = { state = mesecon.state.off }}
},{
	tiles = {"jeija_blinky_plant_on.png"},
	groups = {dig_immediate=3, not_in_creative_inventory=1},
	mesecons = {receptor = { state = mesecon.state.on }}
})

minetest.register_craft({
	output = "mesecons_blinkyplant:blinky_plant_off 1",
	recipe = {	{"","group:mesecon_conductor_craftable",""},
			{"","group:mesecon_conductor_craftable",""},
			{"group:sapling","group:sapling","group:sapling"}}
})
