include("shared.lua")
include("sh_enum.lua")
include("sh_service.lua")
include("jobs_system/init.lua")
include("client/cl_round.lua") 
include("client/cl_hud_button.lua")
include("client/cl_plyhud.lua")
include("client/cl_context_topbar.lua")
include("client/cl_context_menu.lua")
include("client/cl_stat.lua")
include("client/cl_systems.lua")
include("client/derma/cl_craft_menu.lua")
include("client/derma/cl_roundstart.lua")
include("client/derma/cl_wires.lua")
include("ent_controler/sh_item_list.lua")
include("client/cl_equip_config.lua")
include("client/cl_equip_func.lua") 
include("client/cl_armory.lua")
include("client/computer_derma/cl_main.lua")
include("client/win98skin.lua")
include("client/cl_ply_models.lua")

local hide = {
	["CHudHealth"]  = true,
	["CHudBattery"] = true,
    ["CHudAmmo"]    = true,
    ["CHudCrosshair"] = true,
    ["CHudWeaponSelection"] = true,
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) then
		return false
	end
end )

function GM:HUDPaint()
    if GS_ClPlyStat.init then
        GS_HUD:DrawHud()
    else
        GS_HUD.SpectatorHud()
    end
end


hook.Add("PlayerBindPress", "ActionButton", function(ply, bind, pressed)
    if bind == "gm_showhelp" or bind == "gm_showhelp1" then
        if GS_RoundStatus:GetRoundStatus() == GS_ROUND_PREPARE and LocalPlayer():Team() == TEAM_SPECTATOR then
            DrawStartroundMenu()
        end
    end
end)

function GM:OnContextMenuOpen()
    if LocalPlayer():Team() == TEAM_SPECTATOR or LocalPlayer():GetNWBool("Ragdolled") then
        return
    end
    ContextMenu:ContextMenuOpen()
    gui.EnableScreenClicker(true)
end


function GM:OnContextMenuClose()
    if LocalPlayer():Team() == TEAM_SPECTATOR then
        return
    end
    ContextMenu:ContextMenuClose()
    gui.EnableScreenClicker(false)
end

net.Receive("gs_cl_chatprint", function()
    local color = net.ReadColor()
    local text  = net.ReadString()

    chat.AddText(color, text)
end)

function GM:Initialize()
    GS_RoundStatus:Init()
    DrawStartroundMenu()
end
function MakeDermaAction(name, func, arg)
    net.Start("gs_cl_derma_handler")
    net.WriteString(name)
    net.WriteString(func)
    net.WriteTable(arg)
    net.SendToServer()
end 

function GM:PreDrawPlayerHands( hands, vm, ply, weapon )
    if weapon:GetClass() == "gs_swep_hand" then
        if weapon:GetNWBool("FightHand") then
            return false
        else
            return true 
        end
    end
end
