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
    end
end