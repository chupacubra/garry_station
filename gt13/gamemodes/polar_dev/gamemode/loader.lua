local fol = GM.FolderName .. "/gamemode"
local files, folders = file.Find(fol .. "*", "LUA")


local subs, fn = "", ""
print("=======\nloading\n=======")

//local root = polar_dev 

local file_ignore = {
    ["polar_dev/gamemode/init.lua"] = true,
    ["polar_dev/gamemode/cl_init.lua"] = true,
    ["polar_dev/gamemode/loader.lua"] = true,
}

local folder_ignore = {
    ["polar_dev/gamemode"] = true,
    ["polar_dev/gamemode/player_class"] = true,
    ["polar_dev/gamemode/ent_controler/list"] = true,
}

function loadfiles(path, files) 
    for _, fil in ipairs(files) do
        if string.Left(fil, 1) == "!" then continue end
        subs = string.Left(fil, 3)
        fn = path.."/"..fil
        print(fn)
        if file_ignore[fn] then continue end
        
        if subs == "sh_" then
            if SERVER then
                AddCSLuaFile(fn)
            end
            include(fn)
        elseif subs == "cl_" then
            if SERVER then
                AddCSLuaFile(fn) 
            else
                include(fn)
            end
        elseif subs == "sv_" then
            if SERVER then
                include(fn)
            end
        end
    end
end
 
local i = 1

function recurs_dir_load(path)
    if i  > 20 then return end
    local files, folders = file.Find(path .. "/*", "LUA")

    if file.Exists( path.."/".."init.lua", "LUA" ) and !file_ignore[path.."/".."init.lua"] then
        // the folder have init.lua - spec loader
        if SERVER then 
            AddCSLuaFile(path.."/".."init.lua")
        end
        include(path.."/".."init.lua")
    else
        loadfiles(path, files)
    end

    for k, v in pairs(folders) do
        local new = path.."/"..v
        if folder_ignore[new] then continue end
        recurs_dir_load(path.."/"..v)
    end
    i = i + 1
end

recurs_dir_load(fol)
print("=========================")

concommand.Add("gs_reload", function()
    recurs_dir_load(fol)
end)