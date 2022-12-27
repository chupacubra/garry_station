AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

function ENT:Initialize()
	self:SetModel( self.imodel or "model_bucket" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end

    self:SetCanPickup(true)
    if !self.data then
        self.data = {
            name = self:GetEName() or "item_name",
            desc = self:GetDesc() or "item_description",
            primary_action = function(swep, data)
                -- sip from container 
            end
            chemicals = {}
        }
    end
    self:SetENUM_Type(GS_ITEM_CONTAINER)
    self:SetEName()
end

function ENT:AddContainerChemical(chemical)
    -- add in container chem and mix it
end

function ENT:SetChemicals(tabl)

end