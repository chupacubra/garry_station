--[[
    this module was created for syncing load for clients files
]]

PLAYER_LOAD = {}

function PLAYER_LOAD:StartLoading()
    self.Sync_Files = {
        gs_cl_equipment = false,
        hud_client      = false,
    }

    self.AllLoaded = false
end

function PLAYER_LOAD:ModuleLoaded(name)
    self.Sync_Files[name] = true

    -- check loaded files

    for k, v in pairs(self.Sync_Files) do
        if !v then
            return
        end
    end

    self.AllLoaded = true
end

function PLAYER_LOAD:PlayerLoaded()
    return self.AllLoaded
end

net.Receive("gs_ply_sync_load", function(_, ply)
    local modul = net.ReadString()

    player_manager.RunClass(ply, "ModuleLoaded", modul )
end)