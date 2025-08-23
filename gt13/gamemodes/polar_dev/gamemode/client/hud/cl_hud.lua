local hide = {
	["CHudHealth"]  = true,
	["CHudBattery"] = true,
    ["CHudAmmo"]    = true,
    ["CHudCrosshair"] = true,
    ["CHudWeaponSelection"] = true,
    ["CHudHistoryResource"] = true
}


hook.Add( "HUDShouldDraw", "HideHUD", function( name )
    local ply = LocalPlayer()
	return player_manager.GetPlayerClass( ply ) != "gs_human" or hide[name] != true
end)

