GS_EntityControler = {}
GS_EntityList = {}

include("item_base_examine.lua")
include("item_data_operations.lua")
include("item_ammo.lua")
include("item_containers.lua")
include("ent_containers.lua")
include("item_board.lua")
include("item_res.lua")
include("item_common.lua")


function GS_EntityControler:MakeEntity2(name, typ, pos, ang)
    print(typ,name)
    PrintTable(GS_EntityList[typ])
    if !GS_EntityList[typ] then
        return false
    elseif !GS_EntityList[typ][name] then
        return false
    end
    print("spawning")
    local edata = table.Copy(GS_EntityList[typ][name])
    local entity = ents.Create(edata.entity_base or "gs_entity_base_item")

    if edata.Entity_Data then
        entity:SetData(edata.Entity_Data)
    end 

    if edata.Private_Data then
        entity.Private_Data = edata.Private_Data
    end

    if edata.Examine_Data then
        entity.Examine_Data = edata.Examine_Data
    end
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

