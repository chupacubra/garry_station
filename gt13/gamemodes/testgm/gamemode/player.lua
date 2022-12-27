
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

function GS_EquipWeapon(ply, weapon)
	local ent = ents.Create(weapon)
	ply:PickupWeapon( ent )
end

function GM:PlayerSwitchFlashlight()
	return false
end

function GM:PlayerCanPickupWeapon(ply,weapon)
	return false
end

net.Receive("gs_ply_equip_item",function()
	print("eqiop item")
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()

	print(ply,ent)

	if player_manager.RunClass( ply, "HaveEquipment", FAST_EQ_TYPE[ent.TypeEq] ) == false then
		local itemData = duplicator.CopyEntTable(ent)

		player_manager.RunClass( ply, "EquipItem", itemData, FAST_EQ_TYPE[ent.TypeEq] )
		ent:Remove()
		PrintTable(itemData)
	end
end)