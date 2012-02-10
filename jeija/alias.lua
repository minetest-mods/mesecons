-- This file registers aliases for the /give /giveme commands.

minetest.register_alias("jeija:meselamp", "jeija:meselamp_off")
minetest.register_alias("jeija:mesecon", "jeija:mesecon_off")
minetest.register_alias("jeija:object_detector", "jeija:object_detector_off")
minetest.register_alias("jeija:wireless_inverter", "jeija:wireless_inverter_on")
minetest.register_alias("jeija:wireless_receiver", "jeija:wireless_receiver_off")
minetest.register_alias("jeija:wireless_transmitter", "jeija:wireless_transmitter_off")
minetest.register_alias("jeija:switch", "jeija:mesecon_switch_off")
minetest.register_alias("jeija:wall_button", "jeija:wall_button_off")
minetest.register_alias("jeija:piston", "jeija:piston_normal")
minetest.register_alias("jeija:blinky_plant", "jeija:blinky_plant_off")
minetest.register_alias("jeija:mesecon_torch", "jeija:mesecon_torch_on")
minetest.register_alias("jeija:hydro_turbine", "jeija:hydro_turbine_off")
minetest.register_alias("jeija:pressure_plate_stone", "jeija:pressure_plate_stone_off")
minetest.register_alias("jeija:pressure_plate_wood", "jeija:pressure_plate_wood_off")

if ENABLE_TEMPEREST==1 then
	minetest.register_alias("jeija:mesecon_socket", "jeija:mesecon_socket_off")
	minetest.register_alias("jeija:mesecon_inverter", "jeija:mesecon_inverter_on")
end