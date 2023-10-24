PLAYER_ORGANS = {}

--[[

new values:
    blood circulation = 0/1
    pain = 0/1
    oxygen = 0/1
    stamina = 0/1
    organs_saturation = 0/1

ORGANS:
    brain:
        hp = 50
        if brain dead => player dead
        body without brain - player dead (until brain out of head)
    
    heart:
        hp = 100
        bring oxygen and food to all organs
        
        can stop/damage by:
            pain shock
            no oxygen
            no blood
            toxyn

    lungs:
        hp = 100
        "generate" oxygen for organism
        
    liver:
        hp = 100
        shield from toxin
        if hp low, the toxin damage organs

    kidneys:
        hp = 50
        filtrate some toxin, some SHIELD,
        toxin cause damage

    stomach:
        hp = 100
        metabolism function


    
    SKELET and bones:
        all bones:
            skull
            left/right arm
            spine
            ribs
            left/right leg

        if breaken ...
            skull, ribs:
                damage to closer organs, pain
            spine, legs:
                pain, cant normal walking, ragdoling!
            arms:
                pain, cant normal handle items/sweps, drop items

]]--

function PLAYER_ORGANS:SetupOrgans()
    self.Player.Organs = {
        heart = {
            hp = 100,
            stop = false,
        },

        brain = {
            hp = 100
            --status = 0
        },

        lungs = {
            hp = 100
        },
    
        stomach = {
            hp = 100
        },

        liver = {
            hp = 100
        },

        kidneys = {
            hp = 100
        },
    }
end

function PLAYER_ORGANS:SetupThinkOrgans()
    timer.Create("gs_organs_think_"..self.Player:EntIndex(), 1, 0, function()
        self:BrainThink()
        self:HeartThink()
        self:LungsThink()
        self:StomachThink()
        --PrintTable(self.Player.Organs)
    end)
end

function PLAYER_ORGANS:SetupBones()
    self.Player.Bones = {
        skull = false,
        spine = false,
        l_arm = false,
        r_arm = false,
        l_leg = false,
        r_leg = false,
        ribs  = false,
    }
end

function PLAYER_ORGANS:BoneBroken(bone)
    return self.Player.Bones[bone]
end

function PLAYER_ORGANS:BreakBone(bone)
    if !self.Player.Bones[bone] then
        self.Player.Bones[bone] = true
    end
end

function PLAYER_ORGANS:FixBone(bone)
    if self.Player.Bones[bone] then
        self.Player.Bones[bone] = false
    end
end

function PLAYER_ORGANS:BrainThink()
    if self.Player.Organs.brain == nil then
        -- no brain - no life
        return
    end

    if self:BoneBroken("skull") then
        if flipquart() then
            self:DamageOrgan("brain", math.random(1, 5))
        end
    end

    if self.Player.Organism_Value.oxygen == 0 then
        -- show hypoxia icon
        -- damage organism hypoxia damage
        -- hypoxia dmg - result of lack of oxygen 
        -- return
    end

    if self.Player.Spec_Damage.hypoxia > 25 then
        if flipcoin() then
            --self:CritParalyze()
            self:DamageOrgan("brain", 4)
        end
    end

    if self.Player.Organs.brain.hp == 0 then

        self:Death()
        return
    end

end

function PLAYER_ORGANS:LungsThink()
    if self.Player.Organs.lungs == nil then
        -- no lungs - no oxygen
        return
    end
    
    if self:BoneBroken("ribs") then
        if flipquart() then
            self:DamageOrgan("lungs", math.random(1, 5))
        end
    end

    local hp = self.Player.Organs.lungs.hp

    if hp == 0 then
        --dead lungs
        return
    elseif hp <= 20 or self:GetSaturation() == 0 then
        if flipcoin() then
            self:AddOxygenInBlood(0.05)
        end
    else
        self:AddOxygenInBlood(0.15)
    end
end

function PLAYER_ORGANS:HeartThink()
    if self.Player.Organs.heart == nil then
        -- no heart - no blood move
        return
    end

    if self.Player.Organism_Value.pain_shock then
        -- heart stopped due pain shock
        return
    end

    local hp = self.Player.Organs.heart.hp

    if hp == 0 then
        -- no blood circulation
        return
    elseif hp <= 40 or self:GetSaturation() < 20 then
        -- normal circulation in 50%
        if flipcoin() then
            self:HeartMoveBlood()
        end
    else
        self:HeartMoveBlood()
    end
end

function PLAYER_ORGANS:StopHeart()
    self.Player.Organs.heart.stop = true
end

function PLAYER_ORGANS:StartHeart()
    self.Player.Organs.heart.stop = false
end

function PLAYER_ORGANS:DamageOrgan(organ, dmg)
    self.Player.Organs[organ]["hp"] = math.Clamp(self.Player.Organs[organ]["hp"] - dmg, 0, 100) 
end

function PLAYER_ORGANS:HealthOrgan(heal, dmg)
    self.Player.Organs[organ]["hp"] = math.Clamp(self.Player.Organs[organ]["hp"] + heal, 0, 100) 
end

function PLAYER_ORGANS:StomachThink()
    if self.Player.Organs.stomach == nil then
        -- no stomach - no metabolise
        return
    end

    local hp = self.Player.Organs.stomach.hp
    
    if hp < 40 then
        if flipcoin() then
            self:Metabolize()
        end
    else
        self:Metabolize()
    end
end


function PLAYER_ORGANS:OrgansDamageToxin(target, dmg)
    -- for chemicals poison
    -- if liver/kidneys hp < 30:
    --     damage target
    -- else damage liver/kidneys with dmg/2
    -- layers of protect : first kidneys, second liver

    local liver_hp, kidneys_hp = self.Player.Organs.liver.hp, self.Player.Organs.kidneys.hp
    
    if target == "liver" or target == "kidneys" then
        self:DamageOrgan(target, dmg)
    else
        if liver_hp != 0 then
            self:DamageOrgan(target, dmg * (1 - (liver_hp / 100)))
            self:DamageOrgan("liver", dmg)
        elseif kidneys_hp != 0 then
            self:DamageOrgan(target, dmg / 2)
            self:DamageOrgan("kidneys", dmg)
        else
            self:DamageOrgan(target, dmg)
        end
    end
end

function PLAYER_ORGANS:BodyUseEnergy() -- in saturation timer
    -- waste of energy in body 
    -- ~saturation timer

    for k,v in RandomPairs(self.Player.Organs) do
        if self.Player.Organism_Value.saturation == 0 then
            if flipcoin() then
                self:DamageOrgan(k, 4)
            end
        else
            if v.hp != 0 then
                self:SubSaturation(0.5)
            end
        end
    end

    self:SubSaturation(1)
end

function PLAYER_ORGANS:HeartMoveBlood()
    local blood = self:BloodLevel()
    local oxygen = math.Round( 0.15 * (blood/100) * (self.Player.Organs.heart.hp / 100), 2)
    self:SubOxygenInBlood(0.13)
    self:AddOxygen(oxygen)
end

