PLAYER_HP = {}

local god_enable = GetConVar("ps_god")


function GetIcon(dmg)
	if dmg != 0 then
		if dmg < 30 then
			return 2
		elseif dmg < 50 then
			return 3
		elseif dmg < 70 then
			return 4
		elseif dmg < 90 then
			return 5
		else 
			return 6
		end
	else
		return 1
	end
end

function PLAYER_HP:SetupHPSystem()
    self:SetupParts()
    self:SetupOrganismValues()
    self:SetupOrgans()
    self:SetupBones()
    self:SetupOrganismThink()
	self:SetupEffectSystem()
end

function PLAYER_HP:SetupParts()
    self.Player.Body_Parts = {
		head   = {0,0}, --BRUTE and BURN
		hand_l = {0,0},
		hand_r = {0,0},
		body   = {0,0},
		leg_l  = {0,0},
		leg_r  = {0,0},
	}
end

function PLAYER_HP:SetupOrganismValues()
    self.Player.Organism_Value = {
        blood_circulation = 1,
        pain = 0,
        pain_shock = false,
        oxygen = 1,
        stamina = 50,
        saturation = 100,
        toxin = 0,
        last_dmg = 0,
        blood = {
            level = 100,
            bleed = false,
            bleed_rate = 0,
            oxygen = 1
        },
        --organism_status = {}
    }

	self.Player.Spec_Damage =  {
		toxin = 0,
		hypoxia = 0,
	}

    if !self.Ragdolled then
        self.Player.Chemicals = CHEMIC_CONTAINER:New_Container(self.Player, 200)
        self.Player.HealthStatus = GS_HS_OK
        self.Ragdolled = false
        self.CritParalyzeDelay = 0
		self.EffectSpeed  = {}
		self.RagdollTime  = 0
    end

	self.CritRagdoll = 0
	self.HungerRagdoll = 0

end

function PLAYER_HP:SetupOrganismThink()
    self:SetupThinkOrgans()
    self:StartSaturationTimer()

    timer.Create("gs_player_think_"..self.Player:EntIndex(), 1, 0, function()
        if !self.Player:IsValid() then
			self:StopThink()
			return
		end

		self:SubOxygen(0.12)
		
		if self.Player.Organism_Value.oxygen <= 0.1 then
			self.Player.Spec_Damage.hypoxia = self.Player.Spec_Damage.hypoxia + 1
		elseif self.Player.Spec_Damage.hypoxia != 0 and self.Player.Organism_Value.oxygen > 0.7 then
			self.Player.Spec_Damage.hypoxia = self.Player.Spec_Damage.hypoxia - 1
		end

        local dmg = self:GetSumDMG()

        if dmg < 100 then
            self.Player.HealthStatus = GS_HS_OK
			self:EffectSpeedRemove("status_crit")
        elseif dmg > 100 then
			self:EffectSpeedAdd("status_crit", -150, -250)
            -- crit status
            self.Player.HealthStatus = GS_HS_CRIT
			if self.CritRagdoll == 0 and flipquart() then
				self.CritRagdoll = 5
			end
        end


		self:HungerThink()
		self:HealthPartClientUpdate(mainpart)

		if self:RagdollThink() then
			self:Ragdollize()
		else
			self:Unragdollize()
		end
		--PrintTable(self.Player.Organism_Value)
		--PrintTable(self.Player.Spec_Damage)
		self:BodyDebugPrint()
	end)
end

function PLAYER_HP:IncreasePain(int)
    self.Player.Organism_Value.pain = math.Clamp(self.Player.Organism_Value.pain + int, 0, 1)
    self.Player.Organism_Value.last_dmg = CurTime()
end

function PLAYER_HP:DecreasePain(int)
    self.Player.Organism_Value.pain = math.Clamp(self.Player.Organism_Value.pain - int, 0, 1)
end

function PLAYER_HP:GetPain()
    return self.Player.Organism_Value.pain
end

function PLAYER_HP:AddOxygen(int)
    self.Player.Organism_Value.oxygen = math.Clamp(self.Player.Organism_Value.oxygen + int, 0, 1)
end

function PLAYER_HP:SubOxygen(int)
    self.Player.Organism_Value.oxygen = math.Clamp(self.Player.Organism_Value.oxygen - int, 0, 1)
end

function PLAYER_HP:AddOxygenInBlood(int)
    self.Player.Organism_Value.blood.oxygen = math.Clamp(self.Player.Organism_Value.blood.oxygen + int, 0, 1)
end

function PLAYER_HP:SubOxygenInBlood(int)
    self.Player.Organism_Value.blood.oxygen = math.Clamp(self.Player.Organism_Value.blood.oxygen - int, 0, 1)
end

function PLAYER_HP:BloodLevel(int)
    return self.Player.Organism_Value.blood.level
end

