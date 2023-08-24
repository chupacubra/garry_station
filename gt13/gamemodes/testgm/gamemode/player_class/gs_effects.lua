PLAYER_EFFECT = {}

local function SpeedRegulator(speed_tbl, def_speed)
--[[
	making two tables of effects:
		negative
		positive

	get maxs in tables

	return DefSpeed + (max_positive + min_negative)
]]
	if table.Count(speed_tbl) == 0 then
		return def_speed
	end

	local max_speed = table_max(speed_tbl)
	local min_speed = table_min(speed_tbl)

	if min_speed > 0 then 
		min_speed = 0
	end
 
	if max_speed < 0 then
		max_speed = 0
	end 

	print(def_speed , (max_speed + min_speed), "shiza")

	return def_speed + (max_speed + min_speed)
end

function PLAYER_EFFECT:SetSpeed(walk, run)
	self.Player:SetWalkSpeed(walk)
	self.Player:SetRunSpeed(run)
end

function PLAYER_EFFECT:EffectSpeedSet()
	print(self.CurSpeedWalk, self.CurSpeedRun , "setup speed")
	self.Player:SetWalkSpeed(self.CurSpeedWalk)
	self.Player:SetRunSpeed(self.CurSpeedRun) 
end

function PLAYER_EFFECT:EffectSpeedAdd(effect, walk, run)
	--debug.Trace()
	--if self.EffectSpeed[effect] then
		--return
	--end

	self.EffectSpeed[effect] = {walk, run}

	print(self.WalkSpeed,self.RunSpeed,"def speed")

	local rez_walk = SpeedRegulator(tbl_get_from_index(self.EffectSpeed,1), self.WalkSpeed)
	local rez_run  = SpeedRegulator(tbl_get_from_index(self.EffectSpeed,2), self.RunSpeed)

	print(rez_walk, rez_run)


	self.CurSpeedWalk = rez_walk
	self.CurSpeedRun = rez_run

	self:EffectSpeedSet()
end

function PLAYER_EFFECT:EffectSpeedRemove(effect)
	if self.EffectSpeed[effect] == nil then
		--GS_MSG("want to remove speed effect, but is nothing!!!1  "..tostring(self.Player))
		return
	end 

	self.EffectSpeed[effect] = nil 

	print(self.WalkSpeed,self.RunSpeed,"def speed")

	local rez_walk = SpeedRegulator(tbl_get_from_index(self.EffectSpeed,1), self.WalkSpeed)
	local rez_run  = SpeedRegulator(tbl_get_from_index(self.EffectSpeed,2), self.RunSpeed)

	self.CurSpeedWalk = rez_walk
	self.CurSpeedRun = rez_run

	self:EffectSpeedSet()
end

function PLAYER_EFFECT:EffectSpeedHave(effect)
	return self.EffectSpeed[effect] != nil
end

function PLAYER_EFFECT:Ragdollize() -- from ragmod
	--debug.Trace()
	if self.Ragdolled then
		return 
	end

	self:DropSWEPBeforeRagdollize()

	local ragdoll = GS_Corpse.Create(self.Player)
	self.Player.Ragdoll = ragdoll

	self.Player.SWEP = {}
	self.Player.SWEP.Hand_Item = false
	self.Player.SWEP.Weapons = {}
	

	for k, v in pairs(self.Player:GetWeapons()) do
		if v:GetClass() == "gs_swep_hand" then
			-- saving ONLY ent in hand
			self.Player.SWEP.Hand_Item = self.Player.Hands:GetItem()
			continue
		end
		table.insert(self.Player.SWEP.Weapons, duplicator.CopyEntTable(v))
	end

	self.Player:StripWeapons()
	self.Player:Spectate( OBS_MODE_CHASE )
	self.Player:SpectateEntity( ragdoll )
	self.Player:SetNoTarget( true )
	
	self.Ragdolled = true

	self.Player:SetNWBool("Ragdolled", true)
end

function PLAYER_EFFECT:Unragdollize()
	--debug.Trace()
	if !IsValid(self.Player.Ragdoll) then
		--GS_MSG(self.Player," lose self corpse ragdoll, move to spectators")
		if self.Ragdolled then
			GS_MSG(self.Player," lose self corpse ragdoll, move to spectators")
		end
		return
	end

	local sweps = self.Player.SWEP
	local equip = self.Player.Equipment
	local pocket = self.Player.Pocket
	local body   = self.Player.Body_Parts
	local chem = self.Player.Chemicals
	local hp_stat = self.Player.HealthStatus
	local walks  = self.Player:GetWalkSpeed()
	local runs   = self.Player:GetRunSpeed()
	local organ_val = self.Player.Organism_Value
	local spec_d = self.Player.Spec_Damage
	local organs = self.Player.Organs

	--[[this shit don't save after respawn]]

	self.Player:UnSpectate()
	--self.Player:SetModel(self.Player.Ragdoll:GetModel())	--?

	--self.Player:Spawn()

	self.Player.SWEP = nil

	local ragdoll = self.Player.Ragdoll
	self.Player:SetPos(ragdoll:GetPos())
	self.Player:SetEyeAngles( Angle(0,0,0) )
	self.Player:SetVelocity( ragdoll:GetVelocity() )
	self.Player:SetNoTarget ( false )
	self.Player.Ragdoll:Remove()
	self.Player.Ragdoll = nil
	self.Ragdolled = false

	GS_EquipWeapon(self.Player, "gs_swep_hand")
	self.Player.Hands = self.Player:GetWeapon("gs_swep_hand")


	if sweps.Hand_Item != false then
		self.Player.Hands:PutItemInHand(sweps.Hand_Item)
	end

	for k, v in pairs(sweps.Weapons) do
		local weap = duplicator.CreateEntityFromTable(Entity(0), v)
		self.Player:PickupWeapon(weap)
	end

	self.Player.Equipment = equip
	self.Player.Pocket = pocket

	self:SendToClientItemsFromPocket()

	for k,v in pairs(self.Player.Equipment) do
		if v == 0 then
			continue
		end
		self:EquipmentEquipClient(v, k)
	end

	self:SetHP(body)
	self:SetSpeed(walks, runs)
	self.Player.HealthStatus = hp_stat
	self.Player.Organs = organs
	self.Player.Organism_Value = organ_val
	self.Player.Spec_Damage = spec_d

	self:HealthPartClientUpdate(part)
	self:SaturationStatusTrigger()

	self.Player:SetNWBool("Ragdolled", false)

end

function PLAYER_EFFECT:IsRagdolled()
	return self.Ragdolled
end
