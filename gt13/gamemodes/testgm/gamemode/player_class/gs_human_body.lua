PLAYER_HP = {}


function PLAYER_HP:SetupHPSystem()
	self.Player.BODY = {
		head   = {0,0}, --BRUTE and BURN
		hand_l = {0,0},
		hand_r = {0,0},
		body   = {0,0},
		leg_l  = {0,0},
		leg_r  = {0,0},
	}

	self.Player.HP_Effect = {
		toxin   = 0,
		stamina = 0,
		hypoxia = 0,
	}
	--[[]]
	self.Player.Chemicals = CHEMIC_CONTAINER:New_Container(1000)
	self.Player.BloodLevel = 100
	self.Player.BloodBleed = false
	self.Player.BloodBleedRate  = 0
	self.Player.HealthStatus = GS_HS_OK

	if self.Ragdolled != true then
		self.Chemicals = CHEMIC_CONTAINER:New_Container(1000)
		--self.HealthStatus = GS_HS_OK
		self.LastDamage = 0 
		self.CritParalyzeDelay = 0
		self.Ragdolled = false
		--self.BloodLevel = 100
		--self.BloodBleed = false
		--self.BloodBleedRate  = 0
		self.CurSpeedRun = self.RunSpeed
		self.CurSpeedWalk = self.WalkSpeed
		self.EffectSpeed  = {}
	end
end


function PLAYER_HP:CritParalyze(delay,hard)
	if self.Ragdolled or self.CritParalyzeDelay > CurTime() then
		return false
	end

	if !delay then
		delay = math.random(3, 5)
	end

	self:Ragdollize()
	if !hard then
		self.CritParalyzeDelay = CurTime() + delay + 7
		
		timer.Simple(delay, function()
			self:Unragdollize()
		end)
	end

	GS_ChatPrint(self.Player, "You paralized!", CHAT_COLOR.RED)
end

function PLAYER_HP:HurtPart(bone, dmg)
	local bone = self.Player:TranslatePhysBoneToBone(bone)
	local mainpart

	function PrintBones( entity )
		for i = 0, entity:GetBoneCount() - 1 do
			print( i, entity:GetBoneName( i ) )
		end
	end
	--PrintBones(self.Player)

	while true do
		local isPart, part = getMainBodyPart(bone)
		if isPart then
			mainpart = part
			break
		end
		
		bone = self.Player:GetBoneParent(bone)
	end

	-- ???
	--PrintTable(dmg)
	for k,v in pairs(dmg) do
		print(k,v)
		if k == D_STAMINA or k == D_TOXIN then
			continue
		end
		self:DamageHealth(mainpart, k, v)
	end

	print(mainpart.. " = " ..self:GetHealthPercentPart(mainpart).. "%")
	print("HP: "..self:GetHealthPercent())
	print(self:GetSumDMG())

	if self:GetSumDMG() >= 100 then
		print("!!!CRIT!!!")
	end
	self:HealthPartClientUpdate(mainpart)
end

function PLAYER_HP:SetHP(body)
	self.Player.BODY = body

	for k,v in pairs(self.Player.BODY) do
		self:HealthPartClientUpdate(k)
	end
end

function PLAYER_HP:SetupEffectSystem()
	self.Player.Effects = {}
end

function PLAYER_HP:GetHealthPercentPart(part)
	if self.Player.BODY[part] == nil then
		return 0
	end
	local dmg--[[
	if part != "toxin" and part != "stamina" then
		dmg = 100 - (self.Player.BODY[part][1] + self.Player.BODY[part][2] or 0)
	else
		dmg = 100 - self.Player.BODY[part][1]
	end
	--]]
	dmg = 100 - (self.Player.BODY[part][1] + self.Player.BODY[part][2] or 0)

	if dmg < -100 then
		dmg = -100
	end

	return dmg
end


function PLAYER_HP:GetHealthPercent()
	local dmg = 0

	for k,v in pairs(self.Player.BODY) do
		dmg = dmg + self:GetHealthPercentPart(k)
	end

	dmg = dmg / 6

	return dmg
