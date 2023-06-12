gs_map = {}

include("gm_ijm_boreas/init.lua")
DIRECTORY = "addons/gt13/gamemodes/testgm/gamemode/map_controller"

function gs_map.load()
    local current_map = game.GetMap()
    --include(current_map.."/".."init.lua")
    --local _, maps = file.Find( DIRECTORY .. "*", "LUA" )
    --print(current_map, maps)
    --PrintTable(maps)
    --PrintTable(_)
    --print(current_map.."/".."init.lua") 
    --if table.HasValue( maps, current_map ) then
    --    local succes , err = pcall(include, current_map.."/".."init.lua")
    --    print(succes) 
        --[[if succes then 
            GS_MSG("Map load succes!")
            return true
        else
            GS_MSG("The config of this map have the error! => "..err)
            return false
        end--]]
    --else
    --    GS_MSG("THE SERVER DO NOT HAVE THE CONFIG OF THIS MAP! FATAL!")
    --    return false
    --end 
    return true 
end 

function gs_map.use_entity(ply, ent)
    ent:Fire( "Use", "nil", 0, ply)
end

function gs_map.run_map_func(name, caller, ply)
    -- caller - is entity (computer, machine)
    -- caller
    
end

function gs_map.prestart_spawn_entity()

end

function gs_map.wire_action(ply, ent, wire, action)
    -- now action can be maked only for keypad
    if gs_map.get_context_type_entity(ent) != "keypad" then
        print(ply,wire,ent, "KEYPAD WIRE", action)
    end
end

function gs_map.get_context_type_entity(entity)
    -- simple check in tables
    -- keypad/door/airlock/button
    -- prop dont have the context
    
    if !entity:CreatedByMap() then
        return false
    end

    --check in keypads
    local e_id = entity:EntIndex()
    print(e_id)
    if MAP.keydoor_list[e_id] then
        return "keypad"
    end
end

function gs_map.examine_ent(ply, entity)
    local typ = gs_map.get_context_type_entity(entity)

    local exam = MAP:GetExamineEntity(entity, typ)

    for k,v in pairs(exam) do
        if k == 1 then
            ply:ChatPrint("It's a "..v)
        else
            ply:ChatPrint(v)
        end
    end
end

function gs_map.ent_make_action(ply, ent, act)
    if !ent:CreatedByMap() then
        return
    end
    
    if act == A_EXAMINE then
        gs_map.examine_ent(ply, ent)
    elseif act == A_USE then
        gs_map.use_entity(ply, ent)
    end
end


net.Receive("gs_wire_action", function(_, ply)
    local entity = net.ReadEntity()
    local action = net.ReadUInt(2)
    local wire   = net.ReadUInt(4)

    if !entity:CreatedByMap() then
        --wtf
        return
    end

    gs_map.wire_action(ply, entity, wire, action)
end)

net.Receive("gs_map_ent_action", function(_, ply)
    local ent = net.ReadEntity()
    local act = net.ReadUInt(4)
    
    gs_map.ent_make_action(ply, ent, act)
end)

net.Receive("gs_map_entity_get_type", function(_, ply)
    local entity = net.ReadEntity()
    print("122312", entity)
    if !entity:CreatedByMap() then
        return
    end

    local context = gs_map.get_context_type_entity(entity)
    print(context)
    if context then
        net.Start("gs_map_entity_get_type")
        net.WriteEntity(entity)
        net.WriteString(context)
        net.Send(ply)
    end
end)