// drop/throw item or swep with q
/*
hook.Add( "OnSpawnMenuOpen", "test", function()
    local ply = LocalPlayer()
    if !ply:Alive() then return end
    
end )
*/

local DROP_CODE = 27

local function DropItem()
    local ply = LocalPlayer()
    if !ply:Alive() then return end
    
    ply:ConCommand("gs_dropswep")
end
--[[
hook.Add("PlayerButtonDown", "drop_items", function( ply,code )
    if code == DROP_CODE then
        DropItem()
    end
end)
--]]

//hook.Add("PlayerButtonUp", "drop_items", function( ply,code ) end)