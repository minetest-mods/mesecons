
local halfpi = math.pi / 2
local facedir_to_rot = {
[0]=vector.new(0, 0, 0) * halfpi,
	vector.new(0, 3, 0) * halfpi,
	vector.new(0, 2, 0) * halfpi,
	vector.new(0, 1, 0) * halfpi,
	vector.new(3, 1, 1) * halfpi,
	vector.new(2, 1, 1) * halfpi,
	vector.new(1, 1, 1) * halfpi,
	vector.new(0, 1, 1) * halfpi,
	vector.new(1, 3, 1) * halfpi,
	vector.new(0, 3, 1) * halfpi,
	vector.new(3, 3, 1) * halfpi,
	vector.new(2, 3, 1) * halfpi,
	vector.new(0, 0, 1) * halfpi,
	vector.new(3, 0, 1) * halfpi,
	vector.new(2, 0, 1) * halfpi,
	vector.new(1, 0, 1) * halfpi,
	vector.new(2, 2, 1) * halfpi,
	vector.new(1, 2, 1) * halfpi,
	vector.new(0, 2, 1) * halfpi,
	vector.new(3, 2, 1) * halfpi,
	vector.new(0, 0, 2) * halfpi,
	vector.new(0, 1, 2) * halfpi,
	vector.new(0, 2, 2) * halfpi,
	vector.new(0, 3, 2) * halfpi,
}

-- dirname: "U" | "D" | "L" | "R" | "F" | "B"

local lib = {}

local rotate_dirname_facedir_LUT = {
	U = {},
	D = {},
	R = {},
	L = {},
	F = {},
	B = {},
}

local rotate_dirname_facedir_inverse_LUT = {
	U = {},
	D = {},
	R = {},
	L = {},
	F = {},
	B = {},
}

local rotate_dirname_facedir_dir_LUT = {
	U = {},
	D = {},
	R = {},
	L = {},
	F = {},
	B = {},
}

local rotate_dirname_facedir_inverse_dir_LUT = {
	U = {},
	D = {},
	R = {},
	L = {},
	F = {},
	B = {},
}

local dirtable = {
	U = vector.new(0,1,0),
	D = vector.new(0,-1,0),
	R = vector.new(1,0,0),
	L = vector.new(-1,0,0),
	F = vector.new(0,0,1),
	B = vector.new(0,0,-1),
}

local dir_to_vec = function(dirname)
	return vector.copy(dirtable[dirname])
end

local vec_to_dir = function(dir)
	if dir.z > 0.5 then return "F"
	elseif dir.z < -0.5 then return "B"
	elseif dir.x > 0.5 then return "R"
	elseif dir.x < -0.5 then return "L"
	elseif dir.y > 0.5 then return "U"
	else return "D"
	end
end

for dirname, invec in pairs(dirtable) do
	for facedir, rotation in pairs(facedir_to_rot) do
		local outvec = vector.rotate(invec, rotation)
		local outdir = vec_to_dir(outvec)
		rotate_dirname_facedir_LUT[dirname][facedir] = outvec
		rotate_dirname_facedir_inverse_LUT[outdir][facedir] = invec
		rotate_dirname_facedir_dir_LUT[dirname][facedir] = outdir
		rotate_dirname_facedir_inverse_dir_LUT[outdir][facedir] = dirname
	end
end

lib.dir_to_vec = dir_to_vec
lib.vec_to_dir = vec_to_dir
lib.rotate_dirname_facedir = function(dirname, facedir)
	return rotate_dirname_facedir_dir_LUT[dirname][facedir]
end
lib.rotate_dirname_facedir_inverse = function(dirname, facedir)
	return rotate_dirname_facedir_inverse_dir_LUT[dirname][facedir]
end
lib.rotate_dirname_facedir_to_vector = function(dirname, facedir)
	return vector.copy(rotate_dirname_facedir_LUT[dirname][facedir])
end
lib.rotate_dirname_facedir_inverse_to_vector = function(dirname, facedir)
	return vector.copy(rotate_dirname_facedir_inverse_LUT[dirname][facedir])
end
lib.rotate_facedir = function(v, facedir)
	return vector.rotate(v, facedir_to_rot[facedir])
end

return lib
