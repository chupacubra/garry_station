AddCSLuaFile( "player_class/gs_human.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_service.lua" )
AddCSLuaFile( "sh_enum.lua" )
AddCSLuaFile( "client/cl_plyhud.lua" )
AddCSLuaFile( "client/cl_round.lua" )
AddCSLuaFile( "client/cl_context_menu.lua" )
AddCSLuaFile( "client/cl_stat.lua" )
AddCSLuaFile( "client/cl_hud_button.lua" )
AddCSLuaFile( "client/cl_corpse.lua" )
AddCSLuaFile( "client/cl_chemia.lua" )
AddCSLuaFile( "client/cl_task.lua" )
AddCSLuaFile( "client/cl_systems.lua" )
AddCSLuaFile( "client/derma/cl_roundstart.lua" )
AddCSLuaFile( "client/derma/cl_craft_menu.lua" )
AddCSLuaFile( "client/derma/cl_wires.lua" )
AddCSLuaFile( "client/cl_equip_config.lua" )
AddCSLuaFile( "client/computer_derma/cl_main.lua" )
AddCSLuaFile( "client/win98skin.lua" )


include( "shared.lua" )
include( "player.lua" )
include( "sh_enum.lua" )
include( "sh_service.lua" )
include( "map_controller/map_init.lua")
include( "ent_controler/init.lua" )
include( "concmd.lua" )
include( "net_string.lua" )
include( "chemical/sv_init.lua")
include( "derma_client_handler/init.lua" )
include( "global/sv_init.lua")
include( "resource.lua")

hook.Add("GS_PlayerDead", "MakePersonDead", function(plyID)
    GS_Round_System:AddDeadPly(plyID)
end)
--[[
local _print = print

function print(...)
    debug.Trace()
    _print(...)
end
--]]

