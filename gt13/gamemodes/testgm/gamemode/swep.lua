--[[local function GetIDWep(ply, id)

end

function DropSWEP( ply, _, args )

    local wep = (#wepid == 0 and ply:GetActiveWeapon()) or GetIDWep(ply, id)


    ply:SelectWeapon("weapon_ttt_unarmed")

    ply:DropWeapon(wep)
end

concommand.Add( "gs_dropwep", DropSWEP)
--]]