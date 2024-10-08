include("player_ext.lua")

--function GM:PlayerInitialSpawn(ply)
--end

function GM:PlayerSpawn( ply )
	--print(ply:Team(),TEAM_CONNECTING, TEAM_UNASSIGNED)
	if ply:Team() == TEAM_UNASSIGNED then -- joined/conected, set team to specc
		self:PlayerSpawnAsSpectator(ply)
		return
	end

    player_manager.SetPlayerClass( ply, "gs_human" )

    ply:SetupHands()

    player_manager.OnPlayerSpawn( ply )
	player_manager.RunClass( ply, "Spawn" )

    hook.Call( "PlayerSetModel", GAMEMODE, ply )

	ply:SetNoCollideWithTeammates( false )
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

function PickupSWEP(ply, ent)
	// we have 2 hands
	// for BIG weapons (shotguns, automats, miniguns etc) need 2 hands to using
	// for small arms (pistols, smg) and non-weapons swep need 1 free hand
	// 
	// in future:
	// 		small arms - if you have item in hand, when you have a gun - 
	//		holdtype = pistol and some more recoil (depends of power of gun)
	//		if another hands are free:
	//		holdtype = depends of gun(SWEP.DoubleHandedHT, for pistol its a revolver)
	//			and dont have recoil penalty
	
	// check size gun
	ply:PickupWeapon( ent, false )
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
	-- make item flashlight
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

function GM:PlayerCanPickupWeapon()
	return false
end

function GM:PlayerDeathSound() 
	return true 
end

function GM:PlayerDeath( victim, inflictor, attacker )
	if !victim.ClassDead then
		player_manager.RunClass( victim, "Death" )
	end
	hook.Run("GS_PlayerDead", victim:SteamID())
	player_manager.ClearPlayerClass( victim )

	self:PlayerSilentDeath(victim)
	PlayerSpawnAsSpectator(victim)
end

function GM:PlayerDeathThink( ply )
    return true -- can't respawn
end 

function GM:PlayerSpawnAsSpectator( ply )
	debug.Trace()
	print(ply)
	ply:StripWeapons()

	if (GS_Round_System:Status() == GS_ROUND_PREPARE) then
		ply:SetTeam( TEAM_SPECTATOR )
		ply:Spectate( OBS_MODE_FIXED )
		return
	end

	ply:SetTeam( TEAM_SPECTATOR )
	ply:Spectate( OBS_MODE_ROAMING )
end

function PlayerSpawnAsSpectator( ply )
	debug.Trace()
	print(ply)
	ply:StripWeapons()

	if (GS_Round_System:Status() == GS_ROUND_PREPARE) then
		ply:SetTeam( TEAM_SPECTATOR )
		ply:Spectate( OBS_MODE_FIXED )
		return

	end

	ply:SetTeam( TEAM_SPECTATOR )
	ply:Spectate( OBS_MODE_ROAMING )
end

function GM:CanPlayerSuicide()
	return false 
end

function GM:PlayerDisconnected( ply )
	--[[ IF spectator than nothing
		 IF player -> alive
		 	create ragdoll with label "deep depression"
		 IF player -> ragdolled
		 	override this ragdoll to DEATH
	]]
	if ply:IsDead() and ply:Team() == TEAM_SPECTATOR then
		--spectators....

	else
		if !player_manager.RunClass( ply, "IsRagdolled") then
			player_manager.RunClass( ply, "Ragdollize", true)
			GS_Corpse.SetRagdollDeath(ply, ply.Ragdoll, true)
		else
			GS_Corpse.SetRagdollDeath(ply, ply.Ragdoll, true)
		end

		hook.Run("GS_PlayerDead", ply:SteamID())
	end
end

