function enable_door(idef,isOpen)
    if idef.mesecons then return end
    -- when the node is signaled it will simulate a rightclick
    -- which will replace the node with its open version
    -- the open version then responds when mesecons turns off!
    local on_rightclick = idef.on_rightclick;
	local function on_mesecons_signal (pos, node)
        on_rightclick(pos,node,nil);
    end

    if isOpen == nil then
        isOpen = string.sub(idef.name,-1)=='2' or string.sub(idef.name,-4) == 'open';
    end

    if isOpen then
        idef.mesecons = {effector = {
			action_off  = on_mesecons_signal
		}}
    else
        idef.mesecons = {effector = {
			action_on = on_mesecons_signal
		}}
    end
    minetest.register_node(':'..idef.name,idef);
end

-- this wrapper is so that future doors registered will be mesecon enabled too.
oldregister = doors.register_door
doors.register_door = function(doors,name,def) 
    def.door = 1 -- XXX: this should be set on register_door, upstream in the doors mod
    oldregister(doors,name,def)
    enable_door(name+"_b_1",false);
    enable_door(name+"_b_2",true);
end

-- this is to scan doors who have already registered under register_door 
-- before this module was loaded
for _,idef in pairs(minetest.registered_nodes) do
   if idef.groups.door then
       if string.sub(idef.name,-4,-3) == '_b' or string.sub(idef.name,7,14) == 'trapdoor' then
           -- cannot assign attributes to idef anymore, so just copy it to a table you can :p
           -- passing nil means it'll check the name for whether it's open or not
           enable_door(table.copy(idef))
       end
   end
end
