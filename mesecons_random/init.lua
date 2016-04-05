­­ REMOVESTONE

minetest.register_node("mesecons_random:removestone", {

tiles = {"jeija_removestone.png"},

inventory_image = minetest.inventorycube("jeija_removestone_inv.png"),

groups = {cracky=3},

description="Removestone",

sounds = default.node_sound_stone_defaults(),

mesecons = {effector = {

action_on = function (pos, node)

end

}}

})

minetest.register_craft({

output = 'mesecons_random:removestone 4',

recipe = {

{"", "default:cobble", ""},

{"default:cobble", "group:mesecon_conductor_craftable", "default:cobble"},

{"", "default:cobble", ""},

}

})

­­ GHOSTSTONE

minetest.register_node("mesecons_random:ghoststone", {

description="ghoststone",

tiles = {"jeija_ghoststone.png"},

is_ground_content = true,

inventory_image = minetest.inventorycube("jeija_ghoststone_inv.png"),

groups = {cracky=3},

sounds = default.node_sound_stone_defaults(),

mesecons = {conductor = {

state = mesecon.state.off,

rules = { ­­axes

},

onstate = "mesecons_random:ghoststone_active"

}}

})

minetest.register_node("mesecons_random:ghoststone_active", {

drawtype = "airlike",

pointable = false,

walkable = false,

diggable = false,

sunlight_propagates = true,

paramtype = "light",

mesecons = {conductor = {

state = mesecon.state.on,

rules = {

},

offstate = "mesecons_random:ghoststone"

}},

on_construct = function(pos)

­­ remove shadow

shadowpos = vector.add(pos, vector.new(0, 1, 0))

if (minetest.get_node(shadowpos).name == "air") then

end

end

})

minetest.register_craft({

output = 'mesecons_random:ghoststone 4',

recipe = {

{"default:steel_ingot", "default:cobble", "default:steel_ingot"},

{"default:cobble", "group:mesecon_conductor_craftable", "default:cobble"},

{"default:steel_ingot", "default:cobble", "default:steel_ingot"},

}

})


minetest.register_node("mesecons_random:woodghoststone", {

description=" wood ghoststone",

tiles = {"default_wood.png"},

is_ground_content = true,

groups = {cracky=3},

sounds = default.node_sound_stone_defaults(),

mesecons = {conductor = {

state = mesecon.state.off,

rules = { ­­axes

},

onstate = "mesecons_random:woodghoststone_active"

}}

})

minetest.register_node("mesecons_random:woodghoststone_active", {

drawtype = "airlike",

pointable = false,

walkable = false,

diggable = false,

sunlight_propagates = true,

paramtype = "light",

mesecons = {conductor = {

state = mesecon.state.on,

rules = {

},

offstate = "mesecons_random:woodghoststone"

}},

on_construct = function(pos)

­­ remove shadow

shadowpos = vector.add(pos, vector.new(0, 1, 0))

if (minetest.get_node(shadowpos).name == "air") then

end

end

})

minetest.register_craft({

output = 'mesecons_random:woodghoststone 1',

recipe = {

{"mesecons_random:ghoststone" , "default:wood"},

}

})

minetest.register_node("mesecons_random:cobbleghoststone", {

description=" cobble ghoststone",

tiles = {"default_cobble.png"},

is_ground_content = true,

groups = {cracky=3},

sounds = default.node_sound_stone_defaults(),

mesecons = {conductor = {

state = mesecon.state.off,

rules = { ­­axes

},

onstate = "mesecons_random:woodghoststone_active"

}}

})

minetest.register_node("mesecons_random:cobbleghoststone_active", {

drawtype = "airlike",

pointable = false,

walkable = false,

diggable = false,

sunlight_propagates = true,

paramtype = "light",

mesecons = {conductor = {

state = mesecon.state.on,

rules = {

},

offstate = "mesecons_random:woodghoststone"

}},

on_construct = function(pos)

­­ remove shadow

shadowpos = vector.add(pos, vector.new(0, 1, 0))

if (minetest.get_node(shadowpos).name == "air") then

end

end

})

minetest.register_craft({

output = 'mesecons_random:cobbleghoststone 1',

recipe = {

{"mesecons_random:ghoststone" , "default:cobble"},

}

})
