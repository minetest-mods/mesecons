local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_node("mesecons_noteblock:noteblock", {
	description = S("Noteblock"),
	tiles = {"mesecons_noteblock.png"},
	is_ground_content = false,
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2},
	on_punch = function(pos, node, puncher) -- change sound when punched
		if minetest.is_protected(pos, puncher and puncher:get_player_name() or "") then
			return
		end

		node.param2 = (node.param2+1)%12
		mesecon.noteblock_play(pos, node.param2)
		minetest.set_node(pos, node)
	end,
	sounds = mesecon.node_sound.wood,
	mesecons = {effector = { -- play sound when activated
		action_on = function(pos, node)
			mesecon.noteblock_play(pos, node.param2)
		end
	}},
	place_param2 = 11, -- initialize at C note
	on_blast = mesecon.on_blastnode,
})

minetest.register_craft({
	output = "mesecons_noteblock:noteblock 1",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:mesecon_conductor_craftable", "mesecons_gamecompat:steel_ingot", "group:mesecon_conductor_craftable"},
		{"group:wood", "group:wood", "group:wood"},
	}
})

local soundnames = {
	[0] = "mesecons_noteblock_csharp",
	"mesecons_noteblock_d",
	"mesecons_noteblock_dsharp",
	"mesecons_noteblock_e",
	"mesecons_noteblock_f",
	"mesecons_noteblock_fsharp",
	"mesecons_noteblock_g",
	"mesecons_noteblock_gsharp",

	"mesecons_noteblock_a",
	"mesecons_noteblock_asharp",
	"mesecons_noteblock_b",
	"mesecons_noteblock_c" -- << noteblock is initialized here
}

local node_sounds = {}
for alias, sound in pairs({
	["mesecons_gamecompat:lava_source"] = mesecon.sound_name.fire,
	["mesecons_gamecompat:water_source"] = "mesecons_noteblock_bubble",
	["mesecons_gamecompat:river_water_source"] = "mesecons_noteblock_bubble",
	["mesecons_gamecompat:chest"] = "mesecons_noteblock_snare",
	["mesecons_gamecompat:chest_locked"] = "mesecons_noteblock_snare",
	["mesecons_gamecompat:coalblock"] = mesecon.sound_name.explode,
	["mesecons_gamecompat:goldblock"] = "mesecons_noteblock_bell",
	["mesecons_gamecompat:copperblock"] = "mesecons_noteblock_cowbell",
	["mesecons_gamecompat:bronzeblock"] = "mesecons_noteblock_gong",
	["mesecons_gamecompat:tinblock"] = "mesecons_noteblock_xylophone_metal",
	["mesecons_gamecompat:diamondblock"] = "mesecons_noteblock_squarewave",
	["mesecons_gamecompat:silver_sandstone_brick"] = "mesecons_noteblock_chorus",
	["mesecons_gamecompat:sandstone"] = "mesecons_noteblock_sticks",
	["mesecons_gamecompat:silver_sandstone"] = "mesecons_noteblock_sticks",
	["mesecons_gamecompat:desert_sandstone"] = "mesecons_noteblock_sticks",
	["mesecons_gamecompat:glass"] = "mesecons_noteblock_hihat",
	["mesecons_gamecompat:obsidian_glass"] = "mesecons_noteblock_hihat",
	["mesecons_gamecompat:obsidian"] = "mesecons_noteblock_bass_drum",
	["mesecons_gamecompat:obsidian_block"] = "mesecons_noteblock_bass_drum",
	["mesecons_gamecompat:obsidianbrick"] = "mesecons_noteblock_bass_drum",
	["mesecons_gamecompat:straw"] = "mesecons_noteblock_banjo",
	["mesecons_gamecompat:meselamp"] = "mesecons_noteblock_piano_digital",
	["mesecons_gamecompat:coral_skeleton"] = "mesecons_noteblock_xylophone_wood",
	["mesecons_gamecompat:bones"] = "mesecons_noteblock_xylophone_wood",
	["mesecons_gamecompat:cactus"] = "mesecons_noteblock_didgeridoo",
	["mesecons_gamecompat:gravel"] = "mesecons_noteblock_bass_guitar",
	["mesecons_gamecompat:ice"] = "mesecons_noteblock_chime",
	["mesecons_gamecompat:cave_ice"] = "mesecons_noteblock_chime",
	["mesecons_gamecompat:vessels_shelf"] = "mesecons_noteblock_glass",
}) do
	local nodename = minetest.registered_aliases[alias]
	if nodename then
		node_sounds[nodename] = sound
	end
end

local node_sounds_group = {
	["stone"] = "mesecons_noteblock_kick",
	["tree"] = "mesecons_noteblock_crash",
	["wood"] = "mesecons_noteblock_litecrash",
	["sand"] = "mesecons_noteblock_hit",
	["wool"] = "mesecons_noteblock_guitar",
	["leaves"] = "mesecons_noteblock_flute",
}

local steelblock_nodename = minetest.registered_aliases["mesecons_gamecompat:steelblock"]
mesecon.noteblock_play = function(pos, param2)
	pos.y = pos.y-1
	local nodeunder = minetest.get_node(pos).name
	local soundname = node_sounds[nodeunder]
	local use_pitch = true
	local pitch
	-- Special sounds
	if not soundname then
		for k,v in pairs(node_sounds_group) do
			local g = minetest.get_item_group(nodeunder, k)
			if g ~= 0 then
				soundname = v
				break
			end
		end
	end
	-- Piano
	if not soundname then
		soundname = soundnames[param2]
		if not soundname then
			minetest.log("error", "[mesecons_noteblock] No soundname found, test param2")
			return
		end
		if nodeunder == steelblock_nodename then
			soundname = soundname.. 2
		end
		use_pitch = false
	end
	-- Disable pitch for fire and explode because they'd sound too odd
	if soundname == "fire_fire" or soundname == "tnt_explode" then
		use_pitch = false
	end
	if use_pitch then
		-- Calculate pitch
		-- Adding 1 to param2 because param2=11 is *lowest* pitch sound
		local val = (param2+1)%12
		pitch = 2^((val-6)/12)
	end
	pos.y = pos.y+1
	if soundname == "fire_fire" then
		-- Smoothly fade out fire sound
		local handle = minetest.sound_play(soundname, {pos = pos, loop = true})
		minetest.after(3.0, minetest.sound_fade, handle, -1.5, 0.0)
	else
		minetest.sound_play(soundname, {pos = pos, pitch = pitch}, true)
	end
end
