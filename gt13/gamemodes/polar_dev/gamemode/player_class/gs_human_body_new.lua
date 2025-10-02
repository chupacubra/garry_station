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

function PLAYER_HP:UpdateLocalNWVars()
	self.Player:SetLocalNWVar("Stamina", self.Player.Organism_Value.stamina)
	self.Player:SetLocalNWVar("Saturation", self.Player.Organism_Value.saturation)
	self.Player:SetLocalNWVar("Pain", self.Player.Organism_Value.pain)
	self.Player:SetLocalNWVar("PainShock", self.Player.Organism_Value.pain_shock)
end

function PLAYER_HP:SetupOrganismValues()
    self.Player.Organism_Value = {
        blood_circulation = 1,
        pain = 0,
        pain_shock = false,
        oxygen = 1,
        stamina = 100,
		stamina_max = 100,
        saturation = 100, // hunger
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


	timer.Simple(0.1, function()
		self:UpdateLocalNWVars()
	end)



	self.Player.Spec_Damage =  {
		toxin = 0,
		hypoxia = 0,
	}

	// всё что сдесь стоит внести в отдельную таблицу
    if !self.Player.Ragdolled then
        self.Player.Chemicals = CHEMIC_CONTAINER:New_Container(self.Player, 200)
		self.Player.Chemicals.data = {}

        self.Player.HealthStatus = GS_HS_OK
        self.Player.Ragdolled = false
        self.Player.CritParalyzeDelay = 0
		self.Player.EffectSpeed  = {}
		self.Player.RagdollTime  = 0
    end

	self.Player.CritRagdoll = 0
	//self.Player.HungerRagdoll = 0
end

function PLAYER_HP:Ragdollize()
	//if !ply.InFake then	
	//end

	ForceFake(self.Player)
end

function PLAYER_HP:Unragdollize()
	// игрок теперь наверн сам будет решать, вставать ему или нет
end

function PLAYER_HP:SetupOrganismThink()
    self:SetupThinkOrgans()
    self:StartSaturationTimer()

    timer.Create("gs_player_think_"..self.Player:EntIndex(), 1, 0, function()
		local ply = self.Player
		local organism_value = ply.Organism_Value

        if !ply:IsValid() then
			self:StopThink()
			return
		end

		self:SubOxygen(0.12)
		
		if organism_value.oxygen <= 0.1 then
			ply.Spec_Damage.hypoxia = ply.Spec_Damage.hypoxia + 1
		elseif ply.Spec_Damage.hypoxia != 0 and organism_value.oxygen > 0.7 then
			ply.Spec_Damage.hypoxia = ply.Spec_Damage.hypoxia - 1
		end

        local dmg = self:GetSumDMG()

        if dmg < 100 then
            ply.HealthStatus = GS_HS_OK
			//self:EffectSpeedRemove("status_crit")
        elseif dmg > 100 then
			//self:EffectSpeedAdd("status_crit", -150, -250)
            -- crit status
            ply.HealthStatus = GS_HS_CRIT
			if ply.CritRagdoll == 0 and flipquart() then
				ply.CritRagdoll = 5
			end
        end

		// check if ply is not running and runed 1 second before
		if !ply:KeyDown(IN_SPEED) and ply.LastInSpeed + 2 < CurTime() then
			organism_value.stamina = math.Clamp(organism_value.stamina + 2, 0, organism_value.stamina_max)
		end
		self:HungerThink()
		self:HealthPartClientUpdate(mainpart)
		self:UpdateLocalNWVars()
		
		local forceFake = self:RagdollThink() 

		if self:RagdollThink() then
			self:Ragdollize()
		else
			self:Unragdollize()
		end

		self.Player.ForceRagdoll = forceFake

	end)
end


function PLAYER_HP:AddStamina(int)
    self.Player.Organism_Value.stamina = math.Clamp(self.Player.Organism_Value.stamina + int, 0, self.Player.Organism_Value.stamina_max)
   // self.Player.Organism_Value.last_dmg = CurTime()
end

function PLAYER_HP:SubStamina(int)
    self.Player.Organism_Value.stamina = math.Clamp(self.Player.Organism_Value.stamina - int, 0, self.Player.Organism_Value.stamina_max)
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
	//if god_enable:GetBool() then return end
    if self.Player.Organism_Value.blood.bleed == false then
        self.Player.Organism_Value.blood.bleed = true
        self.Player.Organism_Value.blood.bleed_rate = 4
        timer.Create("gs_bleed"..self.Player:EntIndex(), 2, 0, function()
			if self.Player.Organism_Value.blood.bleed == false or self.Player.Organism_Value.blood.bleed_rate == 0 then
				self:BleedReset()
				timer.Remove("gs_bleed"..self.Player:EntIndex())
				return
			end

			self.Player.Organism_Value.blood.level = self.Player.Organism_Value.blood.level - self.Player.Organism_Value.blood.bleed_rate
			self.Player.Organism_Value.blood.bleed_rate = self.Player.Organism_Value.blood.bleed_rate - 1
			self:IncreasePain(0.5 * self.Player.Organism_Value.blood.bleed_rate)

			util.Decal( "Blood", self.Player:GetPos(), self.Player:GetPos() - Vector(0, 100, 0), {self.Player, self.Player.Ragdoll} )
		end)
    else
        self.Player.Organism_Value.blood.bleed_rate = self.Player.Organism_Value.blood.bleed_rate + 2
    end
end

function PLAYER_HP:BleedReset()
	self.Player.Organism_Value.blood.bleed = false
	self.Player.Organism_Value.blood.bleed_rate = 0
end
/*
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
*/
function PLAYER_HP:SetHP(body)
	self.Player.Body_Parts = body

	for k,v in pairs(self.Player.Body_Parts) do
		self:HealthPartClientUpdate(k)
	end
end

function PLAYER_HP:HurtPart(part, typeD, dmg)
	//if god_enable:GetBool() then return end
	local brutesum = self:GetSumDMGBrute()

	local organism_value = self.Player.Organism_Value

	if type(typeD) == "table" then
		for k_type, v_dmg in pairs(typeD) do
			if k_type == D_STAMINA then
				self:SubStamina(v_dmg)
			else
				self:HurtPart(part, k_type, v_dmg)
			end
		end
	else
		if typeD == D_STAMINA or typeD == D_TOXIN then
			//continue
		elseif typeD == D_BRUTE then
			if brutesum >= 50 then
				if flipcoin() then
					self:Bleed()
				end
			end
		end
		self:DamageHealth(part, typeD, dmg)
	end
end

function PLAYER_HP:HealPart(part, typeD, hp)
	if self.Player.Body_Parts[part] == nil then
		return false
	end

	self.Player.Body_Parts[part][typeD] = math.max(self.Player.Body_Parts[part][typeD] - hp, 0)
end

// DamageHealth(nil, "toxin", 1)
function PLAYER_HP:DamageHealth(part, typeD, dmg)
	PrintTable(self.Player.Body_Parts)
	print(self.Player," det damage", part, typeD, dmg)
	//if god_enable:GetBool() then return end

	//print(part, typeD, dmg)

	//if typeD == D_STAMINA then
	//	self.Player.
	//end

	if self.Player.Spec_Damage[typeD] then
		self.Player.Spec_Damage[typeD] = self.Player.Spec_Damage[typeD] + dmg
		return
	end

	if self.Player.Body_Parts[part] == nil then
		return false
	end

	self.Player.Body_Parts[part][typeD] = self.Player.Body_Parts[part][typeD] + dmg
end

function PLAYER_HP:HealHealth(part, typeD, dmg)
	//if god_enable:GetBool() then return end
	if self.Player.Spec_Damage[typeD] then
		self.Player.Spec_Damage[typeD] = math.max(self.Player.Spec_Damage[typeD] - dmg, 0)
		return
	end

	if self.Player.Body_Parts[part] == nil then
		return false
	end

	self.Player.Body_Parts[part][typeD] = math.max(self.Player.Body_Parts[part][typeD] - dmg, 0)
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
	local organ_vals = self.Player.Organism_Value
    if CurTime() - 8 > organ_vals.last_dmg then
        self:DecreasePain(0.05)
    end

    if self:GetPain() > 0.7 then
        organ_vals.pain_shock = true
	else
		organ_vals.pain_shock = false
	end

	if self:GetPain() >= 0.5 then
		if flipcoin() then
			GS_ChatPrint(ply, "You feel pain in body...", Color(200,10,10))
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

	local vals = self.Player.Organism_Value

	local hunger = self:GetSaturation()
	
	if hunger < 10 then
		//if self.Player.HungerRagdoll == 0 and flipquart() then
		//	self.Player.HungerRagdoll = 5
		//end
		vals.stamina_max = 20
		vals.stamina = math.Clamp(vals.stamina, 0, vals.stamina_max)
	elseif hunger < 25 then
//		self:EffectSpeedAdd("hunger", -100, -225)
//		self.Player.Organism_Value.stamina = math.Clamp()

		vals.stamina_max = 70
		vals.stamina = math.Clamp(vals.stamina, 0, vals.stamina_max)

		//vals.stamina = math.Clamp()

	else
		//self:EffectSpeedRemove("hunger")
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
	
	debug.Trace()
	print(self.Player, self.Player:Alive())
	self:StopThink()

	//if !IsValid(self.Player:GetNWEntity("Corpse")) then
		self.Player:CreateFakeRagdoll(true)
	//end
	--self:CloseHudClient()
	--self.Player.ClassDead = true
	//self.Player:Kill()
end

function PLAYER_HP:CritParalyze(delay,hard)
	if self.Player.Ragdolled or self.Player.CritParalyzeDelay > CurTime() then
		return false
	end

	if !delay then
		delay = math.random(3, 5)
	end

	self:Ragdollize()
	if !hard then
		self.Player.CritParalyzeDelay = CurTime() + delay + 7
		
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
	
	self.Player.CritRagdoll = math.Clamp(self.Player.CritRagdoll - 1, 0, 15)
	//self.Player.HungerRagdoll = math.Clamp(self.Player.HungerRagdoll - 1, 0, 15)
	
	if self.Player.Organism_Value.pain_shock then
		return true
	end

	if self.Player.Spec_Damage.hypoxia > 50 then
		return true
	end

	//if self.Player.HealthStatus == GS_HS_CRIT and self.Player.CritRagdoll != 0 then
	//	return true
	//end

	// trash
	//	if self.Player.HungerRagdoll != 0 then
	//		return true
	//	end

	if self.Player.Organism_Value.stamina < 1 then
		return true
	end

	return false
end

local BD_EX = {
    head   = "head",
    hand_l = "left hand",
    hand_r = "right hand",
    body   = "torse",
    leg_l  = "left leg",
    leg_r  = "right leg",
}

function PLAYER_HP:BodyExamineData(ply)
    local exam = {}
    for k, v in pairs(BD_EX) do
        local str_part = {}
        local dmg = self.Player.Body_Parts[k]
/*
        if dmg[D_BRUTE] > 40 and dmg[D_BRUTE] < 15 then
            //table.insert(str_part, "numb")
        elseif dmg[D_BRUTE] < 40 then
            //table.insert(str_part, "bruised")
        else
            //table.insert(str_part, "crippled")
        end

		*/

		if dmg[D_BRUTE] > 40  then
            table.insert(str_part, "crippled")
        elseif dmg[D_BRUTE] > 15 then
            table.insert(str_part, "bruised")
		elseif dmg[D_BRUTE] > 5 then
			table.insert(str_part, "numb")
        end
        if dmg[D_BURN] > 40 then
            table.insert(str_part, "very burn")
        elseif dmg[D_BURN] > 15 then
            table.insert(str_part, "burned")
		elseif dmg[D_BURN] > 5 then
            table.insert(str_part, "red")
        end

        local str = "{255 255 255}The "..BD_EX[k].." is a "

        if #str_part == 0 then
            //str = str .. "ok"
			continue

        elseif #str_part == 1 then
            str = str.. "{255 0 0}"..str_part[1]
        else
            str = str .. "{255 0 0}"..str_part[1] .. " {255 255 255}and {255 0 0}".. str_part[2] 
        end
        
        table.insert(exam, str)
    end
    
    if self.Player.Organism_Value.pain_shock or self.Player.Organism_Value.blood.level < 75 then
        table.insert(exam, "{255 255 255}The skin is pale")
    end

    return exam
end