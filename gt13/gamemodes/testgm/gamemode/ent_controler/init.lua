GS_EntityControler = {}

AddCSLuaFile("sh_item_list.lua")

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
function GS_EntityControler:CreateAmmoArray(ammo_type, ammo_count) -- only for bullets, not shels
    local array = {}
    local bullet = Bullets_Type[ammo_type]

    for i = 0, i == ammo_count do
        table.insert(array, bullet)
    end
    
    return array
end


function GS_EntityControler:CreateFullMagazine(ent_mag, ammo_type, typ, pos, ang) -- 
    local mag = GS_EntityControler:MakeEntData("ent_mag", "ammo")

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
    -- dont some cool work
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
--]]
function EntityCanBeSpawned(ent)
    return true
end