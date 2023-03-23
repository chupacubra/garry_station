PLAYER_EFFECT = {}

function PLAYER_EFFECT:SetSpeed(walk, run)
	self.Player:SetWalkSpeed(walk)
	self.Player:SetRunSpeed(run)
end

function PLAYER_EFFECT:EffectSpeedSet()
	self.Player:SetWalkSpeed(self.CurSpeedWalk)
	self.Player:SetRunSpeed(self.CurSpeedRun) 
end

function PLAYER_EFFECT:EffectSpeedAdd(effect, walk, run)
	if self.EffectSpeed[effect] then
		return
	end

	self.EffectSpeed[effect] = {walk, run}
	self.CurSpeedRun = self.CurSpeedRun + run
	self.CurSpeedWalk = self.CurSpeedWalk + walk

	self:EffectSpeedSet()
end

function PLAYER_EFFECT:EffectSpeedRemove(effect)
	if self.EffectSpeed[effect] == nil then
		return
	end
	local walk, run = unpack(self.EffectSpeed[effect])

	self.CurSpeedRun = self.CurSpeedRun - run
	self.CurSpeedWalk = self.CurSpeedWalk - walk

	self.EffectSpeed[effect] = nil 

	self:EffectSpeedSet()
end

function PLAYER_EFFECT:Ragdollize() -- from ragmod
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
end

function PLAYER_EFFECT:Unragdollize()
	if !IsValid(self.Player.Ragdoll) then
		GS_MSG(self.Player.." lose self corpse ragdoll, move to spectators")
		return
	end

	local sweps = self.Player.SWEP
	local equip = self.Player.Equipment
	local pocket = self.Player.Pocket
	local body   = self.Player.BODY
	local blood, blood_level, blool_rate = self.Player.BloodBleed, self.Player.BloodLevel, self.Player.BloodBleedRate
	local chem = self.Player.Chemicals
	local hp_stat = self.Player.HealthStatus
	local walks  = self.Player:GetWalkSpeed()
	local runs   = self.Player:GetRunSpeed()
	
	--[[this shit don't save after respawn]]

	self.Player:UnSpectate()
	self.Player:SetModel(self.Player.Ragdoll:GetModel())	--?

	self.Player:Spawn()

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
end

function PLAYER_EFFECT:IsRagdolled()
	return self.Ragdolled
end