--[[
net.Receive("gs_ply_equip_item",function()
	print("eqiop item")
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()

	if player_manager.RunClass( ply, "HaveEquipment", FAST_EQ_TYPE[ent.Entity_Data.ENUM_Subtype] ) == false then
		local itemData = duplicator.CopyEntTable(ent)

		local succes = player_manager.RunClass( ply, "EquipItem", itemData, FAST_EQ_TYPE[ent.Entity_Data.ENUM_Subtype])
		if succes then ent:Remove() end
		PrintTable(itemData)
	end
end)
--]]

net.Receive("gs_ply_equip_item",function()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()

	if !player_manager.RunClass( ply, "CanEquipItem", ent ) then return end
	// we CAN equip
	ent:ItemHide()
	ent:ItemSetParentContainer(ply)

	player_manager.RunClass( ply, "EquipItem", item)

end)

function GS_ChatPrint(ply, text, color)
	if color == nil then color = Color( 156, 241, 255, 200 ) end
	net.Start("gs_cl_chatprint")
	net.WriteColor(color)
	net.WriteString(text)
	net.Send(ply)
end
--[[
function GS_ReturnExamineTable(ply, tbl)
	net.Start("gs_cl_inventary_examine_return")
	net.WriteTable(tbl)
	net.Send(ply)
end
--]]
--[[
function ClassRun(...)
	local ply = arg[1]
	local func = arg[2]
	
	if !IsValid(ply) then
		GS_MSG("CLASSRUN: "..tostring().." is not a ply")
		return
	end
end
--]]

function GM:GetFallDamage( ply, speed )
	local aproximatelyDamage = speed / 8

	if aproximatelyDamage > 130 then
		-- facking dead
		-- with breaking legs, spine and apply mega damage to legs and chest 
		return 0
	end

	if aproximatelyDamage > 70 then
		-- break 1/2 leg
		-- apply 55 +/- 10 damage to breaken leg(s)
		return 0
	end

	if aproximatelyDamage < 30 then
		return 0
	end
	-- aproximatelyDamage 30-40
	-- damage to leg(s)
	
	local r = math.random(0, n)

	return 0
end

function GM:PlayerUse(ply, ent)
	if !ent:CreatedByMap() then
		return true
	end

	print(ply, ent)
end

function GM:AcceptInput( ent, input, activator, caller, value )
	--print(ent, input, activator, caller, value)
end

function GM:PlayerNoClip( ply, desiredState )
	return GetConVar("sv_cheats"):GetBool()
end

function GM:PlayerDeathSound() 
	return true
end

function GM:EntityTakeDamage( target, dmg )
	if target.corpse then -- ItS a CORPSE!!1
		GS_Corpse.DamageHandler(target, dmg)
		return
	end
	
	if target:IsPlayer() and dmg:GetAttacker() == Entity(0) then
		return true
	end
	return true
end


hook.Add("GS_PlyTakeDamage", "Main", function(victim, attacker, part, dmg)
	-- check, have the ply armor (vest, helmet, armor suit)

	for _, eq in pairs(ARMORY_PART[part]) do
		-- get itemData
		local itemData = player_manager.RunClass( victim, "GetEquipItem", eq)
		if !itemData then continue end

		if eq == "SUIT" then
			-- then itemData == simple string-name of suit
			itemData = GS_EntityList["suit"][itemData]
		end

		if !itemData.Private_Data.Armor_Setting then
			continue -- equip is not armory!
		end

		dmg = dmg - itemData.Private_Data.Armor_Setting.Protection
		if dmg <= 0 then
			-- the armory is facking save yo!
			-- need to notify for this!
			-- HOW?
			-- ChatPrint("The armory softened impact") dont matching, because it's can go to SPAM
			-- need use the some SOUND if metalick or another impact
			-- victim:EmitSound(table.Random(ArmoryImpact))
			return
		end
	end
	player_manager.RunClass( victim, "HurtPart", part, dmg)
end)

concommand.Add("gs_open", function(ply,cmd, arg)
	local id = arg[1]

	Entity(arg[1]):Fire("Use")
end)
