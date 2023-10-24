GS_EntityControler = {}
GS_EntityList = {}

AddCSLuaFile("sh_item_list.lua")

include("item_data_operations.lua")
include("sh_item_list.lua")

function GS_EntityControler:MakeEntity(name, typ, pos)
    print(typ,name)
    PrintTable(GS_EntityList[typ])

    if !GS_EntityList[typ] then
        return
    elseif !GS_EntityList[typ][name] then
        return
    end

    print("spawning")
    --local edata = table.Copy(GS_EntityList[typ][name])
    local entity = ents.Create("gs_item_"..typ.."_"..name)

    entity:SetPos(pos)
    entity:Spawn()
    
    PrintTable(entity.Data_Labels)

    return entity
end
--[[
function GS_EntityControler:CreateFullMagazine(name,typ,pos,ang) -- old but need
    local ent = fastMagazine(name, typ)
    
    if !ent then
        return
    end

    local entity = ents.Create( "gs_entity_base_item" )
    entity:SetPos(pos)
    entity:SetData(ent.Entity_Data)
     
    if ent.Private_Data then
        entity:SetPrivateData(ent.Private_Data)
    end

    if ent.Examine_Data then
        entity:SetExamineData(ent.Examine_Data)
    end

    entity:Spawn()
end
--]]




function GS_EntityControler:CreateFullMagazine(name, typ, pos, ang)

end

function GS_EntityControler.GetFunctionsEntity(id, typ, entity, ply, context)
    local getfunc = GS_EntityList[typ][id]["GetFunctions"]

    if !getfunc then
        return
    end

    local tbl = getfunc(entity, ply, context)

    return tbl
end

function GS_EntityControler.RunFunctionEntity(action, id, typ, entity, ply, context)
    local runfunc = GS_EntityList[typ][id]["RunFunction"]

    if !runfunc then
        return false
    end

    local rez = runfunc(action, entity, ply, context)

    return rez
end

function EntityCanBeSpawned(ent) -- check ent model out of bounds
    local pos = {ent:OBBCenter(),  ent:OBBMaxs(),  ent:OBBMins()}

    PrintTable(pos)
    debugoverlay.Cross( pos[1], 1, 5)
    debugoverlay.Cross( pos[2], 1, 5)
    debugoverlay.Cross( pos[3], 1, 5)

    for k, v in pairs(pos) do
        if !util.IsInWorld(v) then
            return false
        end
    end
    return true
end