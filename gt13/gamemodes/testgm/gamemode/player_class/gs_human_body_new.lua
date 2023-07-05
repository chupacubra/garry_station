PLAYER_HP = {}

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
        organism_status = {}
    }

	self.Player.Spec_Damage =  {
		toxin = 0,
		hypoxia = 0,
	}

    if !self.Ragdolled then
        self.Player.Chemicals = CHEMIC_CONTAINER:New_Container(200)
        self.Player.HealthStatus = GS_HS_OK
        self.Ragdolled = false
        self.CritParalyzeDelay = 0
		self.EffectSpeed  = {}
    end

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
		print(dmg, "1231231")


        if dmg < 100 then
            self.Player.HealthStatus = GS_HS_OK
			self:EffectSpeedRemove("status_crit")
        elseif dmg > 100 then
			self:EffectSpeedAdd("status_crit", 150, 250)
            -- crit status
            self.Player.HealthStatus = GS_HS_CRIT
        end


		self:HungerThink()
		self:HealthPartClientUpdate(mainpart)

		--PrintTable(self.Player.Organism_Value)
		--PrintTable(self.Player.Spec_Damage)
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
	print(self.Player.Organism_Value.oxygen , int, self.Player.Organism_Value.oxygen - int, math.Clamp(self.Player.Organism_Value.oxygen - int, 0, 1) )
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
    if !self.Player.Organism_Value.blood.bleed then
        self.Player.Organism_Value.blood.bleed = true
        self.Player.Organism_Value.blood.bleed_rate = 4
        timer.Create("gs_bleed"..self.Player:EntIndex(), 2, 0,self.BleedThink)
    else
        self.Player.Organism_Value.blood.bleed_rate = self.Player.Organism_Value.blood.bleed_rate + 2
    end
end

function PLAYER_HP:BleedThink()
    -- timer = 2 sec
    -- with bleed_rate 5 aproximately human will be empty in 40 seconds
    -- BUT the bleed in bleedThink decreasing in 1 unit

    if !self.Player.Organism_Value.blood.bleed or self.Player.Organism_Value.blood.bleed_rate == 0 then
        timer.Remove("gs_bleed"..self.Player:EntIndex())
        return
    end

    self.Player.Organism_Value.blood.level = self.Player.Organism_Value.blood.level - self.Player.Organism_Value.blood.bleed_rate
    self.Player.Organism_Value.blood.bleed_rate = self.Player.Organism_Value.blood.bleed_rate - 1
	self:IncreasePain(0.5 * self.Player.Organism_Value.blood.bleed_rate)
end

function PLAYER_HP:SetHP(body)
	self.Player.Body_Parts = body

	for k,v in pairs(self.Player.Body_Parts) do
		self:HealthPartClientUpdate(k)
	end
end

function PLAYER_HP:HurtPart(bone, dmg)
	local bone = self.Player:TranslatePhysBoneToBone(bone)
	local mainpart

	while true do
		local isPart, part = getMainBodyPart(bone)
		if isPart then
			mainpart = part
			break
		end
		
		bone = self.Player:GetBoneParent(bone)
	end

	for k,v in pairs(dmg) do
		print(k,v)
		if k == D_STAMINA or k == D_TOXIN then
			continue
		end
		self:DamageHealth(mainpart, k, v)
	end

	--print(mainpart.. " = " ..self:GetHealthPercentPart(mainpart).. "%")
	--print("HP: "..self:GetHealthPercent())
	print(self:GetSumDMG())

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
	if self.Player.Body_Parts[part] == nil then
		return false
	end

	self.Player.Body_Parts[part][typeD] = self.Player.Body_Parts[part][typeD] + dmg
end

function PLAYER_HP:InjectChemical(chem, unit) -- insert in human chem  food, poison etc
	self.Player.Chemicals:Component(chem, unit)
end

function PLAYER_HP:RemoveChemical(chem, unit)
	self.Player.Chemicals:Component(chem,-unit)
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


