minetest.swap_node = minetest.swap_node or function(pos, node)
	local data = minetest.get_meta(pos):to_table()
	minetest.add_node(pos, node)
	minetest.get_meta(pos):from_table(data)
end