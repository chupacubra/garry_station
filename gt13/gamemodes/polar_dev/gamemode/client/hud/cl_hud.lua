local hide = {
	["CHudHealth"]  = true,
	["CHudBattery"] = true,
    ["CHudAmmo"]    = true,
    ["CHudCrosshair"] = true,
    //["CHudWeaponSelection"] = true,
    ["CHudHistoryResource"] = true
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	return hide[name] != true
end)