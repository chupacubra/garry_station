-- I NEED TO TEST THIS
-- Because is beatifuleee and give some info about init time
_include = include

function include(file)
    --debug.Trace()
    --local startload = SysTime()
    _include(file)
    MsgC(Color(66,170,255), "[GS] LOAD:\t"..file.. "\n")
end

local ART = {
{"\n\n"},
{Color(255,255,255), "\t"..[[     ____ ]].."\n"},
{Color(255,255,255), "\t"..[[    /\  _`\]].."\n"},
{Color(255,255,255), "\t"..[[    \ \ \L\_\     __     _ __   _ __   __  __    _      ____]].."\n"},    
{Color(255,255,255), "\t"..[[     \ \ \L_L   /'__`\  /\`'__\/\`'__\/\ \/\ \  /\_\  /',__\]].."\n"},  
{Color(255,255,255), "\t"..[[      \ \ \/, \/\ \L\.\_\ \ \/ \ \ \/ \ \ \_\ \ \/_/ /\__, `\]].."\n"},
{Color(255,255,255), "\t"..[[       \ \____/\ \__/.\_\\ \_\  \ \_\  \/`____ \     \/\____/]].."\n"},
{Color(255,255,255), "\t"..[[        \/___/  \/__/\/_/ \/_/   \/_/   `/___/> \     \/___/]].."\n"},
{Color(255,255,255), "\t"..[[                                           /\___/]].."\n"},
{Color(255,255,255), "\t"..[[                                           \/__/]].."\n"},
{Color(255,255,255), "\t"..[[ ____    __             __                            ]],Color(255,25,25),[[   _     __     ]].."\n"},
{Color(255,255,255), "\t"..[[/\  _`\ /\ \__         /\ \__  __                     ]],Color(255,25,25),[[ /' \  /'__`\   ]].."\n"},
{Color(255,255,255), "\t"..[[\ \,\L\_\ \ ,_\    __  \ \ ,_\/\_\    ___     ___     ]],Color(255,25,25),[[/\_, \/\_\L\ \  ]].."\n"},
{Color(255,255,255), "\t"..[[ \/_\__ \\ \ \/  /'__`\ \ \ \/\/\ \  / __`\ /' _ `\   ]],Color(255,25,25),[[\/_/\ \/_/_\_<_ ]].."\n"},
{Color(255,255,255), "\t"..[[   /\ \L\ \ \ \_/\ \L\.\_\ \ \_\ \ \/\ \L\ \/\ \/\ \  ]],Color(255,25,25),[[   \ \ \/\ \L\ \]].."\n"},
{Color(255,255,255), "\t"..[[   \ `\____\ \__\ \__/.\_\\ \__\\ \_\ \____/\ \_\ \_\ ]],Color(255,25,25),[[    \ \_\ \____/]].."\n"},
{Color(255,255,255), "\t"..[[    \/_____/\/__/\/__/\/_/ \/__/ \/_/\/___/  \/_/\/_/ ]],Color(255,25,25),[[     \/_/\/___/ ]].."\n"},
{"\n\n"},
}                                                         

for _, v in pairs(ART) do
    MsgC(unpack(v))
end

ART = nil
local startload = SysTime()

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

MsgC(Color(66,170,255), "[GS] Modules loaded in ".. tostring(math.Round( SysTime() - startload, 3)).."\n")

AddCSLuaFile( "player_class/gs_human.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_service.lua" )
AddCSLuaFile( "sh_enum.lua" )
AddCSLuaFile( "jobs_system/init.lua")
AddCSLuaFile( "paperwork_system/init.lua" )
AddCSLuaFile( "paperwork_system/stamps.lua" )
AddCSLuaFile( "paperwork_system/bbc.lua" )
AddCSLuaFile( "paperwork_system/cl_derma.lua" )
AddCSLuaFile( "client/cl_plyhud.lua" )
AddCSLuaFile( "client/cl_round.lua" )
AddCSLuaFile( "client/cl_notes.lua" )

AddCSLuaFile( "client/cl_context_topbar.lua" )
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


local startload = SysTime()

MsgC(Color(66,170,255), "[GS] GS13 initialize, load server files\n\n")

include = _include

MsgC(Color(66,170,255), "[GS] Modules loaded in ".. tostring(math.Round( SysTime() - startload, 3)).."\n")

--[[
    we need this global value
    
    GameTime    - start game, server start
    RoundStatus - wait ply or already round end
    EvacTimer
    BombTimer
]]--

function GM:Initialize()
    SetGlobalInt("GameTime", math.floor(CurTime()))
    GS_Round_System:InitGame()
end

hook.Add("GS_PlayerDead", "MakePersonDead", function(plyID)
    GS_Round_System:AddDeadPly(plyID)
end)
 
function GM:AllowPlayerPickup( ply, ent )
    return true
end
