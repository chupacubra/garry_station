GS_EntityList = {}

// ENT.Category

function AddEntItem(data, name, base)
    print("Registering entity", name)
    
    if !data then return end
    if GS_EntityList[name] then
        GS_MSG(tostring(name) .." already added, rewriting")
    end

    if GS_EntityList[base] then
        local base = table.Copy(GS_EntityList[base])
        table.Merge(base, data)
        data = base
    end 

    GS_EntityList[name] = data
    PrintTable(GS_EntityList)
end

function RegisterEnts()
    local fol = GM.FolderName .. "/gamemode/ent_controller/list"
    local files, folders = file.Find(fol .. "/*", "LUA")
    
    for k, v in pairs(files) do
        if SERVER then
            AddCSLuaFile(fol.."/"..v)
        end
        include(fol.."/"..v)
    end
   
    // now folders, only one level deep
    for k, fold in pairs(folders) do
        local files, folders = file.Find(fol.."/"..fold.."/*", "LUA")

        for k, v in pairs(files) do
            if SERVER then
                AddCSLuaFile(fol.."/"..fold.."/"..v)
            end
            include(fol.."/"..fold.."/"..v)
        end
    end

    local ENT
    for ent_name, data in pairs(GS_EntityList) do
        ENT = {}
        
        ENT.Base = data.Base or "gs_entity"
        scripted_ents.Register(ENT, ent_name)
    end
end