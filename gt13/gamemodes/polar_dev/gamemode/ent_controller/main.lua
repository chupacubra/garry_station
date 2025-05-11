GS_EntityList = {}

function AddItem(ENT, name, base) 
    if !ENT then return end
    if GS_EntityList[name] then
        GS_MSG(tostring(name) .." already added, rewriting")
    end

    if GS_EntityList[base] then
        local base = table.Copy(GS_EntityList[base])
        table.Merge(base, ENT)
        ENT = base
    end

    GS_EntityList[name] = data
end

function RegisterEnts()
    local fol = GM.FolderName .. "/gamemode/testgm/ent_contoler/list"
    local files, folders = file.Find(fol .. "*", "LUA")
    
    for k, v in pairs(files) do
        if SERVER then
            AddCSLuaFile("items_list/"..v)
        end
        include("items_list/"..v)
    end
    
    local ENT
    for ent_name, data in pairs(GS_EntityList) do
        ENT = {}
        
        ENT.Base = data.Base or "gs_entity"
        scripted_ents.Register(ENT, ent_name)
    end
end