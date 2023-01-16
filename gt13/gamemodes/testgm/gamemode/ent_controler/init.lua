GS_EntityControler = {}

include("item_ammo.lua")
include("item_data_operations.lua")

 
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

