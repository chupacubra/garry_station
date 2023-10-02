AddCSLuaFile( "player_class/gs_human.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_service.lua" )
AddCSLuaFile( "sh_enum.lua" )
AddCSLuaFile( "jobs_system/init.lua")
AddCSLuaFile( "client/cl_plyhud.lua" )
AddCSLuaFile( "client/cl_round.lua" )
AddCSLuaFile( "client/cl_context_menu.lua" )
AddCSLuaFile( "client/cl_stat.lua" )
AddCSLuaFile( "client/cl_hud_button.lua" )
AddCSLuaFile( "client/cl_corpse.lua" )
AddCSLuaFile( "client/cl_chemia.lua" )
AddCSLuaFile( "client/cl_task.lua" )
AddCSLuaFile( "client/cl_systems.lua" )
AddCSLuaFile( "client/cl_armory.lua" )
AddCSLuaFile( "client/derma/cl_roundstart.lua" )
AddCSLuaFile( "client/derma/cl_craft_menu.lua" )
AddCSLuaFile( "client/derma/cl_wires.lua" )
AddCSLuaFile( "client/cl_equip_config.lua" )
AddCSLuaFile( "client/cl_equip_func.lua" )
AddCSLuaFile( "client/computer_derma/cl_main.lua" )
AddCSLuaFile( "client/win98skin.lua" )
AddCSLuaFile( "client/cl_ply_models.lua" )

include( "shared.lua" )
include( "sv_service.lua")
include( "player.lua" )
include( "sh_enum.lua" )
include( "sh_service.lua" )
include( "map_controller/map_init.lua" )
include( "ent_controler/init.lua" )
include( "concmd.lua" )
include( "net_string.lua" )
include( "chemical/sv_init.lua" )
include( "derma_client_handler/init.lua" )
include( "global/sv_init.lua" )
include( "resource.lua" )
include( "jobs_system/init.lua" )
include( "client/cl_ply_models.lua" )

--[[
    we need this global value
    
    GameTime - start game, server start
    RoundStatus - wait ply or already round end
    EvacTimer
    BombTimer
]]--

function GM:Initialize()
    SetGlobalInt("GameTime", math.floor(CurTime()))
end

hook.Add("GS_PlayerDead", "MakePersonDead", function(plyID)
    GS_Round_System:AddDeadPly(plyID)
end)
 
function GM:AllowPlayerPickup( ply, ent )
    return true
end
