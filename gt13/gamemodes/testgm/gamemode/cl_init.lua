include( "shared.lua" )
include( "sh_enum.lua" )
include( "sh_service.lua" )
include( "client/cl_round.lua" ) 
include( "client/cl_hud_button.lua" )
include( "client/cl_plyhud.lua" )
include( "client/cl_context_menu.lua" )
include( "client/cl_stat.lua" )
include( "client/cl_systems.lua" )
include( "client/cl_corpse.lua" )

include("client/derma/cl_roundstart.lua" )

local hide = {
	["CHudHealth"]  = true,
	["CHudBattery"] = true,
    ["CHudAmmo"]    = true,
    ["CHudCrosshair"] = true,
    --["CHudWeaponSelection"] = true, 
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) then
		return false
	end
end )

function GM:HUDPaint()
    if GS_ClPlyStat.init then
        GS_HUD:DrawHud()
    end
end

function GM:PostDrawHUD()
    --if HUD.ContextMenuOpen then
        --GS_ContextMenu:OpenAndDraw()
    --end
end
--[[
function GM:PlayerBindPress(ply, bind, pressed)
    print(ply,bind,pressed)
end
-]]
hook.Add("PlayerBindPress", "ActionButton", function(ply, bind, pressed)
    print(ply,bind,pressed)
    if bind == "gm_showhelp" or bind == "gm_showhelp1" then
        if GS_RoundStatus:GetRoundStatus() == GS_ROUND_PREPARE and LocalPlayer():Team() == TEAM_SPECTATOR then
            DrawStartroundMenu()
        end
    end
end)

function GM:OnContextMenuOpen()
    ContextMenu:ContextMenuOpen()
    gui.EnableScreenClicker(true)
end


function GM:OnContextMenuClose()
    ContextMenu:ContextMenuClose()
    gui.EnableScreenClicker(false)
end

net.Receive("gs_cl_chatprint", function()
    local color = net.ReadColor()
    local text  = net.ReadString()

    chat.AddText(color, text)
end)
--[[
net.Receive("gs_cl_f_button", function()
    local button = net.ReadUInt(3)
    if button == 1 then
        if GS_RoundStatus:GetRoundStatus() == GS_ROUND_PREPARE and LocalPlayer():Team() == TEAM_SPECTATOR then
            DrawStartroundMenu()
        end
    else

    end
end)
--]]
function MakeDermaAction(menu, func, arg) -- rethink ABoUT THIS!
    net.Start("gs_cl_derma_handler")
    net.WriteString(menu)
    net.WriteString(func)
    net.WriteTable(arg)
    net.SendToServer()
end

GS_RoundStatus:Init()