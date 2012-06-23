--register stoppers for movestones/pistons

mesecon.mvps_stoppers={}

function mesecon:is_mvps_stopper(nodename)
	local i=1
	repeat
		i=i+1
		if mesecon.mvps_stoppers[i]==nodename then return true end
	until mesecon.mvps_stoppers[i]==nil
	return false
end

function mesecon:register_mvps_stopper(nodename)
	local i=1
	repeat
		i=i+1
		if mesecon.mvps_stoppers[i]==nil then break end
	until false
	mesecon.mvps_stoppers[i]=nodename
end

function mesecon:mvps_push(pos, direction) -- pos: pos of mvps; direction: direction of push
		pos.x=pos.x+direction.x
		pos.y=pos.y+direction.y
		pos.z=pos.z+direction.z

		local lpos = {x=pos.x, y=pos.y, z=pos.z}
		local lnode = minetest.env:get_node(lpos)
		local newnode
		minetest.env:remove_node(lpos)
		while not(lnode.name == "ignore" or lnode.name == "air" or lnode.name == "default:water" or lnode.name == "default:water_flowing") do
			lpos.x=lpos.x+direction.x
			lpos.y=lpos.y+direction.y
			lpos.z=lpos.z+direction.z
			newnode = lnode
			lnode = minetest.env:get_node(lpos)
			minetest.env:add_node(lpos, newnode)
			nodeupdate(lpos)
		end
end

function mesecon:mvps_pull_all(pos, direction) -- pos: pos of mvps; direction: direction of pull
		local lpos = {x=pos.x-direction.x, y=pos.y-direction.y, z=pos.z-direction.z} -- 1 away
		local lnode = minetest.env:get_node(lpos)
		local lpos2 = {x=pos.x-direction.x*2, y=pos.y-direction.y*2, z=pos.z-direction.z*2} -- 2 away
		local lnode2 = minetest.env:get_node(lpos2)

		if lnode.name ~= "ignore" and lnode.name ~= "air" and lnode.name ~= "default:water" and lnode.name ~= "default:water_flowing" then return end
		if lnode2.name == "ignore" or lnode2.name == "air" or lnode2.name == "default:water" or lnode2.name == "default:water_flowing" then return end

		local oldpos = {x=lpos2.x+direction.x, y=lpos2.y+direction.y, z=lpos2.z+direction.z}
		repeat
			minetest.env:add_node(oldpos, {name=minetest.env:get_node(lpos2).name})
			nodeupdate(oldpos)
			oldpos = {x=lpos2.x, y=lpos2.y, z=lpos2.z}
			lpos2.x = lpos2.x-direction.x
			lpos2.y = lpos2.y-direction.y
			lpos2.z = lpos2.z-direction.z
			lnode = minetest.env:get_node(lpos2)
		until lnode.name=="air" or lnode.name=="ignore" or lnode.name=="default:water" or lnode.name=="default:water_flowing"
		minetest.env:remove_node(oldpos)
end

mesecon:register_mvps_stopper("default:chest")
mesecon:register_mvps_stopper("default:chest_locked")
mesecon:register_mvps_stopper("default:furnace")