end

function PLAYER_HP:GetSumDMG()
	local dmg = 0
	
	for k,v in pairs(self.Player.BODY) do
		dmg = dmg + v[1] + v[2]
	end

	dmg = dmg + self.Player.HP_Effect.toxin + self.Player.HP_Effect.hypoxia
	return dmg
end

function PLAYER_HP:HealthPartClientUpdate(part)
	local parthp
	print(part)
	if !part then
		part = 0
		parthp = 0
	else
		if self.Player.BODY[part] == nil then
			return false
		end
	
		parthp = math.floor(self:GetHealthPercentPart(part))
	end
	
	local hp = math.floor(self:GetHealthPercent())

	net.Start("gs_health_update")
	net.WriteString(part)   -- if we hurt the leg
	net.WriteInt(parthp, 8) -- the hp of leg
	net.WriteInt(hp, 8)     -- the ALL hp (100%...)
	net.WriteUInt(self.Player.HealthStatus,5)
	net.Send(self.Player)
end

--[[
function PLAYER_HP:HealthEffectClienUpdate()
	-- if we have crit or smth

end
--]]

function PLAYER_HP:HealHealth(part, typeD, hp)
	if self.Player.BODY[part] == nil then
		return false
	end

	if self.Player.BODY[part][typeD] - hp < 0 then
		self.Player.BODY[part][typeD] = 0
	else
		self.Player.BODY[part][typeD] = self.Player.BODY[part][typeD] - hp
	end
end

function PLAYER_HP:DamageHealth(part, typeD, dmg)
	if self.Player.BODY[part] == nil then
		return false
	end

	self.Player.BODY[part][typeD] = self.Player.BODY[part][typeD] + dmg
end

function PLAYER_HP:DamageStamina(dmg)
	self.Player.HP_Effect.stamina = self.Player.HP_Effect.stamina + dmg
end

function PLAYER_HP:DamageHypoxia(dmg)
	self.Player.HP_Effect.hypoxia = self.Player.HP_Effect.hypoxia + dmg
end

function PLAYER_HP:DamageToxin(dmg)
	self.Player.HP_Effect.toxin = self.Player.HP_Effect.toxin + dmg
end

function PLAYER_HP:GetHypoxia()
	return self.Player.HP_Effect.hypoxia
end

function PLAYER_HP:GetStamina()
	return self.Player.HP_Effect.stamina
end

function PLAYER_HP:GetToxin()
	return self.Player.HP_Effect.toxin
end

function PLAYER_HP:InjectChemical(chem,unit) -- insert in human chem  food, poison etc
	self.Player.Chemicals:Component(chem,unit)
	PrintTable(self.Chemicals)
end

function PLAYER_HP:RemoveChemical(chem,unit)
	self.Player.Chemicals:Component(chem,-unit)
end

function PLAYER_HP:Metabolize()
	-- activate 1 unit of chemicals on timer
	-- and mixing with another
end

function PLAYER_HP:Death()
	--[[
		move to ghost
		spawn a ragdoll, ragdoll of death person
		set him equipments and other
	]]
	if self.Ragdolled then
		GS_Corpse.SetRagdollDeath(self.Player, self.Player.Ragdoll)
	else
		--[[ create ragdoll]]
		self:Ragdollize()
		GS_Corpse.SetRagdollDeath(self.Player, self.Player.Ragdoll)
	end
	self:StopThink()
	self:CloseHudClient()
	PlayerSpawnAsSpectator(self.Player)
	
	hook.Run("GS_PlayerDead", self.Player:SteamID())
	player_manager.ClearPlayerClass( self.Player )
end


function PLAYER_HP:Loadout()
    self.Player:RemoveAllAmmo()
	GS_EquipWeapon(self.Player, "gs_swep_hand")

	self.Player.Hands = self.Player:GetWeapon("gs_swep_hand")
end
