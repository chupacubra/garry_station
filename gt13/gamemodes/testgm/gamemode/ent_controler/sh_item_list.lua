local files = {
    "item_base_examine.lua",
    "item_ammo.lua",
    "item_box_ammo.lua",
    "item_containers.lua",
    "ent_containers.lua",
    "item_board.lua",
    "item_res.lua",
    "item_common.lua",
    "equip_simple_accessories.lua",
    "map_entity_context.lua",
    "id_generator.lua", 
}

GS_EntityList = {}
GS_FastDataLabels = {}

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

if SERVER then
    for k, v in pairs(files) do
        include(v)
        AddCSLuaFile(v)
    end
else
    for k, v in pairs(files) do
        include(v)
    end
end

for k, v in pairs(GS_EntityList) do
    if type(v) != "table" then
        continue
    end
    for kk, vv in pairs(v) do
        local ENT = {}
        if !vv then continue end
        ENT.Base = vv.entity_base or "gs_entity_base_item"
        ENT.Private_Data = vv.Private_Data
        ENT.Entity_Data  = vv.Entity_Data
        ENT.Data_Labels  = {type = k, id = kk}
        scripted_ents.Register( ENT, "gs_item_"..k.."_"..kk )
        GS_FastDataLabels["gs_item_"..k.."_"..kk] = ENT.Data_Labels
    end
end