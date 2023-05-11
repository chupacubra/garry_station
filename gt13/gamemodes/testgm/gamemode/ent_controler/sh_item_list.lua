local files = {
    "item_base_examine.lua",
    "item_ammo.lua",
    "item_containers.lua",
    "ent_containers.lua",
    "item_board.lua",
    "item_res.lua",
    "item_common.lua",
}

GS_EntityList = {}

if SERVER then
    for k, v in pairs(files) do
        include(v)
        print("wtf")
        AddCSLuaFile(v)
    end
else
    for k, v in pairs(files) do
        include(v)
    end
end