function PLAYER_HP:Bleed()
	if god_enable:GetBool() then return end
    if self.Player.Organism_Value.blood.bleed == false then
        self.Player.Organism_Value.blood.bleed = true
        self.Player.Organism_Value.blood.bleed_rate = 4
        timer.Create("gs_bleed"..self.Player:EntIndex(), 2, 0,self.BleedThink)
    else
        self.Player.Organism_Value.blood.bleed_rate = self.Player.Organism_Value.blood.bleed_rate + 2
    end
end

function PLAYER_HP:BleedReset()
	self.Player.Organism_Value.blood.bleed = false
	self.Player.Organism_Value.blood.bleed_rate = 0
end

function PLAYER_HP:BleedThink()
    -- timer = 2 sec
    -- with bleed_rate 5 aproximately human will be empty in 40 seconds
    -- BUT the bleed in bleedThink decreasing in 1 unit
    if self.Player.Organism_Value.blood.bleed == false or self.Player.Organism_Value.blood.bleed_rate == 0 then
		self:BleedReset()
        timer.Remove("gs_bleed"..self.Player:EntIndex())
        return
    end

    self.Player.Organism_Value.blood.level = self.Player.Organism_Value.blood.level - self.Player.Organism_Value.blood.bleed_rate
    self.Player.Organism_Value.blood.bleed_rate = self.Player.Organism_Value.blood.bleed_rate - 1
	self:IncreasePain(0.5 * self.Player.Organism_Value.blood.bleed_rate)

	util.Decal( "Blood", self.Player:GetPos(), self.Player:GetPos() - Vector(0, 100, 0), {self.Player, self.Player.Ragdoll} )
end

function PLAYER_HP:SetHP(body)
	self.Player.Body_Parts = body

	for k,v in pairs(self.Player.Body_Parts) do
		self:HealthPartClientUpdate(k)
	end
end

function PLAYER_HP:HurtPart(mainpart, dmg)
	if god_enable:GetBool() then return end
	local brutesum = self:GetSumDMGBrute()

	for k,v in pairs(dmg) do
		if k == D_STAMINA or k == D_TOXIN then
			continue
		elseif k == D_BRUTE then
			if brutesum >= 50 then
				if flipcoin() then
					self:Bleed()
				end
			end
		end
		self:DamageHealth(mainpart, k, v)
	end

	--print(mainpart.. " = " ..self:GetHealthPercentPart(mainpart).. "%")
	--print("HP: "..self:GetHealthPercent())
	--print(self:GetSumDMG())

	self:HealthPartClientUpdate(mainpart)
end

function PLAYER_HP:HealHealth(part, typeD, hp)
	if self.Player.Body_Parts[part] == nil then
		return false
	end

	if self.Player.Body_Parts[part][typeD] - hp < 0 then
		self.Player.Body_Parts[part][typeD] = 0
	else
		self.Player.Body_Parts[part][typeD] = self.Player.Body_Parts[part][typeD] - hp
	end
end

function PLAYER_HP:DamageHealth(part, typeD, dmg)
	if god_enable:GetBool() then return end
	if self.Player.Body_Parts[part] == nil then
		return false
	end

	self.Player.Body_Parts[part][typeD] = self.Player.Body_Parts[part][typeD] + dmg
end

function PLAYER_HP:InjectChemical(chem, unit) -- insert in human chem  food, poison etc
	self.Player.Chemicals:AddComponent(chem, unit)
end

function PLAYER_HP:RemoveChemical(chem, unit)
	self.Player.Chemicals:DecComponent(chem, unit)
end

function PLAYER_HP:SetHP(body)
	self.Player.Body_Parts = body

	for k,v in pairs(self.Player.Body_Parts) do
		self:HealthPartClientUpdate(k)
	end
end

function PLAYER_HP:SetupEffectSystem()
	self.Player.Effects = {}
end

function PLAYER_HP:GetHealthPercentPart(part)
	if self.Player.Body_Parts[part] == nil then
		return 0
	end

	local dmg = 100 - (self.Player.Body_Parts[part][1] + self.Player.Body_Parts[part][2] or 0)

	if dmg < -100 then
		dmg = -100
	end

	return dmg
end

function PLAYER_HP:GetSumDMG()
	local dmg = 0
	
	for k,v in pairs(self.Player.Body_Parts) do
		dmg = dmg + v[1] + v[2]
	end

	dmg = dmg + self.Player.Spec_Damage.toxin + self.Player.Spec_Damage.hypoxia
	return dmg
end

function PLAYER_HP:GetSumDMGBrute()
	local dmg = 0
	for k,v in pairs(self.Player.Body_Parts) do
		dmg = dmg + v[1]
	end
	return dmg
end

