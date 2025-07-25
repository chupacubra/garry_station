//include("sv_player_ext.lua")

function GM:PlayerInitialSpawn(ply)
	ply:SetTeam( TEAM_PLY )
end

function GM:PlayerSpawn( ply )
	debug.Trace()

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

hook.Add("PlayerDroppedWeapon", "GameDropWeapon" , function(ply, swep)
	// give hands, if drop some wep
	// weapon already dropped after this
	if !(ply:IsValid() or ply:IsActive()) or !IsValid(swep) then return end
	if !swep.GMSWEP or swep.isHands then 
		return
	end

	local weps = ply:GetWeapons()
	
	for k, v in pairs(weps) do
		if v.IsHands or v.GMSWEP then continue end
		table.remove(weps, k)
	end

	if #weps >= 2 then return end

	local hands = {
		"gs_hands_l",
		"gs_hands_r",
	}

	for k, v in pairs(hands) do
		if ply:GetWeapon(v) == nil then ply:PickupWeapon(v) end		
	end
end)

hook.Add("WeaponEquip", "GameWeaponPickup", function(swep, ply)
	// drop active hand if pickup wep

	if !(ply:IsValid() or ply:IsActive())  then return end
	if !swep.GMSWEP then 
		return
	end

	--local hands = {
	--	ply:GetWeapon("gs_hands_l"),
	--	ply:GetWeapon("gs_hands_r")
	--}

	local active = ply:GetActiveWeapon()
	
	if !IsValid(active) then return end

	if !active.IsHands then 
		return // active swep is not hand
	end

	if active:HaveItem() then
		return // active hand is not empty
	end
	
	active:Remove()
end)

--[[
function OnPickupSWEP(ply, swep)
	debug.Trace()

	if !(ply:IsValid() or ply:IsActive()) or !IsValid(swep) then return end
	if !swep.GMSWEP then 
		//ply:PickupWeapon( ent, false )
		return end
	end

	local hands = {
		ply:GetWeapon("gs_hands_l"),
		ply:GetWeapon("gs_hands_r")
	}

	local active = ply:GetActiveWeapon()
	if !IsValid(active) then
		print("watafak, where you hands, dummy?")	
		return
	end

	if !active.IsHands then 
		print("ACTIVE SWEP MUST BE HANBDS")
		return // active swep is not hand
	end

	if active:HaveItem() then
		return // active hand is not empty
	end
	
	active:Remove()
	//ply:PickupWeapon( ent, false )
end
--]]


function GM:PlayerSwitchFlashlight()
	-- make item flashlight
	//return false
	return true

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
	//return false
	return true
end

function GM:PlayerDeathSound() 
	return true 
end
--[[
function GM:PlayerDeath( victim, inflictor, attacker )
	if !victim.ClassDead then
		player_manager.RunClass( victim, "Death" )
	end
	hook.Run("GS_PlayerDead", victim:SteamID())
	player_manager.ClearPlayerClass( victim )

	self:PlayerSilentDeath(victim)
	PlayerSpawnAsSpectator(victim)
end
--]]
--[[
function GM:PlayerDeathThink( ply )
	//return false
    //return true -- can't respawn
end 
--]]

function GM:PlayerSpawnAsSpectator( ply )
	debug.Trace()
	print(ply)
	ply:StripWeapons()

	ply:SetTeam( TEAM_SPECTATOR )
	//if (GS_Round_System:Status() == GS_ROUND_PREPARE) then
	//	ply:Spectate( OBS_MODE_FIXED )
	//	return
	//end

	ply:Spectate( OBS_MODE_ROAMING )
end

function PlayerForceRespawn(ply, oncorpse)
	/*
		if oncorpse and corpse is valid - get all equip and give respawned
	*/
end

function PlayerSpawnAsSpectator( ply )
	debug.Trace()
	print(ply)
	ply:StripWeapons()

	ply:SetTeam( TEAM_SPECTATOR )
	if (GS_Round_System:Status() == GS_ROUND_PREPARE) then
		ply:Spectate( OBS_MODE_FIXED )
		return
	end
	ply:Spectate( OBS_MODE_ROAMING )
end

function GM:CanPlayerSuicide()
	return true
end

function GM:PlayerDisconnected( ply )
	--[[ IF spectator than nothing
		 IF player -> alive
		 	create ragdoll with label "deep depression"
		 IF player -> ragdolled
		 	override this ragdoll to DEATH

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
	--]]
end


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
		// in accept input checker?
		return true
	end
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


local hg_scaledmg = {
	[HITGROUP_GENERIC]	= 1,
	[HITGROUP_HEAD]		= 2.5,
	[HITGROUP_CHEST]	= 1,
	[HITGROUP_STOMACH]	= 1,
	[HITGROUP_LEFTARM]	= 0.6,
	[HITGROUP_RIGHTARM]	= 0.6,
	[HITGROUP_LEFTLEG]	= 0.6,
	[HITGROUP_RIGHTLEG]	= 0.6,
}

/*
ITEM.IsArmor
ITEM.Protection = {
	[D_BRUTE]	= 20,
	[D_BURN]	= 10,
}
*/

function GM:ScalePlayerDamage(ply, hg, dmg)
	// this called before scale
	// using this for apply damage in ply, because here we have hitgroup - damaged part
	local dmg = dmg:GetDamage()
	local scale = hg_scaledmg[hg] or 1
	local mod_applied = false

	for _, eq in pairs(ARMORY_PART[part]) do
		if eq == "SUIT" then
			print("SUIT ARMOR skibidi")
		end

		local equip = player_manager.RunClass(ply, "GetEquipItem", eq)
		if !IsValid(equip) then continue end
		if !equip.IsArmor then
			local dmgtyp = GS_DMG_LIST[hg_scale] or D_BRUTE 
		else
			mod_applied = true
		end
	end

	if mod_applied then
		// if damaged part dont have armor = scale damage!
		dmg = dmg * hg_scaledmg[hg]
	end

	
end

// need use this for apply damage another(poison, explosion)
local function HandleBodyDamage(ply, dmg)
	if dmg:IsFallDamage() then

	end
end

function GM:EntityTakeDamage( target, dmg )
	if target.corpse then -- ItS a CORPSE!!1
		GS_Corpse.DamageHandler(target, dmg)
		return
	end

	if target:IsPlayer() then
		local typ = dmg:GetDamageType()  
		if typ == DMG_GENERIC then
			// is hand punch
			GAMEMODE:ScalePlayerDamage(target, target:LastHitGroup(), dmg)
		else
			HandleBodyDamage(ply, dmg)
		end
		dmg:SetDamage(0)
		//return true
	end
end

/*
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
*/
concommand.Add("gs_open", function(ply,cmd, arg)
	local id = arg[1]

	Entity(arg[1]):Fire("Use")
end)

concommand.Add( "gs_dropswep", function(ply, str, arg)
	if !ply:IsActive() then return end
	local wep = ply:GetActiveWeapon()
	if !wep:IsValid() or !wep.CanDrop then return end
	ply:DropWeapon()

	//create another hand
end)