include("organism_status.lua")

PLAYER_HP = {}

function PLAYER_HP:SetupHPSystem()
	--[[
	REWRITE:
		F:SetupParts()
		F:SetupOrgans()
	]]


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

	self.Player.Chemicals = CHEMIC_CONTAINER:New_Container(200)
	self.Player.HealthStatus = GS_HS_OK

	self.Player.Special_stats = {
		blood = {
			level = 100,
			bleed = false,
			bleed_rate = 0
		},

		saturation = 100,
		organism_status = {}
	}

	if self.Ragdolled != true then
		self.LastDamage = 0 
		self.CritParalyzeDelay = 0
		self.Ragdolled = false
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
			if !IsValid(self.Player) then
				return
			end

			self:Unragdollize()
		end)
	end

	--GS_ChatPrint(self.Player, "You paralized!", CHAT_COLOR.RED)
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

function PLAYER_HP:BloodThinkStatus()
	local blood = self.Player.Special_stats.blood.level

	if blood > 50 then
		self:EffectSpeedRemove("low_blood")
		self:OrganismStatusRemove("heart_failure", "blood")
		--self:OrganismStatusRemove("stamina_crit", "blood")
	elseif blood > 40 then
		self:EffectSpeedAdd("low_blood",-100, -200)
		--[[
			randomize int 1/12
			stamina crit
		]]
	
	else
		self:OrganismStatus("heart_failure", "blood")
	end
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

	local dmg = 100 - (self.Player.BODY[part][1] + self.Player.BODY[part][2] or 0)

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
	net.WriteUInt(self.Player.HealthStatus, 5)
	net.Send(self.Player)
end

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

function PLAYER_HP:InjectChemical(chem, unit) -- insert in human chem  food, poison etc
	self.Player.Chemicals:Component(chem, unit)
end

function PLAYER_HP:RemoveChemical(chem, unit)
	self.Player.Chemicals:Component(chem,-unit)
end





function PLAYER_HP:Metabolize()
	-- activate 1 unit of chemicals on timer
	for k,v in pairs(self.Player.Chemicals.content) do
		v:OnPlyClbck(self.Player, 1)
	end
end

function PLAYER_HP:GetSaturation()
	return self.Player.Special_stats.saturation
end

function PLAYER_HP:AddSaturation(unit)
	self.Player.Special_stats.saturation = math.Clamp(self.Player.Special_stats.saturation + unit, 0, 100)
end

function PLAYER_HP:SubSaturation(unit)
	self.Player.Special_stats.saturation = math.Clamp(self.Player.Special_stats.saturation - unit, 0, 100)
end

function PLAYER_HP:SaturationStatusTrigger()

	net.Start("gs_ply_hunger")
	net.WriteUInt(self:GetSaturation(), 7)
	net.Send(self.Player)

	print(self:GetSaturation())
end

function PLAYER_HP:StartSaturationTimer()
	timer.Create( self.Player:EntIndex().."_hunger", 40, 0, function()
		if !self.Player:IsValid() then
			self:StopSaturationTimer()
			return
		end

		self:SubSaturation(2)
		self:SaturationStatusTrigger()
	end)
end

function PLAYER_HP:HungerThink()
	if !self.Player:IsValid() then
		return
	end

	local hunger = self:GetSaturation()
	
	if hunger < 10 then
		--self:OrganismStatus("heart_failure", "hunger")
	elseif hunger < 25 then
		self:EffectSpeedAdd("hunger", -100, -225)
		--self:OrganismStatusRemove("heart_failure", "hunger")
	else
		self:EffectSpeedRemove("hunger")
		--self:OrganismStatusRemove("heart_failure", "hunger")
	end
end

function PLAYER_HP:StopSaturationTimer()
	timer.Destroy(self.Player:UserID().."_hunger")
end

function PLAYER_HP:Death()

	--	move to ghost
	--	spawn a ragdoll, ragdoll of death person
	--	set him equipments and other
--[[
	if self.Ragdolled then
		GS_Corpse.SetRagdollDeath(self.Player, self.Player.Ragdoll)
	else
		 --create ragdoll
		self:Ragdollize()
		GS_Corpse.SetRagdollDeath(self.Player, self.Player.Ragdoll)
	end

	self:StopThink()
	self:CloseHudClient()

	PlayerSpawnAsSpectator(self.Player)
	
	hook.Run("GS_PlayerDead", self.Player:SteamID())
	player_manager.ClearPlayerClass( self.Player )

	print(self.Player.Special_stats)
--]]
end

function PLAYER_HP:OrganismStatus(newStatus, origin)
	if organism_status_list[newStatus] == nil then
		return
	end
	
	local start_status = false

	if self.Player.Special_stats.organism_status[newStatus] == nil then
		self.Player.Special_stats.organism_status[newStatus] = {}
		start_function = true
	end

	if self.Player.Special_stats.organism_status[newStatus][origin] then
		return
	end

	self.Player.Special_stats.organism_status[newStatus][origin] = true

	if start_status then 
		organism_status_list[newStatus]["start_function"](self)
	end
end

function PLAYER_HP:OrganismStatusThink()
	for k, _ in self.Player.Special_stats.organism_status do
		organism_status_list[k]["think_function"](self)
	end
end

function PLAYER_HP:OrganismStatusRemove(status, origin)
	if !self.Player.Special_stats.organism_status[status] then
		return
	end

	if !self.Player.Special_stats.organism_status[status][origin] then
		return
	end

	self.Player.Special_stats.organism_status[status][origin] = nil

	if table.Count(self.Player.Special_stats.organism_status[status]) == 0 then
		organism_status_list[status]["end_function"](self)
		self.Player.Special_stats.organism_status[status] = nil
	end
end

function PLAYER_HP:OrganismStatusRemoveAll()
	self.Player.Special_stats.organism_status = {}
end

