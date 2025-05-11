PLAYER_SYNC = {}
// replacement for cl_stat.lua
if SERVER then
    util.AddNetworkString("gs_class_health_sync")
end

function PLAYER_SYNC:SyncHealth()
    if SERVER then
        
    else

    end
end

function PLAYER_SYNC:SyncHealthPart(part)
    if SERVER then
        
    else

    end
end


if CLIENT then
    net.Receive("gs_class_health_sync", function()
        local ply = net.ReadPlayer()
        player_manager.RunClass(ply, "SyncHealth")
    end)
end