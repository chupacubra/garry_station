local ENT = {}

ENT.Base = "gs_chem_container"

ENT.Name  = "Syringe"
ENT.Desc  = "Narkoman"
ENT.Model = "models/props_junk/metalbucket01a.mdl"
ENT.Size  = ITEM_MEDIUM

ENT.Spawnable = true
ENT.Category = "Developing"

ENT.RenderChem = false

ENT.ChemContainerData = {
    Max = 15,
    Chems = {}
}

function ENT:Inject(ply, ent_target)
    if ent_target:IsPlayer() then
        local rec_chem_cont = ent_target.Chemicals

        local transfer = self:GetNWInt("Transfer")
        
        local rec_amount = rec_chem_cont:GetSum()
        if transfer + rec_amount > rec_chem_cont.limit then
            transfer = transfer + (limit - rec_amount)
        end
        if transfer <= 0 then return end

        local drop_chems = FormContent(self.ChemContainer)
        
        local pour = PourLiquid(drop_chems, transfer)

        self.ChemContainer.content = drop_chems
        
        for chem, unit in pairs(pour) do
            rec_chem_cont:AddUnit(chem, unit)
        end

        -- self:ChemContainerUpdate()
        -- rec_chem_cont:ChemContainerUpdate()

        -- rec_chem_cont:MixComp()
    else
        if self:TransferChems(ent_target) then
            RichTextPrint("You injected some...", ply)
            // syringe sound
        end
    end
end

function ENT:Fill(ply, target)
    local transfer = target:GetNWValue("Transfer")
    target:TransferChems(self, transfer)

    RichTextPrint("You fiil a syringe by "..transfer.." units",ply)
end

// inject chemical
// if SHIFT then inject owner
function ENT:ItemPrimary(hands, ply)
    if SERVER then return end
    if ply:KeyDown(IN_SPEED) then
        self:Inject(ply)
        return
    end

    local trace = ply:MakeViewTrace()

    local target = trace.Entity 
    if !IsValid(target) then return end
    if target.IsChemContainer or target:IsPlayer() then
        self:Inject(ply, target)
    end
end

// fill the syringe from target
// if SHIFT then ... what?
function ENT:ItemSecondary(hands, ply)
    if SERVER then return end
    if ply:KeyDown(IN_SPEED) then
        //
    end

    local trace = ply:MakeViewTrace()

    local target = trace.Entity 
    if !IsValid(target) then return end
    if target.IsChemContainer --[[or target:IsPlayer()--]] then
        self:Fill(ply, target)
    end
end


AddEntItem(ENT, "chem_syringe")