function PLAYER_HP:HealthPartClientUpdate(part)
	local parthp

	if !part then
		part = 0
		parthp = 0
	else
		if self.Player.Body_Parts[part] == nil then
			return false
		end
	
		parthp = math.floor(self:GetHealthPercentPart(part))
	end

	local dmg = math.floor(self:GetSumDMG())
	local icon = GetIcon(dmg)

	--local hp = math.floor(self:GetHealthPercent())

	--[[
		hp = icon on client
		BUT the healthStatus is OP
	]]

	net.Start("gs_health_update")
	net.WriteString(part)   -- if we hurt the leg
	net.WriteInt(parthp, 8) -- the hp of leg
	net.WriteUInt(icon, 5)     -- the hp icon status
	net.WriteUInt(self.Player.HealthStatus, 5) -- the CRIT or DEAD icon stat
	net.Send(self.Player)
end

function PLAYER_HP:HealHealth(part, typeD, hp)
	if self.Player.Body_Parts[part] == nil then
		return false
	end

	if self.Player.Body_Parts[part][typeD] - hp < 0 then
		self.Player.Body_Parts[part][typeD] = 0
	else
		self.Player.Body_Parts[part][typeD] = self.Player.Body_Parts[part][typeD] - hp
	end
end

function PLAYER_HP:DamageHealth(part, typeD, dmg)
	if god_enable:GetBool() then return end
	if self.Player.Body_Parts[part] == nil then
		return false
	end

	self.Player.Body_Parts[part][typeD] = self.Player.Body_Parts[part][typeD] + dmg
end

function PLAYER_HP:GetSaturation()
	return self.Player.Organism_Value.saturation
end

function PLAYER_HP:AddSaturation(unit)
	self.Player.Organism_Value.saturation = math.Clamp(self.Player.Organism_Value.saturation + unit, 0, 100)
	self:SaturationStatusTrigger()
end

function PLAYER_HP:SubSaturation(unit)
	self.Player.Organism_Value.saturation = math.Clamp(self.Player.Organism_Value.saturation - unit, 0, 100)
	self:SaturationStatusTrigger()
end

function PLAYER_HP:StartSaturationTimer()
	timer.Create( "gs_hunger_"..self.Player:EntIndex(), 30, 0, function()
		if !self.Player:IsValid() then
			self:StopSaturationTimer()
			return
		end

        //self:BodyUseEnergy()
	end)
end




-- think func in end

function PLAYER_HP:PainThink()
    if CurTime() - 8 > self.Player.Organism_Value.last_dmg then
        self:DecreasePain(0.05)
    end

    if self:GetPain() > 0.7 then
        self.Player.Organism_Value.pain_shock = true
	else
		self.Player.Organism_Value.pain_shock = false
	end

	if self:GetPain() >= 0.5 then
		if flipcoin() then
			GS_ChatPrint(ply, "You feel pain in body...", Color(10,200,10))
		end
	end
end

function PLAYER_HP:SaturationStatusTrigger()
	net.Start("gs_ply_hunger")
	net.WriteUInt(self:GetSaturation(), 7)
	net.Send(self.Player)

	print(self:GetSaturation())
end

function PLAYER_HP:Metabolize()
	self.Player.Chemicals:HumanMetabolize(1)
end

function PLAYER_HP:HungerThink()
	if !self.Player:IsValid() then
		return
	end

	local hunger = self:GetSaturation()
	
	if hunger < 10 then
		if self.HungerRagdoll == 0 and flipquart() then
			self.HungerRagdoll = 5
		end
	elseif hunger < 25 then
		self:EffectSpeedAdd("hunger", -100, -225)
	else
		self:EffectSpeedRemove("hunger")
	end
end

function PLAYER_HP:StopSaturationTimer()
	timer.Destroy("gs_hunger_"..self.Player:EntIndex())
end


-- REWRITE ALL THIS

function PLAYER_HP:Death()
	--[[
		move to ghost
		spawn a ragdoll, ragdoll of death person
		set him equipments and other
	]]
		--[[
	debug.Trace()

	if self.Ragdolled then
		GS_Corpse.SetRagdollDeath(self.Player, self.Player.Ragdoll)
	else
		--[[ create ragdoll]]
		--self:Ragdollize()
		--GS_Corpse.SetRagdollDeath(self.Player, self.Player.Ragdoll)
	--end

	self:StopThink()

	--self:CloseHudClient()
	--self.Player.ClassDead = true
	//self.Player:Kill()
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


function PLAYER_HP:RagdollThink()
	-- check pain
	-- check hypoxia
	-- check crit status
	
	self.CritRagdoll = math.Clamp(self.CritRagdoll - 1, 0, 15)
	self.HungerRagdoll = math.Clamp(self.HungerRagdoll - 1, 0, 15)
	
	if self.Player.Organism_Value.pain_shock then
		return true
	end

	if self.Player.Spec_Damage.hypoxia > 50 then
		return true
	end

	if self.Player.HealthStatus == GS_HS_CRIT and self.CritRagdoll != 0 then
		return true
	end

	if self.HungerRagdoll != 0 then
		return true
	end
end