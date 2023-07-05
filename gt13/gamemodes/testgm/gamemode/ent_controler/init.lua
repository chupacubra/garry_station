GS_EntityControler = {}
GS_EntityList = {}

include("item_data_operations.lua")
include("sh_item_list.lua")
AddCSLuaFile("sh_item_list.lua")


--[[
for k,v in pairs(files) do
    include(v)
    AddCSLuaFile(v)
end
--]]
--[[
    WE NEED TO MAKE GS_EntityList SHARED
    
    and custom/base entity

    BASE entity:
        когда проп спавниться, на клиент отправляется пометка, что этот проп базовый,
        И все действия, связанные с получением каких либо Entity_Data данных ссылаются на GS_Entity_List

    CUSTOM entity:
        когда проп спавниться, на клиент отправляются полные данные о пропе

    Это больше относится к item
]]


function GS_EntityControler:MakeEntity2(name, typ, pos, ang)
    print(typ,name)
    PrintTable(GS_EntityList[typ])
    if !GS_EntityList[typ] then
        return
    elseif !GS_EntityList[typ][name] then
        return
    end
    print("spawning")
    local edata = table.Copy(GS_EntityList[typ][name])
    local entity = ents.Create(edata.entity_base or "gs_entity_base_item")
    
    entity:SetData(edata.Entity_Data)
    entity.Private_Data = edata.Private_Data
    entity.Examine_Data = edata.Examine_Data
    --[[
        
    entitys dont save this functions
    entity.GetFunctions = edata.GetFunctions
    entity.RunFunction  = edata.RunFunction

    --]]
    print(entity.GetFunctions)

    entity.Data_Labels = {
        id = name,
        type = typ,
    } 

    entity:SetPos(pos)
    entity:Spawn()
end

function GS_EntityControler:MakeEntity(etype,name,pos,ang)
    local entity = ents.Create( "gs_entity_vendomat" )
    entity:SetPos(pos)
    entity:Spawn()
end

function GS_EntityControler:MakeFromPattern(name,pos,ang)

end

function GS_EntityControler:MakeItem(etype, name, pos, ang)

end 
 
function GS_EntityControler:MakeAmmoBox(name,type,pos,ang)
    print(name)
    if ammo_name[name] == nil then 
        return
    end

    local ent = table.Copy(ammo_name[name])

    PrintTable(ent)
    
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

function GS_EntityControler:CreateFullMagazine(name,typ,pos,ang)
    local ent = fastMagazine(name, typ)
    print(ent)
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