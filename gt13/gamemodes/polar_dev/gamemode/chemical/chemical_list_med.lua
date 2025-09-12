// возможн для какого нибудь пластыря, который при на несении на человека вызывал бы callbackInPly, тем самым
// управление местным воздействием химии

// heal burns

local function heal(ply, part, typeD, hp)
    if part then
        ply:RunClass("HealPart", part, typeD, math.random(1,8))
    else
        local parts = ply.Body_Parts
        for part, dmg in RandomPairs(parts) do
            if dmg[typeD] > 0 then
                ply:RunClass("HealPart", part, typeD, math.random(1,8))
                return
            end
        end
    end
end

CHEMIC:New("Sulfadiazine",{
	simpleName = "sulfadiazine",
	callbackInPly = function(self, ply, chem, unit, part)
        heal(ply, part, D_BURN, math.random(1, 8))
    end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
    color = Color(221, 106, 61, 128),
    overdose = 30,
    callbackInPlyOverdose = function(self, ply, chem, unit, part)
        ply:RunClass("DamageHealth", nil, D_TOXIN, 2)
    end
})

CHEMIC:New("Salicylic Acid",{
	simpleName = "salicylic_acid",
	callbackInPly = function(self, ply, chem, unit, part)
        heal(ply, part, D_BRUTE, math.random(1, 8))
    end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
    color = Color(221, 61, 101, 128)
})

CHEMIC:New("Charcoal",{
	simpleName = "charcoal",
	callbackInPly = function(self, ply, chem, unit, part)
        ply:RunClass("HealHealth", nil, "toxin", math.random(1,8))
        // clean other chems
        for chem, unit in pairs(self.content) do
            if chem == "charcoal" then continue end
            self:DecComponent(chem, math.random(1, 5))
        end
    end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
    color = Color(32, 32, 32)
})

CHEMIC:New("Salbutamol",{
	simpleName = "salbutamol",
	callbackInPly = function(self, ply, chem, unit, part)
        ply:RunClass("HealHealth", nil, "hypoxia", math.random(1,8))
        // need add oxygen saturation in ply?
        ply:RunClass("AddOxygenInBlood", 0.03)

    end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
    color = Color(0, 128, 128, 128)
})

CHEMIC:New("Syptic Powder",{
	simpleName = "syptic_powder",
	callbackInPly = function(self, ply, chem, unit, part)
        if not part then

        else
            heal(ply, part, D_BRUTE, math.random(6, 15))
        end
    end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
    color = Color(128, 0, 0)
})

CHEMIC:New("Ephedrine",{
	simpleName = "ephedrine",
	callbackInPly = function(self, ply, chem, unit, part)
        heal(ply, part, D_BRUTE, 1)
        ply:RunClass("HealHealth", nil, "hypoxia", math.random(1,8))
        ply:RunClass("DecreasePain", 0.1)
        // need stamina+++
    end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
    color = Color(34, 87, 87, 128)
})

CHEMIC:New("Epinephrine",{
	simpleName = "epinephrine",
	callbackInPly = function(self, ply, chem, unit, part)
        // epic heal - adrenaline
        // if sumdmg > 30 then heal damage all damage by 1
        // if hypoxia
        local dmg = ply:RunClass("GetSumDMG")
        local hypoxia = ply.Spec_Damage.hypoxia
        if dmg > 20 and dmg < 70 then
            heal(ply, part, D_BRUTE, 1)
            heal(ply, part, D_BURN, 1)
            ply:RunClass("HealHealth", nil, "toxin", 1)
        end

        if hypoxia > 35 then
            ply:RunClass("HealHealth", nil, "hypoxia", 5)
        end

        ply.Organism_Values.pain_shock = false
        // need stamina+++

    end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
    color = Color(34, 87, 87, 128),
    overdose = 20,
    callbackInPlyOverdose = function(self, ply, chem, unit, part)
        // some shieeeeet
        // bom heart
    end
})

CHEMIC:New("Saline-Glucose", {
    simpleName = "saline_glucose",
	callbackInPly = function(self, ply, chem, unit, part)
        // heal pain shock
        // heal some burn and brute

        heal(ply, part, D_BRUTE, 1)
        heal(ply, part, D_BURN, 1)
        
        ply:RunClass("HealHealth", nil, "hypoxia", math.random(1,8))
        ply:RunClass("DecreasePain", 0.1)
    end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
    color = Color(173, 173, 173, 128)
})

CHEMIC:New("Morphine", {
    simpleName = "morphine",
	callbackInPly = function(self, ply, chem, unit, part)
        // pain, pain shock
        ply:RunClass("DecreasePain", 0.2)
        ply.Organism_Values.pain_shock = false
    end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
    color = Color(173, 173, 173, 128),
    overdose = 20,
    callbackInPlyOverdose = function(self, ply, chem, unit, part)
        // sleep hr hr
    end
})