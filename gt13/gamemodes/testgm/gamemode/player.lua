 function GM:PlayerInitialSpawn(ply)
	print( ply:Nick() .. " joined the server." )
    print("1223")
end

function GM:PlayerSpawn( ply )

    player_manager.SetPlayerClass( ply, "gs_human" )

    ply:SetupHands()
    player_manager.OnPlayerSpawn( ply )


	player_manager.OnPlayerSpawn( ply, transiton )
	player_manager.RunClass( ply, "Spawn" )

    hook.Call( "PlayerSetModel", GAMEMODE, ply )

    self:PlayerLoadout( ply )
end

function GM:PlayerSetModel( ply )

	player_manager.RunClass( ply, "SetModel" )

end

function GM:PlayerSetHandsModel( ply, ent )

	local info = player_manager.RunClass( ply, "GetHandsModel" )
	if ( !info ) then
		local playermodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
		info = player_manager.TranslatePlayerHands( playermodel )
	end

	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end

end

function GM:PlayerLoadout( ply )

	player_manager.RunClass( ply, "Loadout" )

end

function GS_EquipWeapon(ply, weapon) -- for start loadout
	local ent = ents.Create(weapon)
	ply:PickupWeapon( ent )
	if weapon == "gs_swep_hand" then
		timer.Simple(0.5, function()
			ent:SetHoldType("normal")
		end)
	end
end

function GM:PlayerSwitchFlashlight()
	return false
end

function GM:PlayerSwitchWeapon(ply, oldWeapon, newWeapon)
	if oldWeapon:IsValid() then
		if oldWeapon.IsGS_Weapon and oldWeapon:GetActivity() == ACT_VM_RELOAD then
			return true
		end
		return false
	end
end

function GM:PlayerCanPickupWeapon(ply,weapon)
	return false
end

function GM:PlayerDeath( victim, inflictor, attacker )
	player_manager.RunClass( victim, "StopThink" )
end

net.Receive("gs_ply_equip_item",function()
	print("eqiop item")
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()

	if player_manager.RunClass( ply, "HaveEquipment", FAST_EQ_TYPE[ent.TypeEq] ) == false then
		local itemData = duplicator.CopyEntTable(ent)

		local succes = player_manager.RunClass( ply, "EquipItem", itemData, FAST_EQ_TYPE[ent.TypeEq] )
		if succes then ent:Remove() end
		PrintTable(itemData)
	end
end)