include("item_pattern.lua")

GS_EntityControler = {}

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
    if ammo_name[name] == nil then 
        return
    end

    local ent = ammo_name[name]
    local entity = ents.Create( "gs_entity_base_item" )
    entity:SetPos(pos)
    entity:SetData(ent.Entity_Data)
    if ent.Private_Data then
        entity:SetPrivateData(ent.Private_Data)
    end
    entity:Spawn()

    PrintTable(entity:GetHandData())

end


--[[



]]

function GS_EntityControler:LoadMagazineFromAmmoBox(magazine, ammobox) -- ({Entity_Data,Private_Data},{Entity_Data,Private_Data})
    local me_data, mp_data = magazine.Entity_Data, magazine.Private_Data
    local be_data, bp_data = ammobox.Entity_Data, ammobox.Private_Data

    --type ammo test
    if !cantype(me_data.ENUM_Subtype, be_data.ENUM_Subtype) then
        return false
    end

    --full magazine
    if mp_data.Max_Bullets == #mp_data.AmmoInMagazine then
        return false
    end

    if be_data.AmmoInBox == 0 then
        return false
    end

    local bullet = bp_data.BulletDamage
    table.insert(mp_data.AmmoInMagazine, bullet)
    
    be_data.AmmoInBox = be_data.AmmoInBox - 1

    return true, {Entity_Data = me_data, Private_Data =  mp_data}, {Entity_Data = be_data, Private_Data = bp_data}
end