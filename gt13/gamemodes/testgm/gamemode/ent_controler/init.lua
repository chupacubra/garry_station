GS_EntityControler = {}
GS_EntityList = {}

include("item_data_operations.lua")
include("sh_item_list.lua")
AddCSLuaFile("sh_item_list.lua")

function AddEquipment(typ, name, data, drawdata)
    if !typ or !name or !data or !drawdata then
        GS_MSG("Cant create equipment, invalid arguments!")
        return
    end

    if !GS_EntityList[typ] then GS_EntityList[typ] = {} end
    GS_EntityList[typ][name] = data
    
    if CLIENT and drawdata then
        if !cl_equip_config then cl_equip_config = {} end
        cl_equip_config[data.Entity_Data.Model] = drawdata
    end
end

function AddItem(typ, name, data)
    if !typ or !name or !data or !drawdata then
        GS_MSG("Cant create equipment, invalid arguments!")
        return
    end

    if !GS_EntityList[typ] then GS_EntityList[typ] = {} end
    GS_EntityList[typ][name] = data
end

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

function GS_EntityControler:MakeFromPattern(name,pos,ang)

end

function GS_EntityControler:MakeItem(etype, name, pos, ang)

end 
 
function GS_EntityControler:MakeAmmoBox(name,type,pos,ang) -- old
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

function GS_EntityControler:CreateFullMagazine(name,typ,pos,ang) -- old but need
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