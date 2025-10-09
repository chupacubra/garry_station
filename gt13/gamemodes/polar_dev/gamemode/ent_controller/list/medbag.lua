
local ENT = {}

ENT.Base = "gs_entity"

ENT.Name  = "First Aid kit"
ENT.Desc  = "Ti umresh i t.d."
ENT.Model = "models/Items/HealthKit.mdl"
ENT.Size  = ITEM_SMALL

ENT.Spawnable = true
ENT.Category = "Polar Station: items"

ENT.PrimaryActionDelay = 0.5

ENT.Base_Charge = 3

function ENT:PostInit()
    self.Charge = self.Base_Charge
    self.NextAction = 0
    self.Healing = 50
end

local seq = 0
local sound_medtreatment = "" // some bandage sound

function ENT:Examine(ply)
    if CLIENT then return end

    RichTextPrint("It's a {255 255 255}"..self.Name, ply)
    RichTextPrint("{255 255 255}"..self.Desk, ply)

    local text = "{255 255 255}"
    if self.Charge == self.Base_Charge then
        text = text .. "Is full"
    elseif self.Charge == 0 then
        text = text .. "Have some" 
    else
        text = text .. "It's empty"
    end

    RichTextPrint(text, ply)
end

function ENT:PostInit()
    // server-side version of examine
    self:AddContextCallback("Examine",
        function()
            if CLIENT then return end
            self:Examine()
        end,
    "icon16/eye.png",
    nil,  // sub_menu = false 
    true) // run on server = true
end

function ENT:MedTreatment(ply_owner, ply_target)
    if self.Charge < 1 then
        RichTextPrint("It's empty!", ply_owner)
        return
    end

    local self_healing = false
    if !ply_target then 
        ply_target = ply_owner 
        self_healing = true
    end
    
    if !self_healing then
        if ply_owner:GetPos():Distance(ply_target:GetPos()) > 100 then return end // далеко очен
    end
    
    // ply_owner:SetSequence(seq)

    local task = {}
    task.time = 3
    task.func = function()
        if !self_healing then
            if ply_owner:GetPos():Distance(ply_target:GetPos()) > 100 then
                return
            end
        end

        // лечене 50 урона брута на всем теле
        //local brute_sum = player_target:RunClass("GetSumDMGBrute")
        local bodyparts = player_target.BodyParts
        local divider = 0

        for k, v in pairs(bodyparts) do
            if v[D_BRUTE] > 0 then 
                divider = divider + 1
            end
        end

        local heal_part = self.Healing / divider

        for part, v in pairs(bodyparts) do
            ply_target:RunClass("HealPart", part, D_BRUTE, heal_part)
        end

        if ply_target.Organism_Value.blood.bleed then
            ply_target:RunClass("BleedReset")
            RichTextPrint("You stop the bleed", ply_owner)
        end

    end
    self:EmitSound(sound_medtreatment)

    ply_owner:DoTask(task)

    RichTextPrint("You start applying some bandage...",ply_owner)
    if !self_healing then
        RichTextPrint("Vas kto to lechit", ply_target)
    end
end

function ENT:CanAction()
    return self.NextAction < CurTime()
end

function ENT:ItemPrimary(hands, ply)
    if !self.CanAction then return end

    self:MedTreatment(ply)
end

function ENT:ItemSecondary(hands, ply)
    if !self.CanAction then return end

    local trace = ply:MakeViewTrace()

    local target = trace.Entity
    if !IsValid(target) then return end
    if !target:IsPlayer() then return end
    
    self:MedTreatment(ply, target)
end

AddEntItem(Base, "medbag")
