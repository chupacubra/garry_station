include( "shared.lua" )
include( "sh_enum.lua" )
include( "sh_service.lua")
include( "client/cl_hud_button.lua" )
include( "client/cl_plyhud.lua" )
include( "client/cl_context_menu.lua" )
include( "client/cl_stat.lua" )
include( "client/cl_systems.lua" )

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
    GS_HUD:DrawHud()
end

function GM:PostDrawHUD()
    --if HUD.ContextMenuOpen then
        --GS_ContextMenu:OpenAndDraw()
    --end
end

function GM:PlayerBindPress(ply, bind, pressed)
    print(ply,bind,pressed)
end


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