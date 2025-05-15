local CODE_MENU = KEY_I

local function getSpawnList()
    local items = {}

    for class, data in pairs(GS_EntityList) do
        if data.Spawnable == false then continue end

        local categ = data.Category or "Other" 
    end
end

function SpawnMenu(open)
    print("123")
    
    PrintTable(GS_EntityList)
end
--[[
hook.Add("PlayerButtonDown", "SpawnMenu", function( ply,code )
//    print(ply, code)
    if code == CODE_MENU then
        SpawnMenu(true) 
    end
end)

hook.Add("PlayerButtonUp", "drop_items", function( ply,code ) 
    if code == CODE_MENU then
        SpawnMenu(false) 
    end
end)
--]]