function PLAYER_HP:GetHealthPercent()
	--[[
	local dmg = 0 

	for k,v in pairs(self.Player.Body_Parts) do
		dmg = dmg + self:GetHealthPercentPart(k)
	end

	for k,v in pairs(self.Player.Spec_Damage) do

		dmg = dmg + v
	end

	dmg = (dmg / 8)
	print(dmg, "123")
	return dmg
	--]]
end

function PLAYER_HP:GetSumDMG()
	local dmg = 0
	
	for k,v in pairs(self.Player.Body_Parts) do
		dmg = dmg + v[1] + v[2]
	end

	dmg = dmg + self.Player.Spec_Damage.toxin + self.Player.Spec_Damage.hypoxia
	return dmg
end

function PLAYER_HP:HealthPartClientUpdate(part)
	local parthp
	print(part)
	if !part then
		part = 0
		parthp = 0
	else
		if self.Player.Body_Parts[part] == nil then
			return false
		end
	
		parthp = math.floor(self:GetHealthPercentPart(part))
	end

	local icon = 1 -- the base 100% icon
	local dmg = math.floor(self:GetSumDMG())

	--[[
		!
	]]
	print(dmg)
	
	if dmg != 0 then
		if dmg < 30 then
			icon = 2
		elseif dmg < 50 then
			icon = 3
		elseif dmg < 70 then
			icon = 4
		elseif dmg < 90 then
			icon = 5
		else 
			icon = 6
		end
	end

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
	if self.Player.Body_Parts[part] == nil then
		return false
	end

	self.Player.Body_Parts[part][typeD] = self.Player.Body_Parts[part][typeD] + dmg
end





function PLAYER_HP:Metabolize()
	-- activate 1 unit of chemicals on timer
	for k,v in pairs(self.Player.Chemicals.content) do
		v:OnPlyClbck(self.Player, 1)
	end
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
	timer.Create( self.Player:EntIndex().."_hunger", 30, 0, function()
		if !self.Player:IsValid() then
			self:StopSaturationTimer()
			return
		end

		--self:SubSaturation(2)
        self:BodyUseEnergy()
        --self:SaturationStatusTrigger()
	end)
end




-- think func in end

function PLAYER_HP:PainThink()
    if CurTime() - 10 > self.Player.Organism_Value.last_dmg then
        self:DecreasePain(0.05)
    end

    if self:GetPain() > 0.5 then
        self.Player.Organism_Value.pain_shock = true
        timer.Simple(10, function()
            self.Player.Organism_Value.pain_shock = false
        end)
    end
end

function PLAYER_HP:SaturationStatusTrigger()

	net.Start("gs_ply_hunger")
	net.WriteUInt(self:GetSaturation(), 7)
	net.Send(self.Player)

	print(self:GetSaturation())
end










-- REWRITE ALL THIS




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

	print(self.Player.Organism_Value)
end

function PLAYER_HP:OrganismStatus(newStatus, origin)
	if organism_status_list[newStatus] == nil then
		return
	end
	
	local start_status = false

	if self.Player.Organism_Value.organism_status[newStatus] == nil then
		self.Player.Organism_Value.organism_status[newStatus] = {}
		start_function = true
	end

	if self.Player.Organism_Value.organism_status[newStatus][origin] then
		return
	end

	self.Player.Organism_Value.organism_status[newStatus][origin] = true

	if start_status then 
		organism_status_list[newStatus]["start_function"](self)
	end
end

function PLAYER_HP:OrganismStatusThink()
	for k, _ in self.Player.Organism_Value.organism_status do
		organism_status_list[k]["think_function"](self)
	end
end

function PLAYER_HP:OrganismStatusRemove(status, origin)
	if !self.Player.Organism_Value.organism_status[status] then
		return
	end

	if !self.Player.Organism_Value.organism_status[status][origin] then
		return
	end

	self.Player.Organism_Value.organism_status[status][origin] = nil

	if table.Count(self.Player.Organism_Value.organism_status[status]) == 0 then
		organism_status_list[status]["end_function"](self)
		self.Player.Organism_Value.organism_status[status] = nil
	end
end

function PLAYER_HP:OrganismStatusRemoveAll()
	self.Player.Organism_Value.organism_status = {}
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